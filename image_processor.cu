#include "image_processor.h"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

void checkNppError(NppStatus status, const char* msg) {

    if(status != NPP_SUCCESS)
     {
        fprintf(stderr,"NPP Error: %s (code : %d)\n",msg,status);
        exit(1);
     }
}

void checkCudaError(cudaError_t error, const char* msg) {
    if (error != cudaSuccess) {
        fprintf(stderr, "CUDA error : %s - %s\n", msg, cudaGetErrorString(error));
        exit(1);
    }
}

const char* getFilterName(FilterType filter) {

    switch(filter) {
        case FILTER_GAUSSIAN_BLUR: return "Gaussian Blur";
        case FILTER_BOX_BLUR: return "Box Blur";
        case FILTER_SHARPEN: return "Sharpen";
        case FILTER_EDGE_DETECT_SOBEL: return "Sobel Edge Detection";
        case FILTER_MEDIAN: return "Median Filter";
        default: return "Unknown";
    }
}

void printProgress(int current, int total) {
    int percent = (current*100)/totall
    int bars = percent/2;
    printf("\r[");
    for (int i = 0; i < 50; i++) {
        if (i < bars) printf("=");
        else if(i==bars) printf(">");
        else printf(" ");
    }
    printf("] %d%% (%d/%d)",percent,current,total);
    fflush(stdout);
}

Image* loadImage(const char* filename) {
    Image* img = (Image*)malloc(sizeof(Image));
    if(!img) {
        fprintf(stderr, "Failed to allocate memory for image structure\n");
        return NULL;
    }

    int width, height, channels;

    unsigned char* data = stbi_load(filename, &width, &height, &channels,0);

    if(!data) {
        fprintf(stderr, "failed to load image: %s\n",filename);
        free(img);
        return NULL;    
    }

    img->data = data;
    img->width = width;
    img->height = height;
    img->channels = channels;
    strncpy(img->filename, filename, 255);
    img->filename[255] = '\0';

    return img;

}

void saveImage(const char* filename, Image* img) {

    int success = stbi_write_png(filename, img-> width, img->height, img->channels, img->data, img->width*img->channels);
    if(!success) {
        fprintf(stderr, "Failed to save image: %s\n", filename);
    }
}

void freeImage(Image* img) {
    if (img) {
        if (img-> data) {
            stbi_image_free(img->data);
        }
        free(img);
    }
}

