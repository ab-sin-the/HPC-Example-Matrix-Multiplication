// CPU with parallelization version
// Parallelization is implemented with OpenMP

#include <iostream>
#include <cstdlib>
#include <ctime>
#include <omp.h>
using namespace std;

int main(int argc, char const *argv[])
{
    int n;
    cout << "Please input the number of columns/rows of the matrix: " << endl;
    cout << "(Input a number n will calculate the multiplication of two matrices both of size n * n)" << endl;
    cin >> n;

    //
    // We will next generate two matrices both of size n*n with random int number with range [1, 512]
    // We will also generate a zero matrix to store the result of multiplication
    // For now, you do not need to understand the "new" expression
    //

    int **matrixA = new int*[n]; 
    int **matrixB = new int*[n];
    int **matrix_res = new int*[n];

    for (int i = 0; i < n; i++) {
        matrixA[i] = new int[n];
        matrixB[i] = new int[n];
        matrix_res[i] = new int[n];
        for (int j = 0; j < n; j++) {
            matrixA[i][j] = (rand() % 512) + 1;
            matrixB[i][j] = (rand() % 512) + 1;
            matrix_res[i][j] = 0;
        }
    }

    //
    // We will next multiply these two matrices (matrixA * matrixB) and count the time
    // The result of multiplication will be stored in matrix_res
    // The process will be reported each report_line lines, you can change the number below
    //

    int report_line = 10;
    time_t start_actual_time = time(NULL);

    //
    // Notice the difference here
    //
    
    #pragma omp parallel for 
    for (int i = 0; i < n; i++) {
        int thread_num = omp_get_thread_num();
        if (i % report_line == 0) {
            cout << "Thread " << thread_num  << " reaches line " << i << endl;
        }
        for (int j = 0; j < n; j++) {

            //
            // Calculate matrix_res[i][j] = sum(k) matrixA[i][k]*matrixB[k][j]
            //

            for (int k = 0; k < n; k++) {
                matrix_res[i][j] = matrix_res[i][j] + matrixA[i][k] * matrixB[k][j];
            }
        }
    }    

    double duration_actual = time(NULL) - start_actual_time;

    cout << "It takes " << duration_actual << " seconds actual time to multiply two matrices with size " << n << " * " << n << endl;
    
    //
    // Clean up the memory, you do not need to understand this part
    //
    
    for (int i = 0; i < n; i++) {
        delete [] matrixA[i];
        delete [] matrixB[i];
        delete [] matrix_res[i];
    }
    
    delete [] matrixA;
    delete [] matrixB;
    delete [] matrix_res;

    return 0;
}

