import 'package:flutter/material.dart';
import '../models/models.dart';

/// Service providing code snippets for all parallel algorithms.
///
/// Contains side-by-side serial and parallel implementations with
/// educational annotations explaining the transformations.
class CodeSnippetService {
  /// Get code snippet for a specific algorithm.
  static CodeSnippet? getCodeSnippet(String algoId) {
    switch (algoId) {
      case 'matrix_mult':
        return _generateMatrixMultCode();
      case 'merge_sort':
        return _generateMergeSortCode();
      case 'monte_carlo':
        return _generateMonteCarloCode();
      case 'nbody':
        return _generateNBodyCode();
      case 'mandelbrot':
        return _generateMandelbrotCode();
      default:
        return null;
    }
  }

  /// Matrix Multiplication code snippet.
  static CodeSnippet _generateMatrixMultCode() {
    const serialCode = '''// Sequential Matrix Multiplication
// Time Complexity: O(N³)
// Cache Access: Sequential, predictable

void matrix_mult_serial(double* A, double* B, 
                       double* C, int N) {
    
    // Iterate through rows
    for (int i = 0; i < N; i++) {
        
        // Iterate through columns
        for (int j = 0; j < N; j++) {
            double sum = 0.0;
            
            // Compute dot product
            for (int k = 0; k < N; k++) {
                sum += A[i*N + k] * B[k*N + j];
            }
            
            // Store result
            C[i*N + j] = sum;
        }
    }
}

// Single-threaded execution
// Good cache locality
// Predictable memory access pattern''';

    const parallelCode = '''// Parallel Matrix Multiplication with OpenMP
// Expected Speedup: ~6-8x on 8 cores
// Memory Bound: Limited by bandwidth

void matrix_mult_parallel(double* A, double* B, 
                         double* C, int N, int threads) {
    omp_set_num_threads(threads);
    
    // PARALLELIZATION: Distribute rows across threads
    #pragma omp parallel for schedule(static)
    for (int i = 0; i < N; i++) {
        
        // Each thread processes different rows
        for (int j = 0; j < N; j++) {
            double sum = 0.0;  // Thread-local variable
            
            // Inner loop remains serial per thread
            for (int k = 0; k < N; k++) {
                sum += A[i*N + k] * B[k*N + j];
            }
            
            // WARNING: Adjacent writes may share cache lines
            C[i*N + j] = sum;
        }
    }
}

// Multi-threaded: Each thread handles subset of rows
// Static scheduling: Uniform workload distribution
// False sharing risk: Adjacent C[i][j] writes''';

    return CodeSnippet(
      algoId: 'matrix_mult',
      serialCode: serialCode,
      parallelCode: parallelCode,
      serialComplexity: 'O(N³)',
      parallelSpeedupPotential: '~6-8x on 8 cores',
      annotations: [
        CodeAnnotation(
          title: 'Parallelization Strategy',
          description:
              'The outer loop (rows) is parallelized with #pragma omp parallel for. '
              'Each thread processes independent rows, avoiding data races. '
              'Static scheduling distributes rows evenly across threads.',
          parallelLineStart: 8,
          type: AnnotationType.optimization,
          icon: Icons.speed,
        ),
        CodeAnnotation(
          title: 'False Sharing Risk',
          description:
              'Adjacent elements in C matrix may reside on the same cache line (64 bytes). '
              'When multiple threads write to adjacent rows, the cache line ping-pongs between cores, '
              'causing performance degradation. Solution: Pad arrays or use blocking.',
          parallelLineStart: 20,
          type: AnnotationType.warning,
          icon: Icons.warning_amber,
        ),
        CodeAnnotation(
          title: 'Memory Bandwidth Bottleneck',
          description:
              'Matrix multiplication is memory-bound for large N. Each element requires '
              '2N memory reads and 1 write. With 8+ threads, memory bandwidth becomes the limiting factor, '
              'explaining why speedup plateaus below linear scaling.',
          type: AnnotationType.performance,
          icon: Icons.memory,
        ),
        CodeAnnotation(
          title: 'Static vs Dynamic Scheduling',
          description:
              'schedule(static) divides iterations equally at compile time. '
              'This is optimal for matrix multiplication because all rows have uniform workload (N² operations). '
              'Dynamic scheduling would add unnecessary overhead.',
          parallelLineStart: 8,
          type: AnnotationType.concept,
          icon: Icons.lightbulb,
        ),
      ],
    );
  }

