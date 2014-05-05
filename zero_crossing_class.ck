public class ZeroCrossings extends Chugen  {
    (1.0 :: second / 1.0 :: samp) $ int => int SRATE;
    SRATE => int frame;  // how often to update
    0.0 => float lastIn;
    0 => int ZCount;
    0 => int myZeroes;
    0 => int counter;
    
    fun float tick(float in)   {
        if (lastIn < 0.0 & in >= 0.0) {
            1 +=> ZCount;
        }
        in => lastIn;
        1 +=> counter;
        if (counter >= frame) {
            ZCount => myZeroes;
            myZeroes * SRATE / frame => myZeroes; // per second
            0 => ZCount => counter;
        }
        return in;  // might as well, right?
    }
    
    fun int zeroes()  {
        return myZeroes;
    }
    
    fun void setFrame(int frameSamps)  {
        frameSamps => frame;
    }
}

