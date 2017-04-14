#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <malloc.h>
#include <assert.h>

#define TEST_W 4096
#define TEST_H 4096

/* provide the implementations of naive_transpose,
 * sse_transpose, sse_prefetch_transpose
 */

#include "../impl/matrix.h"
#include "../impl/stopwatch.h"

MatrixAlgo *matrix_providers[] = {
    &NaiveMatrixProvider,
    &SSEMatrixProvider,
};

int main()
{
    /* Matrix algorithm declaration */

#ifdef sse
    MatrixAlgo *algo = matrix_providers[1];
#else
    MatrixAlgo *algo = matrix_providers[0];
#endif

    /* verify the result of 4x4 matrix */
    {
        float testin[4][4] = {
            {  0,  1,  2,  3,},
            {  4,  5,  6,  7,},
            {  8,  9, 10, 11,},
            { 12, 13, 14, 15,},
        };

        float expected[4][4] = {
            { 0, 4,  8, 12,},
            { 1, 5,  9, 13,},
            { 2, 6, 10, 14,},
            { 3, 7, 11, 15,},
        };

        int testin_size = sizeof(testin) / sizeof(testin[0][0]);
        int expected_size = sizeof(expected) / sizeof(expected[0][0]);

        Matrix *matrix, *expect;

        /* expected answer */
        expect = algo->create(4, 4);
        algo->assign(expect, *expected, expected_size);

        /* create & assign matrix */
        matrix = algo->create(4, 4);
        algo->assign(matrix, *testin, testin_size);

        /* print original matrix */
        printf("Before transpose:\n");
        algo->println(matrix);

        /* transpose */
        algo->transpose(matrix);

        /* print result */
        printf("After transpose:\n");
        algo->println(matrix);

        /* correctness check */
        assert(1 == algo->equal(matrix, expect) &&
               "Verification fails");
    }

    /* Performance test */
    {
        float *src = (float *) memalign(32, sizeof(float) * TEST_W * TEST_H);

        srand(time(NULL));
        for (int i = 0; i < TEST_H; ++i) {
            for (int j = 0; j < TEST_W; ++j) {
                src[i * TEST_W + j] = rand();
            }
        }

        int src_size = TEST_W * TEST_H;

        Matrix *matrix;

        /* create & assign matrix */
        matrix = algo->create(TEST_W, TEST_H);
        algo->assign(matrix, src, src_size);

        /* setup timer */
        watch_p ctx = Stopwatch.create();
        assert(ctx && "Clock setup fail!");

        /* transpose & measure time */
        Stopwatch.start(ctx);
        algo->transpose(matrix);
        double now = Stopwatch.read(ctx);

        /* print result */
        printf("elpased time: %g us\n", now);
        Stopwatch.destroy(ctx);
    }

    return 0;
}