  /// Merge Sort code snippet.
  static CodeSnippet _generateMergeSortCode() {
    const serialCode = '''// Sequential Merge Sort
// Time Complexity: O(N log N)
// Space Complexity: O(N) for temp array

void merge_sort_serial(int* arr, int* temp, 
                       int left, int right) {
    
    if (left < right) {
        int mid = left + (right - left) / 2;
        
        // Recursively sort left half
        merge_sort_serial(arr, temp, left, mid);
        
        // Recursively sort right half
        merge_sort_serial(arr, temp, mid + 1, right);
        
        // Merge sorted halves
        merge(arr, temp, left, mid, right);
    }
}

// Recursive divide-and-conquer
// Sequential recursion
// No parallelization overhead''';

    const parallelCode = '''// Parallel Merge Sort with OpenMP Tasks
// Expected Speedup: ~4-6x on 8 cores
// Recursive task parallelism

#define TASK_THRESHOLD 10000

void merge_sort_parallel(int* arr, int* temp,
                        int left, int right) {
    
    if (left < right) {
        int mid = left + (right - left) / 2;
        int size = right - left + 1;
        
        // PARALLELIZATION: Task-based recursion
        if (size > TASK_THRESHOLD) {
            #pragma omp task
            merge_sort_parallel(arr, temp, left, mid);
            
            #pragma omp task
            merge_sort_parallel(arr, temp, mid + 1, right);
            
            // Wait for both tasks to complete
            #pragma omp taskwait
        } else {
            // Serial execution for small arrays
            merge_sort_serial(arr, temp, left, mid);
            merge_sort_serial(arr, temp, mid + 1, right);
        }
        
        merge(arr, temp, left, mid, right);
    }
}

// Task-based parallelism: Dynamic work distribution
// Threshold: Avoid overhead on small subarrays''';

    return CodeSnippet(
      algoId: 'merge_sort',
      serialCode: serialCode,
      parallelCode: parallelCode,
      serialComplexity: 'O(N log N)',
      parallelSpeedupPotential: '~4-6x on 8 cores',
      annotations: [
        CodeAnnotation(
          title: 'Task-Based Parallelism',
          description:
              '#pragma omp task creates asynchronous tasks that can run on any available thread. '
              'This is ideal for recursive algorithms where the amount of work varies. '
              'Tasks are more flexible than parallel for loops.',
          parallelLineStart: 16,
          type: AnnotationType.concept,
          icon: Icons.account_tree,
        ),
        CodeAnnotation(
          title: 'Task Threshold Optimization',
          description:
              'Creating tasks has overhead (~1-10μs per task). For small subarrays (<10,000 elements), '
              'the overhead exceeds the benefit. The threshold prevents creating millions of tiny tasks '
              'that would overwhelm the runtime system.',
          parallelLineStart: 13,
          type: AnnotationType.optimization,
          icon: Icons.speed,
        ),
        CodeAnnotation(
          title: 'Task Synchronization',
          description:
              '#pragma omp taskwait blocks until all child tasks complete. '
              'This ensures both halves are sorted before merging. Without taskwait, '
              'the merge would execute on unsorted data, causing incorrect results.',
          parallelLineStart: 23,
          type: AnnotationType.warning,
          icon: Icons.sync,
        ),
        CodeAnnotation(
          title: 'Memory Bandwidth Saturation',
          description:
              'Merge sort is memory-bound due to extensive array copying. '
              'Parallel speedup is limited by memory bandwidth, not CPU cores. '
              'Typical speedup: 4-6x instead of 8x on 8-core systems.',
          type: AnnotationType.performance,
          icon: Icons.memory,
        ),
      ],
    );
  }

