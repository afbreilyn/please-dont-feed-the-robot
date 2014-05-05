public class RoundOff {
    
    0 => float midi_new;
    0 => float midi_abs;

    fun float rounder (float midi_orig){
        while(1) {
            midi_orig => float midi_decimals;
            while (midi_decimals > 1) {
                midi_decimals-1 => midi_decimals;
            }
            
            if (midi_decimals == 1) {
                0 => midi_decimals;
            }
            
            if (midi_decimals > .5) {
                -(1 - midi_decimals) => midi_decimals;
            }
            
            //<<<midi_decimals>>>;
            
            midi_orig - midi_decimals => midi_new => midi_abs;
            
            while (midi_abs > 12.) { // allows 
                midi_abs - 12. => midi_abs;
            }
            
            return midi_new;
            return midi_abs;
            
            //<<<midi_new>>>;
        }
    }
}