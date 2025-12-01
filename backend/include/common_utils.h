/*
 * Common utilities for parallel architecture workbench
 * Shared functionality across all C benchmarks
 */

#ifndef COMMON_UTILS_H
#define COMMON_UTILS_H

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

/**
 * Print usage information and exit
 */
void print_usage(const char* program_name, const char* algo_name) {
    fprintf(stderr, "Usage: %s <problem_size> <num_threads>\n", program_name);
    fprintf(stderr, "Example: %s 1024 8\n", program_name);
    fprintf(stderr, "\nAlgorithm: %s\n", algo_name);
    exit(1);
}

/**
 * Print results in JSON format for Flutter parsing
 */
void print_json_result(const char* algo, int threads, int size, double time_seconds) {
    printf("{\"algo\": \"%s\", \"threads\": %d, \"size\": %d, \"time\": %.6f}\n", 
           algo, threads, size, time_seconds);
    fflush(stdout);
}

/**
 * Validate command line arguments
 * Returns 1 if valid, 0 if invalid
 */
int validate_args(int argc, char* argv[], int* size, int* threads, const char* prog_name, const char* algo_name) {
    if (argc != 3) {
        print_usage(prog_name, algo_name);
        return 0;
    }

    *size = atoi(argv[1]);
    *threads = atoi(argv[2]);

    if (*size <= 0) {
        fprintf(stderr, "Error: Problem size must be positive\n");
        return 0;
    }

    if (*threads <= 0) {
        fprintf(stderr, "Error: Thread count must be positive\n");
        return 0;
    }

    return 1;
}

/**
 * Allocate memory with error checking
 */
void* safe_malloc(size_t size) {
    void* ptr = malloc(size);
    if (ptr == NULL) {
        fprintf(stderr, "Error: Failed to allocate %zu bytes\n", size);
        exit(1);
    }
    return ptr;
}

/**
 * Calculate and display parallel overhead
 */
void display_overhead_info(double serial_time, double parallel_time, int threads) {
    double speedup = serial_time / parallel_time;
    double efficiency = speedup / threads;
    double overhead = (threads * parallel_time - serial_time) / serial_time * 100;

    fprintf(stderr, "Speedup: %.2fx | Efficiency: %.2f%% | Overhead: %.2f%%\n", 
            speedup, efficiency * 100, overhead);
}

#endif /* COMMON_UTILS_H */
