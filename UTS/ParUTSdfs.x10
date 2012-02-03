import x10.util.Random;
import x10.compiler.Inline;
import x10.compiler.Uncounted;

final class ParUTSdfs {
    val stack:MyStack[SHA1RandXX];
    val thieves:FixedSizeStack[Int];
    val temp:FixedSizeStack[Int];
    val lifelines:Rail[Int];
    val lifelinesActivated:Rail[Boolean];
    
    val b:Int;
    val d:Int;
    val k:Int;
    val n:Int;
    val w:Int;
    val l:Int;
    
    val den:Double;
    val myRandom = new Random();
    
    var active:Boolean = false;
    @x10.compiler.Volatile transient var empty:Boolean;
    @x10.compiler.Volatile transient var waiting:Boolean;
    
    val counter:Counter;
    public def counters()=[counter as Counter];
    
    public def this (b:Int, d:Int, k:Int, n:Int, w:Int, l:Int, lifelines:Rail[Int]) {
        this.b = b;
        this.den = Math.log(b/(1.0+b));
        this.d = d-1;
        this.k = k;
        this.n = n;
        this.w = w;
        this.l = l;
        this.lifelines = lifelines;
        this.counter = new Counter(false);
        stack = new MyStack[SHA1RandXX](65536);
        thieves = new FixedSizeStack[Int](lifelines.size+2);
        temp = new FixedSizeStack[Int](Place.MAX_PLACES);
        lifelinesActivated = new Rail[Boolean](Place.MAX_PLACES);
        
        // 1st wave
        val i = Runtime.hereInt();
        if (2*i+1<Place.MAX_PLACES) thieves.push(2*i+1);
        if (2*i+2<Place.MAX_PLACES) thieves.push(2*i+2);
        if (i > 0) lifelinesActivated((i-1)/2) = true;
    }
    
    @Inline def score(node:SHA1RandXX) = (1L << (d - node.depth())) * node.breadth();
    
    @Inline final def push(node:SHA1RandXX) {
        val depth = node.depth();
        val breadth = node.breadth() - 1;
        if (depth < d) {
            if (breadth > 0) stack.push(SHA1RandXX(node));
            val child = SHA1RandXX(node, breadth);
            if (child.breadth() > 0) stack.push(child);
        } else {
            counter.nodesCounter += breadth;
        }
    }
    
    @Inline final def processLoot(loot:Rail[SHA1RandXX], lifeline:Boolean) {
        counter.incRx(lifeline, loot.size);
        var i:Int=0;
        for (; i<loot.size; ++i) {
            push(loot(i));
        }
        counter.nodesCounter += i;
    }
    
    @Inline final def processAtMostN() {
        var i:Int=0;
        do {
            push(stack.pop());
        } while ((++i<n) && (stack.size()>0));
        counter.nodesCounter += i;
    }
    
    /** A trivial function to calculate minimum of 2 integers */
    @Inline def min(i:Int,j:Int) = i < j ? i : j;
    
    final def processStack(st:PlaceLocalHandle[ParUTSdfs]) {
        do {
            while (stack.size() > 0) {
                processAtMostN();
                Runtime.probe();
                distribute(st);
            }
        } while (steal(st));
    }
    
    @Inline def distribute(st:PlaceLocalHandle[ParUTSdfs]) {
        var numThieves:Int = thieves.size() + temp.size();
        if (numThieves == 0) return;
        val lootSize = stack.size();
        if (lootSize >= 2) {
            numThieves = min(numThieves+1, lootSize);
            val numToSteal = lootSize/numThieves;
            val victim = Runtime.hereInt();
            for (var i:Int=1; i < numThieves; ++i) {
                val loot = stack.pop(numToSteal);
                if (temp.size() > 0) {
                    val thief = temp.pop();
                    counter.nodesGiven += numToSteal;
                    ++counter.stealsSuffered;
                    if (thief >= 0) {
                        at (Place(thief)) @Uncounted async { st().deal(st, loot, victim); st().waiting = false; }
                    } else {
                        at (Place(-thief-1)) @Uncounted async { st().deal(st, loot, -1); st().waiting = false; }
                    }
                } else {
                    val thief = thieves.pop();
                    counter.incTxNodes(numToSteal);
                    at (Place(thief)) async st().deal(st, loot, victim);
                }
            }
        }
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
    
    def request2(st:PlaceLocalHandle[ParUTSdfs], thief:Int, isLifeLine:Boolean) {
    	++counter.stealsReceived;
    	val length = stack.size();
    	val numSteals = k==0 ? (length >= 2 ? length/2 : 0) : (k < length ? k : (k/2 < length ? k/2 : 0));
    	if (numSteals == 0) {
    		if (isLifeLine) thieves.push(thief);
    		at (Place(thief)) @Uncounted async { st().waiting = false; }
    	} else {
    		val loot = stack.pop(numSteals);
    		counter.nodesGiven += numSteals;
    		++counter.stealsSuffered;
    		val victim = isLifeLine ? Runtime.hereInt() : -1;
    		at (Place(thief)) @Uncounted async { st().deal(st, loot, victim); st().waiting = false; }
    	}
    }
    
    def steal(st:PlaceLocalHandle[ParUTSdfs]) {
        val P = Place.MAX_PLACES;
        if (P == 1) return false;
        val p = Runtime.hereInt();
        empty = true;
        for (var i:Int=0; i < w && empty; ++i) {
            var q:Int = 0;
            while ((q = myRandom.nextInt(P)) == p);
            counter.incStealsAttempted();
            waiting = true;
            at (Place(q)) @Uncounted async st().request(st, p, false);
            while (waiting) Runtime.probe();
        }
        for (var i:Int=0; (i<lifelines.size) && empty && (0<=lifelines(i)); ++i) {
            val lifeline = lifelines(i);
            if (!lifelinesActivated(lifeline)) {
                lifelinesActivated(lifeline) = true;
                waiting = true;
                at (Place(lifeline)) @Uncounted async st().request(st, p, true);
                while (waiting) Runtime.probe();
            }
        }
        return !empty;
    }
    
    def request(st:PlaceLocalHandle[ParUTSdfs], thief:Int, isLifeLine:Boolean) {
        ++counter.stealsReceived;
        if (stack.size() == 0) {
            if (isLifeLine) thieves.push(thief);
            at (Place(thief)) @Uncounted async { st().waiting = false; }
        } else {
            if (isLifeLine) temp.push(thief); else temp.push(-thief-1);
        }
    }
    
    def deal(st:PlaceLocalHandle[ParUTSdfs], loot:Rail[SHA1RandXX], source:Int) {
        val isLifeLine = source >= 0;
        try {
            if (isLifeLine) lifelinesActivated(source) = false;
            if (active) {
                empty = false;
                processLoot(loot, isLifeLine);
            } else {
                active = true;
                counter.startLive();
                processLoot(loot, isLifeLine);
                //distribute(st);
                processStack(st);
                counter.stopLive();
                active = false;
            }
        } catch (v:Throwable) {
            Console.OUT.println("Exception at " + here);
            v.printStackTrace();
        }
    }
    
    def main(st:PlaceLocalHandle[ParUTSdfs], seed:Int) {
        finish {
            active = true;
            counter.startLive();
            counter.nodesCounter = 2;
            push(SHA1RandXX(seed));
            processStack(st);
            counter.stopLive();
            active = false;
        } 
    }
}