  /// Monte Carlo Pi Estimation code snippet.
  static CodeSnippet _generateMonteCarloCode() {
    const serialCode = '''// Sequential Monte Carlo Pi Estimation
// Time Complexity: O(N)
// Embarrassingly parallel workload

double estimate_pi_serial(long long N) {
    long long hits = 0;
    
    // Generate N random points
    for (long long i = 0; i < N; i++) {
        double x = (double)rand() / RAND_MAX;
        double y = (double)rand() / RAND_MAX;
        
        // Check if point is inside unit circle
        if (x*x + y*y <= 1.0) {
            hits++;
        }
    }
    
    // Pi ≈ 4 * (points in circle / total points)
    return 4.0 * hits / N;
}

// Independent iterations
// No data dependencies
// Ideal for parallelization''';

    const parallelCode = '''// Parallel Monte Carlo with OpenMP
// Expected Speedup: ~7.5-8x on 8 cores
// Near-perfect linear scaling

double estimate_pi_parallel(long long N, int threads) {
    long long total_hits = 0;
    omp_set_num_threads(threads);
    
    // PARALLELIZATION: Each thread processes subset
    #pragma omp parallel
    {
        unsigned int seed = time(NULL) + omp_get_thread_num();
        long long local_hits = 0;
        
        // Distribute iterations across threads
        #pragma omp for
        for (long long i = 0; i < N; i++) {
            // Thread-safe random generation
            seed = seed * 1103515245 + 12345;
            double x = (double)(seed % 1000000) / 1000000.0;
            
            seed = seed * 1103515245 + 12345;
            double y = (double)(seed % 1000000) / 1000000.0;
            
            if (x*x + y*y <= 1.0) {
                local_hits++;
            }
        }
        
        // ATOMIC: Safely aggregate results
        #pragma omp atomic
        total_hits += local_hits;
    }
    
    return 4.0 * total_hits / N;
}

// Embarrassingly parallel: No communication
// Atomic operation: Thread-safe aggregation''';

    return CodeSnippet(
      algoId: 'monte_carlo',
      serialCode: serialCode,
      parallelCode: parallelCode,
      serialComplexity: 'O(N)',
      parallelSpeedupPotential: '~7.5-8x (near-linear)',
      annotations: [
        CodeAnnotation(
          title: 'Embarrassingly Parallel',
          description:
              'Monte Carlo is the ideal parallel workload. Each iteration is completely independent '
              'with no data dependencies. This enables near-perfect linear speedup, '
              'limited only by thread creation overhead and atomic operations.',
          type: AnnotationType.concept,
          icon: Icons.scatter_plot,
        ),
        CodeAnnotation(
          title: 'Thread-Local Variables',
          description:
              'Each thread maintains its own local_hits counter to avoid contention. '
              'Only at the end do threads use atomic operation to aggregate. '
              'This minimizes synchronization overhead and maximizes parallelism.',
          parallelLineStart: 12,
          type: AnnotationType.optimization,
          icon: Icons.layers,
        ),
        CodeAnnotation(
          title: 'Atomic Aggregation',
          description:
              '#pragma omp atomic ensures only one thread updates total_hits at a time. '
              'Without atomic, race conditions would cause incorrect results. '
              'Atomic has minimal overhead (~10-50 cycles) since it happens only once per thread.',
          parallelLineStart: 29,
          type: AnnotationType.concept,
          icon: Icons.lock,
        ),
        CodeAnnotation(
          title: 'Random Number Generation',
          description:
              'Thread-safe RNG is crucial. Each thread uses unique seed (time + thread_id). '
              'Using shared rand() would require locking, destroying parallelism. '
              'LCG (Linear Congruential Generator) provides fast, thread-local randomness.',
          parallelLineStart: 11,
          type: AnnotationType.warning,
          icon: Icons.shuffle,
        ),
      ],
    );
  }

