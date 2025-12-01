/*
 * Monte Carlo Pi Estimation - Parallel Implementation
 * 
 * Demonstrates: Embarrassingly Parallel, Atomic Operations, Reduction
 * Complexity: O(N)
 * 
 * Parallelization Strategy:
 * - Each thread generates random points independently
 * - Use reduction clause to aggregate hits
 * - Should show near-perfect linear speedup
 */

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>
#include "../include/common_utils.h"

double estimate_pi(long long N, int threads) {
    long long total_hits = 0;
    omp_set_num_threads(threads);

    #pragma omp parallel
    {
        // Thread-safe random number generation for Windows
        unsigned int seed = (unsigned int)(time(NULL) + omp_get_thread_num() * 1000);
        long long local_hits = 0;

        #pragma omp for
        for (long long i = 0; i < N; i++) {
            // Simple LCG (Linear Congruential Generator) for thread safety
            seed = seed * 1103515245 + 12345;
            double x = (double)(seed % 1000000) / 1000000.0;
            
            seed = seed * 1103515245 + 12345;
            double y = (double)(seed % 1000000) / 1000000.0;
            
            if (x * x + y * y <= 1.0) {
                local_hits++;
            }
        }

        #pragma omp atomic
        total_hits += local_hits;
    }

    return 4.0 * total_hits / N;
}

int main(int argc, char* argv[]) {
    int size, threads;
    
    if (!validate_args(argc, argv, &size, &threads, argv[0], "Monte Carlo Pi Estimation")) {
        return 1;
    }

    long long N = (long long)size;

    double start = omp_get_wtime();
    double pi = estimate_pi(N, threads);
    double end = omp_get_wtime();

    double elapsed = end - start;
    
    // Print result
    print_json_result("monte_carlo", threads, (int)N, elapsed);
    
    // Debug: print estimated pi to stderr
    fprintf(stderr, "Estimated π: %.6f (error: %.6f)\n", pi, pi - 3.141592653589793);

    return 0;
}
