#define _CRT_SECURE_NO_WARNINGS //fopen ���� �ذ�
#include <stdio.h> // FILE*, fseek, fread �� ���
#define DATA_OFFSET_OFFSET 0x000A
#define WIDTH_OFFSET 0x0012
#define HEIGHT_OFFSET 0x0016
#define BITS_PER_PIXEL_OFFSET 0x001C
#define HEADER_SIZE 14
#define INFO_HEADER_SIZE 40
#define NO_COMPRESION 0
#define MAX_NUMBER_OF_COLORS 0
#define ALL_COLORS_REQUIRED 0


typedef unsigned int int32;
typedef short int16;
typedef unsigned char byte;

void ReadImage(const char* fileName, const char* outfileName, byte** pixels, int32* width, int32* height, int32* bytesPerPixel, FILE*& imageFile, FILE*& OUT) // (�����̸�, �ȼ��� ���� �迭, ���α��� ���� ���� ��ġ, ���α��� ���� ���� ��ġ, �ȼ��� ����Ʈ �� ���� ��ġ
{
    
    imageFile = fopen(fileName, "rb");//������ ���̳ʸ� ���� ����
    int32 dataOffset; //������ ���� ��ġ �ּҰ� 
    int32 LookUpTable=0; 
    fseek(imageFile, HEADER_SIZE + INFO_HEADER_SIZE-8, SEEK_SET); //fseek(���Ϻ���,�̵�byte,������ġ)
    fread(&LookUpTable, 4, 1, imageFile); //fread(�޸��ּ�,ũ��,����,���Ϻ���)
    fseek(imageFile, 0, SEEK_SET);

    OUT = fopen(outfileName, "wb");

    int header = 0;
    if (LookUpTable)
        header = HEADER_SIZE + INFO_HEADER_SIZE + 1024;
    else
        header = HEADER_SIZE + INFO_HEADER_SIZE;
    for (int i = 0; i < header; i++) // ���� BMP ���Ͽ��� ����� ���̺� �̾Ƽ� ���ο� BMP ������ ����� ����
    {
        int get = getc(imageFile);
        putc(get, OUT);
    }

    fseek(imageFile, DATA_OFFSET_OFFSET, SEEK_SET); //fseek(���Ϻ���,�̵�byte,������ġ)
    fread(&dataOffset, 4, 1, imageFile); //fread(�޸��ּ�,ũ��,����,���Ϻ���)
    fseek(imageFile, WIDTH_OFFSET, SEEK_SET);
    fread(width, 4, 1, imageFile);
    fseek(imageFile, HEIGHT_OFFSET, SEEK_SET);
    fread(height, 4, 1, imageFile);
    int16 bitsPerPixel;
    fseek(imageFile, BITS_PER_PIXEL_OFFSET, SEEK_SET);
    fread(&bitsPerPixel, 2, 1, imageFile);
    *bytesPerPixel = ((int32)bitsPerPixel) / 8; //3 bytes per pixel when color, 1 byte per pixel when grayscale


    int paddedRowSize = (int)(4 * (float)(*width) / 4.0f) * (*bytesPerPixel); //4�� ����� ������ִ� ����
    int unpaddedRowSize = (*width) * (*bytesPerPixel);
    int totalSize = unpaddedRowSize * (*height);

    *pixels = new byte[totalSize];
    int i = 0;
    byte* currentRowPointer = *pixels + ((*height - 1) * unpaddedRowSize);
    for (i = 0; i < *height; i++)
    {
        fseek(imageFile, dataOffset + (i * paddedRowSize), SEEK_SET);       //data�� padding�Ǿ� �ִ�.
        fread(currentRowPointer, 1, unpaddedRowSize, imageFile);            //read data�� unpadding ��ŭ�� ����
        currentRowPointer -= unpaddedRowSize;
    }

    fclose(imageFile);

}

