import x10.compiler.Pragma;
import x10.util.Box;
import x10.util.IndexedMemoryChunk;

class RandomAccess {

    static POLY = 0x0000000000000007L;
    static PERIOD = 1317624576693539401L;

    // Utility routine to start random number generator at Nth step
    static def HPCC_starts(var n:Long): Long {
        var i:Int, j:Int;
        val m2 = new Array[Long](64);
        while (n < 0) n += PERIOD;
        while (n > PERIOD) n -= PERIOD;
        if (n == 0L) return 0x1L;
        var temp:Long = 0x1;
        for (i=0; i<64; i++) {
            m2(i) = temp;
            temp = (temp << 1) ^ (temp < 0 ? POLY : 0L);
            temp = (temp << 1) ^ (temp < 0 ? POLY : 0L);
        }
        for (i=62; i>=0; i--) if (((n >> i) & 1) != 0L) break;
        var ran:Long = 0x2;
        while (i > 0) {
            temp = 0;
            for (j=0; j<64; j++) if (((ran >> j) & 1) != 0L) temp ^= m2(j);
            ran = temp;
            i -= 1;
            if (((n >> i) & 1) != 0L)
                ran = (ran << 1) ^ (ran < 0 ? POLY : 0L);
        }
        return ran;
    }

    public static def sqrt(var p:Int) {
        var r:Int = p;
        while (p > 1) { p = p>>2; r = r>>1; }
        return r;
    }

    static def runBenchmark(plhimc: PlaceLocalHandle[Box[IndexedMemoryChunk[Long]]{self!=null}],
                            logLocalTableSize: Int, numUpdates: Long) {
        val mask = (1<<logLocalTableSize)-1;
        val local_updates = numUpdates / Place.MAX_PLACES;

        val max = Place.MAX_PLACES;
        val stride = sqrt(max);

        @Pragma(Pragma.FINISH_SPMD) finish {
            for(var i:Int=0; i<max; i+=stride) {
                val ii = i;
                at(Place(ii)) async {
                    @Pragma(Pragma.FINISH_SPMD) finish {
                        val m = (max < ii+stride) ? max : (ii+stride);
                        for(var j:Int=ii; j<m; ++j) {
                            val jj = j;
                            at(Place(jj)) async {
                                val t = System.nanoTime();
            var ran:Long = HPCC_starts(jj*(numUpdates/Place.MAX_PLACES));
            val imc = plhimc()();
            val size = logLocalTableSize;
            val mask1 = mask;
            val mask2 = Place.MAX_PLACES - 1;
            val poly = POLY;
            val lu = local_updates;
            for (var k:Long=0 ; k<lu ; k+=1L) {
                val place_id = ((ran>>size) as Int) & mask2;
                val index = (ran as Int) & mask1;
                val update = ran;
                if (place_id==jj) {
                    imc(index) ^= update;
                } else {
                    imc.getCongruentSibling(Place(place_id)).remoteXor(index, update);
                }
                ran = (ran << 1) ^ (ran<0L ? poly : 0L);
            }
            
            val u = System.nanoTime() - t;
//            Runtime.println("" + jj + " -> " + (u/1e9));
                            }}}}}
        }
    }

    private static def help (err:Boolean) {
        if (here.id!=0) return;
        val out = err ? Console.ERR : Console.OUT;
        out.println("Usage: ra [-m <mem>] [-u <updates>]");
        out.println("where");
        out.println("   <mem> is the log2 size of the local table (default 12)");
        out.println("   <updates> is the number of updates per element (default 4)");
    }

    public static def main (args:Array[String]{rank==1}) {

        if ((Place.MAX_PLACES & (Place.MAX_PLACES-1)) > 0) {
            Console.ERR.println("The number of places must be a power of 2.");
            return;
        }

        var logLocalTableSize_ : Int = 12;
        var updates_ : Int = 4;

        // parse arguments
        for (var i:Int=0 ; i<args.size ; ) {
            if (args(i).equals("-m")) {
                i++;
                if (i >= args.size) {
                    if (here.id==0)
                        Console.ERR.println("Too few cmdline params.");
                    help(true);
                    return;
                }
                logLocalTableSize_ = Int.parseInt(args(i++));
            } else if (args(i).equals("-u")) {
                i++;
                if (i >= args.size) {
                    if (here.id==0)
                        Console.ERR.println("Too few cmdline params.");
                    help(true);
                    return;
                }
                updates_ = Int.parseInt(args(i++));
            } else {
                if (here.id==0)
                    Console.ERR.println("Unrecognised cmdline param: \""+args(i)+"\"");
                help(true);
                return;
            }
        }

        // calculate the size of update array (must be a power of 2)
        val logLocalTableSize = logLocalTableSize_;
        val localTableSize = 1<<logLocalTableSize;
        val tableSize = (localTableSize as Long)*Place.MAX_PLACES;
        val numUpdates = updates_*tableSize;

        // create congruent array (same address at each place)
        val plhimc = PlaceLocalHandle.makeFlat(Dist.makeUnique(), () => new Box(IndexedMemoryChunk.allocateZeroed[Long](localTableSize, 8, true)) as Box[IndexedMemoryChunk[Long]]{self!=null});
        @Pragma(Pragma.FINISH_SPMD) finish for (p in Place.places()) at (p) async {
            for ([i] in 0..(localTableSize-1)) plhimc()()(i) = i as Long;
        }

        // print some info
        Console.OUT.println("Main table size:         2^"+logLocalTableSize+"*"+Place.MAX_PLACES
                                       +" == "+tableSize+" words"
                                       +" ("+tableSize*8.0/1024/1024+" MB)");
        Console.OUT.println("Per-process table size:  2^"+logLocalTableSize
                                       +" == "+localTableSize+" words"
                                       +" ("+localTableSize*8.0/1024/1024+" MB)");
        Console.OUT.println("Number of places:        " + Place.MAX_PLACES);
        Console.OUT.println("Number of updates:       " + numUpdates);

        // time it
        var cpuTime:Double = -System.nanoTime() * 1e-9D;
        runBenchmark(plhimc, logLocalTableSize, numUpdates);
        cpuTime += System.nanoTime() * 1e-9D;

        // print statistics
        val GUPs = (cpuTime > 0.0 ? 1.0 / cpuTime : -1.0) * numUpdates / 1e9;
        Console.OUT.println("CPU time used: "+cpuTime+" seconds");
        Console.OUT.println(GUPs+" Billion(10^9) Updates per second (GUP/s)");

        // repeat for testing.
        runBenchmark(plhimc, logLocalTableSize, numUpdates);
        @Pragma(Pragma.FINISH_SPMD) finish for (p in Place.places()) at (p) async {
            var err:Int = 0;
            for ([i] in 0..(localTableSize-1)) 
                if (plhimc()()(i) != (i as Long)) err++;
            Console.OUT.println(here+": Found " + err + " errors.");
        }
    }
}