  /// N-Body Simulation code snippet.
  static CodeSnippet _generateNBodyCode() {
    const serialCode = '''// Sequential N-Body Simulation
// Time Complexity: O(N²)
// Pairwise force calculations

void compute_forces_serial(Body* bodies, int N) {
    const double G = 6.67430e-11;
    
    // For each body
    for (int i = 0; i < N; i++) {
        double fx = 0.0, fy = 0.0, fz = 0.0;
        
        // Calculate force from all other bodies
        for (int j = 0; j < N; j++) {
            if (i != j) {
                double dx = bodies[j].x - bodies[i].x;
                double dy = bodies[j].y - bodies[i].y;
                double dz = bodies[j].z - bodies[i].z;
                double dist = sqrt(dx*dx + dy*dy + dz*dz);
                double force = G * bodies[i].mass * 
                              bodies[j].mass / (dist*dist);
                
                fx += force * dx / dist;
                fy += force * dy / dist;
                fz += force * dz / dist;
            }
        }
        
        // Update velocities
        bodies[i].vx += fx / bodies[i].mass;
        bodies[i].vy += fy / bodies[i].mass;
        bodies[i].vz += fz / bodies[i].mass;
    }
}

// O(N²) pairwise interactions
// Each body influenced by all others''';

    const parallelCode = '''// Parallel N-Body with OpenMP
// Expected Speedup: ~5-7x on 8 cores
// Dynamic scheduling for load balance

void compute_forces_parallel(Body* bodies, 
                            int N, int threads) {
    const double G = 6.67430e-11;
    omp_set_num_threads(threads);
    
    // PARALLELIZATION: Distribute bodies across threads
    #pragma omp parallel for schedule(dynamic)
    for (int i = 0; i < N; i++) {
        double fx = 0.0, fy = 0.0, fz = 0.0;
        
        // Inner loop: Read-only access (no conflicts)
        for (int j = 0; j < N; j++) {
            if (i != j) {
                double dx = bodies[j].x - bodies[i].x;
                double dy = bodies[j].y - bodies[i].y;
                double dz = bodies[j].z - bodies[i].z;
                double dist = sqrt(dx*dx + dy*dy + dz*dz);
                double force = G * bodies[i].mass * 
                              bodies[j].mass / (dist*dist);
                
                fx += force * dx / dist;
                fy += force * dy / dist;
                fz += force * dz / dist;
            }
        }
        
        // Each thread updates different body (no conflicts)
        bodies[i].vx += fx / bodies[i].mass;
        bodies[i].vy += fy / bodies[i].mass;
        bodies[i].vz += fz / bodies[i].mass;
    }
}

// Dynamic scheduling: Better load balance
// Read-only inner loop: No synchronization needed''';

    return CodeSnippet(
      algoId: 'nbody',
      serialCode: serialCode,
      parallelCode: parallelCode,
      serialComplexity: 'O(N²)',
      parallelSpeedupPotential: '~5-7x on 8 cores',
      annotations: [
        CodeAnnotation(
          title: 'Fine-Grained Parallelism',
          description:
              'Each iteration of the outer loop is independent—threads calculate forces for different bodies. '
              'The inner loop reads body positions (no conflicts). Each thread writes to different bodies[i], '
              'avoiding data races without synchronization.',
          parallelLineStart: 10,
          type: AnnotationType.concept,
          icon: Icons.grain,
        ),
        CodeAnnotation(
          title: 'Dynamic Scheduling Choice',
          description:
              'schedule(dynamic) assigns iterations on-demand. This handles load imbalance '
              'when some bodies have different computational costs (e.g., varying interaction distances). '
              'Trade-off: ~2-5% overhead vs static, but better balance for irregular workloads.',
          parallelLineStart: 10,
          type: AnnotationType.optimization,
          icon: Icons.balance,
        ),
        CodeAnnotation(
          title: 'Memory Access Pattern',
          description:
              'Each thread reads all bodies[j] positions but writes only to bodies[i]. '
              'This creates high memory bandwidth usage (N² reads). Speedup limited by memory subsystem, '
              'not CPU cores. Cache helps with repeated reads.',
          type: AnnotationType.performance,
          icon: Icons.memory,
        ),
        CodeAnnotation(
          title: 'Algorithmic Optimization',
          description:
              'O(N²) can be reduced to O(N log N) using Barnes-Hut tree or Fast Multipole Method. '
              'Current implementation is brute-force for clarity. Production code would use spatial data structures '
              'to reduce computational complexity before parallelizing.',
          type: AnnotationType.concept,
          icon: Icons.auto_graph,
        ),
      ],
    );
  }

