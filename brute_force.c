#include "stdio.h"
#include "math.h"

#define PI 3.14159265358979
#define N 8

void DCT_2D(int * input_stream, int * output_strem);
void dct(int * input, int * output);
void transposition(int input[N][N], int output[N][N]);

int main() {
	int input[N][N] = {0};
	int output[N][N] = {0};

	DCT_2D(*input, *output);
	for(int x = 0; x < N; x++){
		for(int y = 0; y < N; y++){
			printf("%d\n", output[x][y]);
		}
	} 
	
 return 0; 
}

// this is the brute force naive solution as provided by
// Mihai SIMA in slide deck 4 of the SENG440 course notes
void DCT_2D(int * input_stream, int * output_stream) {
  // input and output for the system
  int i_block[N][N], o_block[N][N];
  int t1_block[N][N], t2_block[N][N];
  
  // counter values for the loops
  int k, l;

  for (k = 0; k < N; k++) {
    for(l = 0; l < N; l++) {
      i_block[k][l] = input_stream[N * k + l];
    }
  }

  for (k=0; k < N; k++) {
    dct(i_block[k], t1_block[k]);
  }

  transposition(t1_block, t2_block);

  for (k=0; k < N; k++) {
    dct(t2_block[k], o_block[k]);
  }

  for (k=0; k < N; k++) {
    output_stream[N * k + l] = o_block[k][l];
  }
}

void dct(int * input, int * output){
  int n, k;
  double sum, ck;

  for(k = 0; k < N; k++){
	  sum = 0.0;

	  ck = (k == 0) ? (1.0 / sqrt(2.0)) : 1.0;

	  for(n = 0; n < N; n++) {
		sum += input[n] * cos(PI * k * (2.0 * n + 1.0) / (2.0 * N));
	  }
	  output[k] = (int)(sum * (2.0 / N) * ck);
  }
}

void transposition(int input[N][N], int output[N][N]) {
	int x = 0;
	int y = 0;
	
	while(x < N) {
		while(y < N) {
			output[y][x] = input[x][y];	
			y++;
		}
		x++;
	}
}