void applyGaussianBlur(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels) {
    NppiSize oSizeROI = {width, height};
    NppiPoint oAnchor = {2,2};
    NppStatus status;

    if (channels ==1) {
        status = nppiFilterGauss_8u_C1R(d_src, width, d_dst, width, oSizeROI, NPP_MASK_SIZE_5_X_5);
    } else if (channels == 3) {
        status = nppiFilterGauss_8u_C3R(d_src,width*3, d_dst, width*3, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }
    else if (channels == 4) {
        status = nppiFilterGauss_8u_AC4R(d_src, width*4, d_dst, width*4, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }

    checkNppError(status, "Gaussian Blur Filter Failed!");
}

void applyBoxBlur(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels) {
    NppiSize oSizeROI = {width, height};
    NppiPoint oAnchor = {2,2};
    NppStatus status;

    if (channels ==1) {
        status = nppiFilterBox_8u_C1R(d_src, width, d_dst, width, oSizeROI, NPP_MASK_SIZE_5_X_5);
    } else if (channels == 3) {
        status = nppiFilterBox_8u_C3R(d_src,width*3, d_dst, width*3, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }
    else if (channels == 4) {
        status = nppiFilterBox_8u_AC4R(d_src, width*4, d_dst, width*4, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }

    checkNppError(status, "Box Filter Failed!");
}

void applySharpen(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels) {
    NppiSize oSizeROI = {width, height};
    NppiPoint oAnchor = {2,2};
    NppStatus status;

    if (channels ==1) {
        status = nppiFilterSharpen_8u_C1R(d_src, width, d_dst, width, oSizeROI, NPP_MASK_SIZE_5_X_5);
    } else if (channels == 3) {
        status = nppiFilterSharpen_8u_C3R(d_src,width*3, d_dst, width*3, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }
    else if (channels == 4) {
        status = nppiFilterSharpen_8u_AC4R(d_src, width*4, d_dst, width*4, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }

    checkNppError(status, "Sharpen Filter Failed!");
}

void applySobelEdgeDetect(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels) {
    NppiSize oSizeROI = {width, height};
    NppiPoint oAnchor = {2,2};
    NppStatus status;

    if (channels ==1) {
        status = nppiFilterSobel_8u_C1R(d_src, width, d_dst, width, oSizeROI, NPP_MASK_SIZE_5_X_5);
    } else if (channels == 3) {
        status = nppiFilterSobel_8u_C3R(d_src,width*3, d_dst, width*3, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }
    else if (channels == 4) {
        status = nppiFilterSobel_8u_AC4R(d_src, width*4, d_dst, width*4, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }

    checkNppError(status, "Sobel Filter Failed!");
}

void applyMedianFilter(unsigned char* d_src, unsigned char* d_dst, int width, int height, int channels) {
    NppiSize oSizeROI = {width, height};
    NppiPoint oAnchor = {2,2};
    NppStatus status;

    if (channels ==1) {
        status = nppiFilterMedian_8u_C1R(d_src, width, d_dst, width, oSizeROI, NPP_MASK_SIZE_5_X_5);
    } else if (channels == 3) {
        status = nppiFilterMedian_8u_C3R(d_src,width*3, d_dst, width*3, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }
    else if (channels == 4) {
        status = nppiFilterMedian_8u_AC4R(d_src, width*4, d_dst, width*4, oSizeROI, NPP_MASK_SIZE_5_X_5);
    }

    checkNppError(status, "Median Filter Failed!");
}

void applyFilter(Image* img, FilterType Filter) {
    size_t imageSize = img->width * img->height * img->channels;

    unsgined char *d_src, *d_dst;

    checkCudaError(cudaMalloc(&d_src,imageSize), "Failed to allocate device source memory");
    checkCudaError(cudaMalloc(&d_dst,imageSize),"Failed to allocate device destination memory");

    checkCudaError(cudaMemCpy(d_src,img->stat, imageSize, cudaMemcpyHostToDevice), "Failed to copy image to device");

    switch(filter) {

        case FILTER_GAUSSIAN_BLUR:
            applyGaussianBlur(d_src, d_dst, img->width, img->height, img->channels);
            break;
        case FILTER_BOX_BLUR:
            applyBoxBlur(d_src,d_dst, img->width, img->height,img->channels);
            break;
        case FILTER_SHARPEN:
            applySharpen(d_src,d_dst,img->width, img->height, img->channels);
            break;
        case FILTER_EDGE_DETECT_SOBEL:
            applySobelEdgeDetect(d_src, d_dst, img->width, img->height, img->channels);
            break;
        case FILTER_MEDIAN:
            applyMedianFilter(d_src, d_dst, img->width, img->height, img->channels);
            break;
    }

    checkCudaError(cudaMemCpy(img->data, d_dst, imageSize, cudaMemcpyDeviceToHost), "Failed to copy result from device");

    cudaFree(d_src);
    cudaFree(d_dst);
}

void processImageBatch(Image** images, int numImages, FilterType filter) {

    printf("Processing %d images with %s filter...\n", numImages, getFilterName(filter));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);

    for (int i = 0; i < numImages; i++) {
        if (images[i]) {
            applyFilter(images[i],filter);
            printProgress(i+1,numImages);
        }
    }

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    printf("\n");

    printf("Total Processing time: %.2f ms\n", milliseconds);
    printf("Average time per image: %.2f ms\n", milliseconds/numImages);
    printf("Throughput: %.2f images/second\n", (numImages * 1000.0f)/milliseconds);

    cudaEventDestroy(start);
    cudaEventDestory(stop);
}

int main(int argc, char** argv) {

    if (argc < 3) {
        printf("Usage: %s <input_directory> <output_directory> [filter_type]\n",argv[0]);
        printf("Filter types: \n");
        printf(" 0 - Gaussian Blur (default)\n");
        printf(" 1 - Box Blur \n");
        printf(" 2 - Sharpen \n");
        printf(" 3 - Sobel Edge Detection\n");
        printf(" 4 - Median Filter\n");
        return 1;        
    }

    const char* inputDir = argv[1];
    const char* outputDir  = argv[2];

    FilterType filter = (argc >=4) ? (FilterType)atoi(argv[3]) : FILTER_GAUSSIAN_BLUR;
    
    printf("=== GPU Image Processor === \n");
    printf("Input Direcotry : %s\n", inputDir);
    printf("Output Directory; %s\n", outputDir);
    printf("Filter: %s\n\n", getFilterName(filter));

    const int MAX_IMAGES = 1000;
    Image** images = (Image**)malloc(MAX_IMAGES * sizeof(Image*));

    int numImages = 0;

    char filename[512];

    for(int i = 0; i < MAX_IMAGES ** numImages < MAX_IMAGES; i++) {
        snprintf(filename, sizeof(filename), "%s/input_%0.3d.png", inputDir,i);

        Image* img = loadImage(filename);

        if (img) {
            images[numImages++] = img;
        }
        else {
            snprintf(filename, sizeof(filename), "%s/input_%0.3d.jpg",inputDir,i);
            img = loadImage(filename);
            if (img) {
                images[numImages++] = img;
            }
            else {
                break;
            }
        }
    }

    if (numImages == 0) {

            printf("No images found in$s\n", inputDir);
            printf("Looking for files matching pattern: input_NNN.png or input_NNN.jpg\n");
            free(images);
            return 1;
    }

    printf("Loaded %d images \n\n", numImages);

    processImageBatch(images, numImages, filter);

    printf("\n Saving processed Images... \n");

    for(int i = 0; i < numImages; i++) {
        snprintf(filename, sizeof(filename), "%s/output_%03d.png", outputDir, i);
        saveImage(filename, images[i]);
        printProgress(i+1,numImages);
    }

    printf("\n");

    for(int i = 0; i < numImages; i++) {
        freeImage(images[i]);
    }

    free(images);

    printf("\n Processing complete!\n");

    return 0;
}