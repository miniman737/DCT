## SENG 440: Discrete Cosine Transform

Below is the README.md outlining the general file structure of this repo for exploring optimized implementations of the 2D Discrete Cosine Transform used for 8x8 image compression.

## Project Overview
In this project, Marcus Ganz and Owen De Groot investigate the complexity behind Discrete Cosine Transforms, and the implementation restrictions and optimizations of using them on small Single Board ARM 32 bit computers. In this project Owen De Groot, and Marcus Ganz investigate Software, Firmware and Hardware optimizations that all exist when writing C code on embeded systems, and interface with specific hardware. 

Discrete Cosine Transforms is super similar to Discrete Fourier Transforms, except the DCT is occuring in the real domain, and Fourier Transform is occuring in the Frequency Domain. DCT's and DFT's can be used for very similar mathematical and engineering applications, as long as one understands the difference in the wave, and knows that one is in the real domain and one is in the frequency domain. DFT's take more compute and are more challenging to do on small embeded systems, as complex math operations are more costly than performing math in just the real domain.

One of the main purposes of performing DCT's on computers is for performing image compression. JPEG image compression leverages DCT's when making an image smaller. In this project Owen De Groot and Marcus Ganz write their own implementation of a DCT to run on a ARM-32 bit processor to perform efficient image compression of a 320x240 pixel image.

## File Structure
This project will have the following file structure:
- src:
  - brute_force.c
  - dct_loeffler.c
  - dct_hardware_speedup.c
- README.md