void WriteImage(byte* pixels, int32 width, int32 height, int32 bytesPerPixel, FILE*& outputFile, char version)
{
    int paddedRowSize = (int)(4 * (float)width / 4.0f) * bytesPerPixel;
    int unpaddedRowSize = width * bytesPerPixel;
    //blue
    if (version == 'B') {
        for (int i = 0; i < height; i++)
        {
            int pixelOffset = ((height - i) - 1) * unpaddedRowSize;
            for (int j = 0; j < paddedRowSize / 3; j++) {
                int rowOffset = pixelOffset + 3 * j;
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
                fwrite("0", 1, 1, outputFile);
                fwrite("0", 1, 1, outputFile);
            }
        }
        fclose(outputFile);
    }
    //green
    else if (version == 'G') {
        for (int i = 0; i < height; i++)
        {
            int pixelOffset = ((height - i) - 1) * unpaddedRowSize;
            for (int j = 0; j < paddedRowSize / 3; j++) {
                int rowOffset = pixelOffset + 3 * j + 1;
                fwrite("0", 1, 1, outputFile);
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
                fwrite("0", 1, 1, outputFile);
            }
        }
        fclose(outputFile);
    }
    //red
    else if (version == 'R') {
        for (int i = 0; i < height; i++)
        {
            int pixelOffset = ((height - i) - 1) * unpaddedRowSize;
            for (int j = 0; j < paddedRowSize / 3; j++) {
                int rowOffset = pixelOffset + 3 * j + 2;
                fwrite("0", 1, 1, outputFile);
                fwrite("0", 1, 1, outputFile);
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
            }
        }
        fclose(outputFile);
    }
    //grayblue
    else if (version == 'Q') {
        for (int i = 0; i < height; i++)
        {
            int pixelOffset = ((height - i) - 1) * unpaddedRowSize;
            for (int j = 0; j < paddedRowSize / 3; j++) {
                int rowOffset = pixelOffset + 3 * j;
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
            }
        }
        fclose(outputFile);
    }
    //graygreen
    else if (version == 'W') {
        for (int i = 0; i < height; i++)
        {
            int pixelOffset = ((height - i) - 1) * unpaddedRowSize;
            for (int j = 0; j < paddedRowSize / 3; j++) {
                int rowOffset = pixelOffset + 3 * j + 1;
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
            }
        }
        fclose(outputFile);
    }
    //grayred
    else if (version == 'E') {
        for (int i = 0; i < height; i++)
        {
            int pixelOffset = ((height - i) - 1) * unpaddedRowSize;
            for (int j = 0; j < paddedRowSize / 3; j++) {
                int rowOffset = pixelOffset + 3 * j + 2;
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
                fwrite(&pixels[rowOffset], 1, 1, outputFile);
            }
        }
        fclose(outputFile);
    }
    //default
    else {
        for (int i = 0; i < height; i++)
        {
            int pixelOffset = ((height - i) - 1) * unpaddedRowSize;
            if (pixelOffset < 10000)
                fwrite(&pixels[0], 1, paddedRowSize, outputFile);
            else
                fwrite(&pixels[pixelOffset], 1, paddedRowSize, outputFile);
        }
    }
    
}

int main()
{
    byte* pixels;
    int32 width;
    int32 height;
    int32 bytesPerPixel;
    FILE* imageFile; 
    FILE* outputFile;
    ReadImage("Lion.bmp", "Lion_out.bmp", &pixels, &width, &height, &bytesPerPixel, imageFile, outputFile);
    WriteImage(pixels, width, height, bytesPerPixel, outputFile,'B');
    //WriteImage(pixels, width, height, bytesPerPixel, outputFile, 'G');
    //WriteImage(pixels, width, height, bytesPerPixel, outputFile, 'R');
    //WriteImage(pixels, width, height, bytesPerPixel, outputFile, 'Q');
    //WriteImage(pixels, width, height, bytesPerPixel, outputFile, 'W');
    //WriteImage(pixels, width, height, bytesPerPixel, outputFile, 'E');
    //WriteImage(pixels, width, height, bytesPerPixel, outputFile, ' ');
    delete[] pixels;

    return 0;
}