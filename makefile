# compile on the DE1-SoC board (Cortex-A9, hard-float ABI):
#   make
# Run (needs /dev/mem):
#   sudo ./benchmark

CC     = gcc
CFLAGS = -O2 -march=armv7-a -mfpu=neon -mfloat-abi=hard -Wall -Wextra
LIBS   = -lm

benchmark: benchmark.c
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

clean:
	rm -f benchmark
