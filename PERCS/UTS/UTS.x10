import x10.compiler.Inline;
import x10.compiler.Uncounted;
import x10.util.Option;
import x10.util.OptionsParser;
import x10.util.Random;

//@x10.compiler.NativeCPPInclude("google/profiler.h")

public final class UTS {
    val queue:Queue;
    val thieves:FixedSizeStack[Int];
    val temp:FixedSizeStack[Int];
    val lifelines:Rail[Int];
    val lifelinesActivated:Rail[Boolean];
    
    val n:Int;
    val w:Int;
    
    val random = new Random();
    val logger = new Logger();
    
    var active:Boolean = false;
    @x10.compiler.Volatile transient var empty:Boolean;
    @x10.compiler.Volatile transient var waiting:Boolean;
    
    val P = Place.MAX_PLACES;
    
    public def this(b:Int, d:Int, n:Int, w:Int, l:Int, z:Int) {
        this.n = n;
        this.w = w;
        this.lifelines = new Rail[Int](z, -1);
        
        val h = Runtime.hereInt();
        
        // lifelines
        var x:Int = 1;
        var t:Int = 0;
        for (var j:Int=0; j<z; j++) {
            var v:Int = h;
            for (var k:Int=1; k<l; k++) {
                v = v - v%(x*l) + (v+x)%(x*l);
                if (v<P) {
                    lifelines(t++) = v;
                    break;
                }
            }
            x *= l;
        }
        
        /*
         * Console.OUT.print("" + i + " =>");
         * for (var j:Int=0; j<z; j++) Console.OUT.print(" " + lifelines(j));
         * Console.OUT.println();
         */
        
        queue = new Queue(65536, b, d);
        thieves = new FixedSizeStack[Int](lifelines.size+2);
        temp = new FixedSizeStack[Int](P);
        lifelinesActivated = new Rail[Boolean](P);
        
        // 1st wave
        if (2*h+1 < P) thieves.push(2*h+1);
        if (2*h+2 < P) thieves.push(2*h+2);
        if (h > 0) lifelinesActivated((h-1)/2) = true;
    }
    
    @Inline final def processAtMostN() {
        var i:Int=0;
        for (; (i<n) && (queue.size>0); ++i) {
            queue.expand();
        }
        queue.count += i;
        return queue.size > 0;
    }
    
    @Inline static def min(i:Int,j:Int) = i < j ? i : j;
    
    final def processStack(st:PlaceLocalHandle[UTS]) {
        do {
            while (processAtMostN()) {
                Runtime.probe();
                distribute(st);
            }
            reject(st);
        } while (steal(st));
    }
    
    @Inline def give(st:PlaceLocalHandle[UTS], loot:Queue.Fragment) {
        val victim = Runtime.hereInt();
        logger.nodesGiven += loot.hash.length();
        if (temp.size() > 0) {
            val thief = temp.pop();
            if (thief >= 0) {
                ++logger.lifelineStealsSuffered;
                at (Place(thief)) @Uncounted async { st().deal(st, loot, victim); st().waiting = false; }
            } else {
                ++logger.stealsSuffered;
                at (Place(-thief-1)) @Uncounted async { st().deal(st, loot, -1); st().waiting = false; }
            }
        } else {
            ++logger.lifelineStealsSuffered;
            val thief = thieves.pop();
            at (Place(thief)) async st().deal(st, loot, victim);
        }
    }
    
    @Inline def distribute(st:PlaceLocalHandle[UTS]) {
        var numThieves:Int;
        var t:Int;
        while (((numThieves = thieves.size() + temp.size()) > 0) && (t = queue.select()) >= 0) {
            val lootSize = queue.upper(t) - queue.lower(t);
            numThieves = min(numThieves+1, lootSize);
            val numToSteal = lootSize/numThieves;
            for (var i:Int=1; i < numThieves; ++i) {
                give(st, queue.grab(t, numToSteal));
            }
        }
        if (numThieves == 0) return;
        val lootSize = queue.size;
        numThieves = min(numThieves+1, lootSize);
        val numToSteal = lootSize/numThieves;
        for (var i:Int=1; i < numThieves; ++i) {
            give(st, queue.pop(numToSteal));
        }
        reject(st);
    }
    
    @Inline def reject(st:PlaceLocalHandle[UTS]) {
        while (temp.size() > 0) {
            val thief = temp.pop();
            if (thief >= 0) {
                thieves.push(thief);
                at (Place(thief)) @Uncounted async { st().waiting = false; }
            } else {
                at (Place(-thief-1)) @Uncounted async { st().waiting = false; }
            }
        }
    }
    
