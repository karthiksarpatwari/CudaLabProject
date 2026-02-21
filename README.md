# CudaLabProject

An attempt at trying to do different kinds of filter using GPU acceleration (NVIDIA's NPP library for optimal image operations)

## Features

-**GPU-Accelerated Processing**
-**Batch Processing**
- **Performance Metrics**
- **Progress Tracking **

Applies 5 different kinds of filters

- **Gaussian Blur**
- **Box Blur**
- **Sharpen**
- ** Sobel Edge detection**
- **Median Filter**

### Software
- NVIDIA CUDA toolkit
- CUDA-capable GPU
- C++ Compilter with C++14
- Python3 with Pillow

### Libraries
- CUDA runtime
- NPP (NVIDIA Perf Primitives)
- stb_image/stb_image_write

## Project structure
```
`
|__ image_processor.h # Header file
|__ image_processor.cu # Main cuda
|__ Makefile.image # Build file
|__ generat_test_images.py # Test images
|__ setup.sh #linux script
|__ setup.bat #windows script
|__ input/
|__ output/


# Auto run

run the appropriate script

# manual run

1. Download dependencies
    curl -o stb_image.h https://raw.githubusercontent.com/nothings/stb/master/stb_image.h
    curl -o stb_image_write.h https//raw.githubusercontent.com/nothings/stbd/master/stb_image_write.h

2. Create directories
    mkdir -p input output

3. Generate Test Images
    python3 generate_test_images.py 1000

    or put your own images in the input/ direcotry - expecting them to be input_000.png ...


make -f Makefile.image
./image_processor input output 0

## Acknowledgment
uses stb_image by Sean Barrett