  /// Mandelbrot Set code snippet.
  static CodeSnippet _generateMandelbrotCode() {
    const serialCode = '''// Sequential Mandelbrot Set Generation
// Time Complexity: O(N² × k), k = iterations
// Highly irregular workload

void compute_mandelbrot_serial(int* result, 
                              int width, int height) {
    double x_min = -2.5, x_max = 1.0;
    double y_min = -1.0, y_max = 1.0;
    
    // For each pixel
    for (int py = 0; py < height; py++) {
        for (int px = 0; px < width; px++) {
            
            // Map pixel to complex plane
            double cx = x_min + (x_max - x_min) * px / width;
            double cy = y_min + (y_max - y_min) * py / height;
            
            // Iterate Mandelbrot function
            double x = 0.0, y = 0.0;
            int iter = 0;
            
            while (x*x + y*y <= 4.0 && iter < 1000) {
                double temp = x*x - y*y + cx;
                y = 2.0*x*y + cy;
                x = temp;
                iter++;
            }
            
            result[py * width + px] = iter;
        }
    }
}

// Iteration count varies per pixel
// Load imbalance: Some regions converge quickly''';

    const parallelCode = '''// Parallel Mandelbrot with Dynamic Scheduling
// Expected Speedup: ~6-7x on 8 cores
// Load balancing critical

void compute_mandelbrot_parallel(int* result,
                                int width, int height,
                                int threads) {
    double x_min = -2.5, x_max = 1.0;
    double y_min = -1.0, y_max = 1.0;
    omp_set_num_threads(threads);
    
    // PARALLELIZATION: Dynamic scheduling for load balance
    #pragma omp parallel for schedule(dynamic, 16) collapse(2)
    for (int py = 0; py < height; py++) {
        for (int px = 0; px < width; px++) {
            
            // Map pixel to complex plane
            double cx = x_min + (x_max - x_min) * px / width;
            double cy = y_min + (y_max - y_min) * py / height;
            
            // Iterate Mandelbrot function
            double x = 0.0, y = 0.0;
            int iter = 0;
            
            // Iteration count varies: 1 to 1000
            while (x*x + y*y <= 4.0 && iter < 1000) {
                double temp = x*x - y*y + cx;
                y = 2.0*x*y + cy;
                x = temp;
                iter++;
            }
            
            result[py * width + px] = iter;
        }
    }
}

// Dynamic scheduling: Essential for irregular workloads
// Chunk size 16: Balance overhead vs granularity''';

    return CodeSnippet(
      algoId: 'mandelbrot',
      serialCode: serialCode,
      parallelCode: parallelCode,
      serialComplexity: 'O(N² × k)',
      parallelSpeedupPotential: '~6-7x on 8 cores',
      annotations: [
        CodeAnnotation(
          title: 'Load Imbalance Problem',
          description:
              'Mandelbrot iteration count varies dramatically by pixel. Points inside the set '
              'take 1000 iterations, boundary points vary 10-999, and exterior points converge in 1-10 iterations. '
              'Static scheduling would create 8x performance difference between threads.',
          type: AnnotationType.warning,
          icon: Icons.warning_amber,
        ),
        CodeAnnotation(
          title: 'Dynamic Scheduling Solution',
          description:
              'schedule(dynamic, 16) assigns work in chunks of 16 pixels. When a thread finishes, '
              'it requests more work. This ensures all threads stay busy. Chunk size 16 balances '
              'scheduling overhead (~100 cycles) with fine-grained load distribution.',
          parallelLineStart: 12,
          type: AnnotationType.optimization,
          icon: Icons.auto_awesome,
        ),
        CodeAnnotation(
          title: 'Collapse Clause',
          description:
              'collapse(2) merges both loops into a single iteration space (width × height). '
              'This creates more parallel work opportunities and helps with load balancing. '
              'Instead of parallelizing rows, we parallelize individual pixels.',
          parallelLineStart: 12,
          type: AnnotationType.concept,
          icon: Icons.unfold_more,
        ),
        CodeAnnotation(
          title: 'Performance Characteristics',
          description:
              'Speedup limited by load imbalance and synchronization overhead from dynamic scheduling. '
              'Achieving 6-7x on 8 cores is good for irregular workloads. Better algorithms (adaptive sampling, '
              'perturbation theory) can improve but add complexity.',
          type: AnnotationType.performance,
          icon: Icons.insights,
        ),
      ],
    );
  }
}
