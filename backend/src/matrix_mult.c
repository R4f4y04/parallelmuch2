/*
 * Matrix Multiplication - Parallel Implementation
 * 
 * Demonstrates: Cache Coherence, Memory Bound Operations, False Sharing
 * Complexity: O(N^3)
 * 
 * Parallelization Strategy:
 * - Parallelize outer loop (rows of result matrix)
 * - Each thread computes independent rows
 * - Watch for false sharing on adjacent row writes
 */

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "../include/common_utils.h"

void matrix_multiply(double* A, double* B, double* C, int N, int threads) {
    omp_set_num_threads(threads);

    #pragma omp parallel for schedule(static)
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            double sum = 0.0;
            for (int k = 0; k < N; k++) {
                sum += A[i * N + k] * B[k * N + j];
            }
            C[i * N + j] = sum;
        }
    }
}

void initialize_matrix(double* M, int N, double value) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            M[i * N + j] = value;
        }
    }
}

int main(int argc, char* argv[]) {
    int N, threads;
    
    if (!validate_args(argc, argv, &N, &threads, argv[0], "Matrix Multiplication")) {
        return 1;
    }

    // Allocate matrices on heap (stack size is limited)
    size_t matrix_size = (size_t)N * N * sizeof(double);
    double* A = (double*)safe_malloc(matrix_size);
    double* B = (double*)safe_malloc(matrix_size);
    double* C = (double*)safe_malloc(matrix_size);

    // Initialize with simple values
    initialize_matrix(A, N, 1.0);
    initialize_matrix(B, N, 2.0);

    // Benchmark execution
    double start = omp_get_wtime();
    matrix_multiply(A, B, C, N, threads);
    double end = omp_get_wtime();

    double elapsed = end - start;

    // Output JSON for Flutter
    print_json_result("matrix_mult", threads, N, elapsed);

    // Cleanup
    free(A);
    free(B);
    free(C);

    return 0;
}
