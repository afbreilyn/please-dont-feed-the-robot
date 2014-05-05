<<<"aaron foster bresley - final project">>>;
<<<"           13 - 05 - 13 ">>>;

//sound network
adc.chan(3) => FFT fft =^ RMS rms => blackhole;
//<<<"working here 1">>>;
adc.chan(1) => LPF lpf => ZeroCrossings zcs => blackhole;
//<<<"working here 2">>>;
adc.chan(3) => dac;
//<<<"working here 3">>>;

/* the mic feeds into chuck: both from MAX/MSP but also live
the live get's played instantly, but the 30 second old sounds
 get analyzed and played back
 */

ResonZ rZed => Envelope e;

SinOsc s; //=> dac;
SinOsc s2; //=> dac;

1500 => lpf.freq;
0. => rZed.gain;

0 => s.freq => s2.freq => rZed.freq;
0 => s.gain => s2.gain; 

//classes
RoundOff r;
UAnaBlob blob;

//OSC sending/receiving
OscRecv recv;
12000 => recv.port;
recv.listen();

"localhost" => string hostname;
12001 => int port;

OscSend emit;
emit.setHost(hostname,port);

//Set Sample Rate
44100.0 => float SAMPLE_RATE;

/// variables
4096 => fft.size => int FFT_SIZE;

int zMax;

int window_size_table[2048]; 
1./2046. => float scaler;
0 => int counter;

//fills a table of all the values of the window size, (multiply by 2 to make sure the hop size stays an int)
for (0 => int i; i < 2047; i++){
    r.rounder((i * i) * scaler) $ int => window_size_table[i];
    //<<<i, window_size_table[i]>>>;
}

1024 => int WINDOW_SIZE; 
5000 => zcs.frame;
int freq_ish;
float Z[FFT_SIZE/2];
float Q[FFT_SIZE];
int MaxI; //stores hight index value
800. => float freq_last;
float freq_move;
float totalfreq;

0 => int count2;
0 => int gotime;

WINDOW_SIZE/2 => int HOP_SIZE;

// windowing
Windowing.hann(WINDOW_SIZE) => fft.window;


// PITCH DETECTION!!!! \\\
spork ~ eny();
spork ~ remys();

while(true){
    if (zcs.zeroes() < 2047) { // if the zero crossings are small that the FFT size
        zcs.zeroes() => freq_ish; //zero crossings 
        
        if (freq_ish < 8) // due to the exponential scaling, starts at 8
            8 => freq_ish;
        else
            freq_ish -1 => freq_ish;
        window_size_table[freq_ish] => WINDOW_SIZE;
        WINDOW_SIZE/2 => int HOP_SIZE;
    }
    else {
        1024 => WINDOW_SIZE; 
        WINDOW_SIZE/2 => HOP_SIZE;
    }
    
    //calculate FFT
    fft.upchuck() @=> blob;
    
    for (0 => int i; i < Z.cap(); i++) {
        fft.fval(i) => Z[i]; 
    }
    
    MaxIndex(Z) => MaxI;
    Bin2freq(MaxI, SAMPLE_RATE, FFT_SIZE) => float freq;
    
    Std.ftom(freq) => float midi_freq;
    r.rounder(midi_freq);
    
    emit.startMsg("/midiNotes_and_freq", "ffii");
    r.midi_new => emit.addFloat;
    freq => emit.addFloat;
    r.midi_abs $ int => emit.addInt;
    freq_ish => emit.addInt;
    
    //<<<"Zero Crossings is: ", zcs.zeroes(), "Freq is: ", freq>>>;
    HOP_SIZE::samp => now;
    
    HOP_SIZE + counter => counter; 
    
    if (counter < 1323000)
    {
        freq + totalfreq => totalfreq; //gives us total frequency
        count2++; 
        1 => gotime;
        //<<<"max">>>;
    }
    
    else{
        totalfreq / count2 => float meow => rZed.freq;
        
        //<<<"meow is: ", meow>>>;
        1 => rZed.Q;
        .8 => rZed.gain;
        //totalfreq / (count2 * 4) => s.freq;
        //0.01 => s.gain; 
        //<<<rZed.freq()>>>;
        0. => totalfreq;
        0 => count2;
        0 => counter;
        
        //<<<"30 seconds passed">>>; 
    }
}

//functions 


fun void eny () {
    while (1) {
        32::second => now;
        e.keyOn();
    }    
}

fun int MaxIndex(float A[]) {
    0.0 => float tempMaxValue;
    0 => int tempMaxIndex;
    
    for (0 => int i; i < A.cap(); i++){
        if (tempMaxValue < A[i]){
            A[i] => tempMaxValue;
            i => tempMaxIndex; 
        }
    }
    return tempMaxIndex; 
}

fun float Bin2freq (int bin, float sr, int fftsize){
    float freq;
    (bin * sr) / fftsize => freq; 
    return freq;   
}


fun void remys() {
    1 => int gate;
    .2 => float threshold;
    MidiOut mout; 
    MidiMsg msg;
    
    if( !mout.open(1)){
        me.exit();
        <<<"midi part not working">>>;
    }
    while (1) {
        rms.upchuck() @=> UAnaBlob blob;
        blob.fval(0) * 1000. => float temp;
        1024::samp => now;
        if ((temp > threshold) && (gate == 0)){
            //<<<"bang", counter>>>;  
            1 => gate;
            144 => msg.data1; //note on
            r.midi_abs $ int => int m;
            m + 1 => m;
            //<<<m>>>;
            if (m <= 0) 0 => m;
            m => msg.data2; // which actuator? (which robot) ... between 0 - 20
            127 => msg.data3; // velocity 
            mout.send(msg); // send MIDI data 
        }
        else if ((temp < threshold) && (gate == 1)){
            0 => gate;
        }
    }
}
