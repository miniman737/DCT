#include "stdio.h"

void 2D_IDCT(int * input_stream, int * output_strem);

int main() {
  

 return 0; 
}

// this is the brute force naive solution as provided by
// Mihai SIMA in slide deck 4 of the SENG440 course notes
void 2D_DCT(uint16_t * input_stream, uint16_t * output_stream) {
  // input and output for the system
  uint16_t i_block[8][8], o_block[8][8];
  uint16_t t1_block[8][8], t2_block[8][8];
  
  // counter values for the loops
  int k, l;

  for (k = 0; k < 8; k++) {
    for(l = 0; l < 8; l++) {
      i_block[k][l] = input_stream[8 * k + l];
    }
  }

  for (k=0; k < 8; k++) {
    dct(i_block[k], t1_block[k]);
  }

  transposition(t1_block, t2_block);

  for (k=0; k < 8; k++) {
    dct(t2_block[k], o_block[k]);
  }

  for (k=0; k < 8; k++) {
    output_stream[8 * k + l] = o_block[k][l];
  }
}

void dct(int * input, int * output){
  uint_t n, k;


}

void transposition() {}

