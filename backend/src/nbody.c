/*
 * N-Body Simulation - Parallel Implementation
 * 
 * Demonstrates: Fine-grained Parallelism, Computational Physics, O(N^2) Complexity
 * Complexity: O(N^2)
 * 
 * Parallelization Strategy:
 * - Parallelize force calculation loop
 * - Each thread computes forces for subset of bodies
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>
#include "../include/common_utils.h"

typedef struct {
    double x, y, z;
    double vx, vy, vz;
    double mass;
} Body;

void compute_forces(Body* bodies, int N, int threads) {
    const double G = 6.67430e-11;
    const double softening = 1e-9;
    
    omp_set_num_threads(threads);

    #pragma omp parallel for schedule(dynamic)
    for (int i = 0; i < N; i++) {
        double fx = 0.0, fy = 0.0, fz = 0.0;

        for (int j = 0; j < N; j++) {
            if (i != j) {
                double dx = bodies[j].x - bodies[i].x;
                double dy = bodies[j].y - bodies[i].y;
                double dz = bodies[j].z - bodies[i].z;

                double dist_sq = dx*dx + dy*dy + dz*dz + softening;
                double dist = sqrt(dist_sq);
                double force = G * bodies[i].mass * bodies[j].mass / dist_sq;

                fx += force * dx / dist;
                fy += force * dy / dist;
                fz += force * dz / dist;
            }
        }

        // Update velocities (simplified)
        bodies[i].vx += fx / bodies[i].mass;
        bodies[i].vy += fy / bodies[i].mass;
        bodies[i].vz += fz / bodies[i].mass;
    }
}

int main(int argc, char* argv[]) {
    int N, threads;
    
    if (!validate_args(argc, argv, &N, &threads, argv[0], "N-Body Simulation")) {
        return 1;
    }

    Body* bodies = (Body*)safe_malloc(N * sizeof(Body));

    // Initialize with random positions and masses
    for (int i = 0; i < N; i++) {
        bodies[i].x = (double)rand() / RAND_MAX;
        bodies[i].y = (double)rand() / RAND_MAX;
        bodies[i].z = (double)rand() / RAND_MAX;
        bodies[i].vx = bodies[i].vy = bodies[i].vz = 0.0;
        bodies[i].mass = 1.0;
    }

    double start = omp_get_wtime();
    compute_forces(bodies, N, threads);
    double end = omp_get_wtime();

    double elapsed = end - start;
    print_json_result("nbody", threads, N, elapsed);

    free(bodies);

    return 0;
}
