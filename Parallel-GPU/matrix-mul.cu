// GPU with parallelization version
// Parallelization is implemented with CUDA

#include <iostream>
#include <cstdlib>
#include <ctime>
#include <cmath>
#include <cuda.h>
using namespace std;

// __global__ means the function runs on GPU, and called from CPU (in this case the function is called by main(), which runs on CPU)
__global__
void multiply_matrix(int n, int* matrixA, int* matrixB, int* matrix_res) {
    int line_num = blockIdx.x * blockDim.x + threadIdx.x;
    if (line_num < n) {
        for (int i = 0; i < n; i ++) {
            for (int j = 0; j < n; j ++) {
                //
                // matrix_res[line_num][i] = sum(j) matrixA[line_num][j] * matrixB[j][i]
                //
                matrix_res[line_num * n + i] += matrixA[line_num * n + j] * matrixB[j * n + i];
            }
        }
    }
}

int main(int argc, char const *argv[])
{   
    if (argc < 2) {
        cout << "Wrong number of arguments!!" << endl;
        return -1;
    }
    int n = atoi(argv[1]);
    //
    // We will next generate two matrices both of size n*n with random int number with range [1, 512]
    // We will also generate a zero matrix to store the result of multiplication
    // For now, you do not need to understand the "new" expression
    //

    int *matrixA = new int[n*n]; 
    int *matrixB = new int[n*n];
    int *matrix_res = new int[n*n];
    int *dMatrixA;
    int *dMatrixB;
    int *dMatrix_res;
    // Notice that we use different index method
    // We store all the data of the matrix in one row, so matrix[i * n + j] is previous matrix[i][j]
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            matrixA[i * n + j] = (rand() % 512) + 1;
            matrixB[i * n + j] = (rand() % 512) + 1;
            matrix_res[i * n + j] = 0;
        }
    }

    //
    // We will next multiply these two matrices (matrixA * matrixB) and count the time
    // The result of multiplication will be stored in matrix_res
    //

    clock_t start = clock();

    //
    // Since CPU and GPU use different memory, we need to allocate memory on GPU
    // We use id dMatrix to mean Matrix stored in device
    //

    cudaMallocManaged(&dMatrixA, n * n * sizeof(int));
    cudaMallocManaged(&dMatrixB, n * n * sizeof(int));
    cudaMallocManaged(&dMatrix_res, n * n * sizeof(int));

    cudaMemcpy(dMatrixA, matrixA, n * n * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dMatrixB, matrixB, n * n * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dMatrix_res, matrix_res, n * n * sizeof(int), cudaMemcpyHostToDevice);

    //
    // The code below call the function run on GPU and wait it to finish
    // Each thread will calculate one line
    //

    multiply_matrix<<< ((n + 255) / 256) , 256>>> (n, dMatrixA, dMatrixB, dMatrix_res);
    cudaDeviceSynchronize();

    
    cudaMemcpy(matrix_res, dMatrix_res, n * n * sizeof(int), cudaMemcpyDeviceToHost);
    cout << "It takes " << (clock() - start) / (double) CLOCKS_PER_SEC  << " seconds to multiply two matrices with size " << n << " * " << n << endl;
    //
    // Clean up the memory, you do not need to understand this part
    //
    
    cudaFree(dMatrixA);
    cudaFree(dMatrixB);
    cudaFree(dMatrix_res);
    delete [] matrixA;
    delete [] matrixB;
    delete [] matrix_res;

    return 0;
}

