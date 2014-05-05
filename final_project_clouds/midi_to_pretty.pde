class midi_to_pretty {
  float[] colours = new float[3];
  int r, g, b;
  float what_to_do;
  float midi_num;

  midi_to_pretty (float m) {
    midi_num = m; // ignoring initial input
  }

  float[]update (float at_pitch, int absolute) { /* uses the 12 values of the
   midiconverter to create twelve colours for the clouds */
   
      switch(absolute) {
      case 1: // C
        r = 202;
        g = 48;
        b = 51;
        break;
      case 2: // C#
        r = 99;
        g = 145;
        b = 211;
        break;
      case 3: // D
        r = 175; 
        g = 61;
        b = 121;
        break;
      case 4: // D#
        r = 223;
        g = 204;
        b = 28;
        break;
      case 5: //E
        r = 216;
        g = 209;
        b = 175;
        break;
      case 6: //F
        r = 28;
        g = 209;
        b = 86;
        break;
      case 7: //F#
        r = 28;
        g = 48;
        b = 86;
        break;
      case 8: //G
        r = 204;
        g = 204;
        b = 204;
        break;
      case 9: //G#
        r = 41;
        g = 18;
        b = 11;
        break;
      case 10: //A
        r = 204;
        g = 221;
        b = 136;
        break;
      case 11: //A#
        r = 0;
        g = 0;
        b = 0;
        break;
      case 12: //B
        r = 12;
        g = 12;
        b = 70;
        break;
      }

      colours[0] = r;
      colours[1] = g;
      colours[2] = b;
      return colours;
  }
}

