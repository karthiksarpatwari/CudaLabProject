#ifndef IMAGE_PROCESSOR_H
#define IMAGE_PROCESSOR_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <cuda_runtime.h>
#include <npp.h>

typedef enum {

    FILTER_GAUSSIAN_BLUR,
    FILTER_BOX_BLUR,
    FILTER_SHARPEN,
    FILTER_EDGE_DETECT_SOBEL,
    FILTER_MEDIAN
} FilterType;


typedef struct {
    unsigned char* data;
    int width;
    int height;
    int channels;
    char filename[256];
} Image;

void checkNppError(NppStatus status, const char* msg);
void checkCudaError(cudaError_t error, const char* msg);

Image* loadImage(const char* filename);
void saveImage(const char* filename, Image* img);
void freeImage(Image* img);

void processImageBatch(Image** images, int numImages, FilterType filter);
void applyFilter(Image* img, FilterType filter);

void applyGaussianBlur(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels);
void applyBoxBlur(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels);
void applySharpen(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels);
void applySobelEdgeDetect(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels);
void applyMedianFilter(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels);

void printProgress(int current, int total);

const char* getFilterName(FilterType filter);

#endif