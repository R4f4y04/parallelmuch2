/*
 * Merge Sort - Parallel Implementation
 * 
 * Demonstrates: Recursive Parallelism, Task-based Parallelism, Memory Bandwidth
 * Complexity: O(N log N)
 * 
 * Parallelization Strategy:
 * - Use OpenMP tasks for recursive divide-and-conquer
 * - Stop creating tasks below a threshold to avoid overhead
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>
#include "../include/common_utils.h"

#define TASK_THRESHOLD 10000

void merge(int* arr, int* temp, int left, int mid, int right) {
    int i = left, j = mid + 1, k = left;

    while (i <= mid && j <= right) {
        if (arr[i] <= arr[j]) {
            temp[k++] = arr[i++];
        } else {
            temp[k++] = arr[j++];
        }
    }

    while (i <= mid) temp[k++] = arr[i++];
    while (j <= right) temp[k++] = arr[j++];

    for (i = left; i <= right; i++) {
        arr[i] = temp[i];
    }
}

void merge_sort_parallel(int* arr, int* temp, int left, int right) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        int size = right - left + 1;

        if (size > TASK_THRESHOLD) {
            // Create tasks for large subarrays
            #pragma omp task
            merge_sort_parallel(arr, temp, left, mid);
            
            #pragma omp task
            merge_sort_parallel(arr, temp, mid + 1, right);
            
            #pragma omp taskwait
        } else {
            // Serial execution for small subarrays
            merge_sort_parallel(arr, temp, left, mid);
            merge_sort_parallel(arr, temp, mid + 1, right);
        }

        merge(arr, temp, left, mid, right);
    }
}

void merge_sort(int* arr, int* temp, int N, int threads) {
    omp_set_num_threads(threads);

    #pragma omp parallel
    {
        #pragma omp single
        {
            merge_sort_parallel(arr, temp, 0, N - 1);
        }
    }
}

int main(int argc, char* argv[]) {
    int N, threads;
    
    if (!validate_args(argc, argv, &N, &threads, argv[0], "Merge Sort")) {
        return 1;
    }

    int* arr = (int*)safe_malloc(N * sizeof(int));
    int* temp = (int*)safe_malloc(N * sizeof(int));

    // Initialize with random values
    for (int i = 0; i < N; i++) {
        arr[i] = rand() % 1000;
    }

    double start = omp_get_wtime();
    merge_sort(arr, temp, N, threads);
    double end = omp_get_wtime();

    double elapsed = end - start;
    print_json_result("merge_sort", threads, N, elapsed);

    free(arr);
    free(temp);

    return 0;
}
