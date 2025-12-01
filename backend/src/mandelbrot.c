/*
 * Mandelbrot Set - Parallel Implementation
 * 
 * Demonstrates: Load Imbalance, Dynamic Scheduling
 * Complexity: O(N^2 × k) where k is iterations per point
 * 
 * Parallelization Strategy:
 * - Use dynamic scheduling to handle load imbalance
 * - Some regions converge quickly, others slowly
 */

#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "../include/common_utils.h"

#define MAX_ITER 1000

int mandelbrot_iterations(double cx, double cy) {
    double x = 0.0, y = 0.0;
    int iter = 0;

    while (x*x + y*y <= 4.0 && iter < MAX_ITER) {
        double temp = x*x - y*y + cx;
        y = 2.0*x*y + cy;
        x = temp;
        iter++;
    }

    return iter;
}

void compute_mandelbrot(int* result, int width, int height, int threads) {
    omp_set_num_threads(threads);

    // Map pixel coordinates to complex plane
    double x_min = -2.5, x_max = 1.0;
    double y_min = -1.0, y_max = 1.0;

    #pragma omp parallel for schedule(dynamic, 16) collapse(2)
    for (int py = 0; py < height; py++) {
        for (int px = 0; px < width; px++) {
            double cx = x_min + (x_max - x_min) * px / width;
            double cy = y_min + (y_max - y_min) * py / height;
            
            result[py * width + px] = mandelbrot_iterations(cx, cy);
        }
    }
}

int main(int argc, char* argv[]) {
    int size, threads;
    
    if (!validate_args(argc, argv, &size, &threads, argv[0], "Mandelbrot Set")) {
        return 1;
    }

    int width = size;
    int height = size;
    
    int* result = (int*)safe_malloc(width * height * sizeof(int));

    double start = omp_get_wtime();
    compute_mandelbrot(result, width, height, threads);
    double end = omp_get_wtime();

    double elapsed = end - start;
    print_json_result("mandelbrot", threads, size, elapsed);

    free(result);

    return 0;
}