    def steal(st:PlaceLocalHandle[UTS]) {
        if (P == 1) return false;
        val p = Runtime.hereInt();
        empty = true;
        for (var i:Int=0; i < w && empty; ++i) {
            var q:Int = 0;
            while ((q = random.nextInt(P)) == p);
            ++logger.stealsAttempted;
            waiting = true;
            at (Place(q)) @Uncounted async st().request(st, p, false);
            while (waiting) Runtime.probe();
        }
        for (var i:Int=0; (i<lifelines.size) && empty && (0<=lifelines(i)); ++i) {
            val lifeline = lifelines(i);
            if (!lifelinesActivated(lifeline)) {
                ++logger.lifelineStealsAttempted;
                lifelinesActivated(lifeline) = true;
                waiting = true;
                at (Place(lifeline)) @Uncounted async st().request(st, p, true);
                while (waiting) Runtime.probe();
            }
        }
        return !empty;
    }
    
    def request(st:PlaceLocalHandle[UTS], thief:Int, lifeline:Boolean) {
        try {
            if (lifeline) ++logger.lifelineStealsReceived; else ++logger.stealsReceived;
            if (queue.size == 0) {
                if (lifeline) thieves.push(thief);
                at (Place(thief)) @Uncounted async { st().waiting = false; }
            } else {
                if (lifeline) temp.push(thief); else temp.push(-thief-1);
            }
        } catch (v:Throwable) {
            error(v);
        }
    }
    
    @Inline final def processLoot(loot:Queue.Fragment, lifeline:Boolean) {
        val n = loot.hash.length();
        if (lifeline) {
            ++logger.lifelineStealsPerpetrated;
            logger.lifelineNodesReceived += n;
        } else {
            ++logger.stealsPerpetrated;
            logger.nodesReceived += n;
        }
        queue.push(loot);
    }
    
    def deal(st:PlaceLocalHandle[UTS], loot:Queue.Fragment, source:Int) {
        try {
            val lifeline = source >= 0;
            if (lifeline) lifelinesActivated(source) = false;
            if (active) {
                empty = false;
                processLoot(loot, lifeline);
            } else {
                active = true;
                logger.startLive();
                processLoot(loot, lifeline);
                //distribute(st);
                processStack(st);
                logger.stopLive();
                active = false;
                logger.nodesCount = queue.count;
            }
        } catch (v:Throwable) {
            error(v);
        }
    }
    
    def main(st:PlaceLocalHandle[UTS], seed:Int) {
        finish {
            try {
                active = true;
                logger.startLive();
                queue.init(seed);
                processStack(st);
                logger.stopLive();
                active = false;
                logger.nodesCount = queue.count;
            } catch (v:Throwable) {
                error(v);
            }
        } 
    }
    
    static def error(v:Throwable) {
        Runtime.println("Exception at " + here);
        v.printStackTrace();
    }
    
    public static def main(args:Array[String](1)) {
        val opts = new OptionsParser(args, null, [
                Option("b", "", "Branching factor"),
                Option("r", "", "Seed (0 <= r < 2^31"),
                Option("d", "", "Tree depth"),
                Option("n", "", "Number of nodes to process before probing. Default 200."),
                Option("w", "", "Number of thieves to send out. Default 1."),
                Option("l", "", "Base of the lifeline"),
                Option("z", "", "Depth of the lifeline"),
                Option("v", "", "Verbose. Default 0 (no).")]);
        
        val b = opts("-b", 4);
        val r = opts("-r", 0);
        val d = opts("-d", 6);
        val n = opts("-n", 200);
        val w = opts("-w", 1);
        val l = opts("-l", 32);
        val z = opts("-z", 1);
        val verbose = opts("-v", 0) != 0;
        
        val P = Place.MAX_PLACES;
        
        Console.OUT.println("places=" + P +
                "   b=" + b +
                "   r=" + r +
                "   d=" + d +
                "   w=" + w +
                "   n=" + n +
                "   l=" + l + 
                "   z=" + z);
        
        val st = PlaceLocalHandle.makeFlat[UTS](PlaceGroup.WORLD, ()=>new UTS(b, d, n, w, l, z));
        
        Console.OUT.println("Starting...");
        //@Native("c++", "ProfilerStart(\"UTS.prof\");") {}
        var time:Long = System.nanoTime();
        st().main(st, r);
        time = System.nanoTime() - time;
        //@Native("c++", "ProfilerStop();") {}
        Console.OUT.println("Finished.");
        
        val logs:Rail[Logger];
        if (P >= 1024) {
            logs = new Rail[Logger](P/32, (i:Int)=>at (Place(i*32)) {
                val h = Runtime.hereInt();
                val n = min(32, P-h);
                val logs = new Rail[Logger](n, (i:Int)=>at (Place(h+i)) st().logger);
                val log = new Logger();
                log.collect(logs);
                return log;
            });
        } else {
            logs = new Rail[Logger](P, (i:Int)=>at (Place(i)) st().logger);
        }
        val log = new Logger();
        log.collect(logs);
        log.stats(time, verbose);
    }
}

// vim: ts=2:sw=2:et
