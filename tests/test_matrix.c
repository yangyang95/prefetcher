#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <assert.h>

#define TEST_W 4096
#define TEST_H 4096

/* provide the implementations of naive_transpose,
 * sse_transpose, sse_prefetch_transpose
 */

#include "../impl/naive_transpose.c"

MatrixAlgo *matrix_providers[] = {
    &NaiveMatrixProvider,
};

int main()
{
    MatrixAlgo *algo = matrix_providers[0];

    /* verify the result of 4x4 matrix */

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

    Matrix *dst, *src, *expect;

    /* expected answer */
    expect = algo->create(4, 4);
    algo->assign(expect, *expected, expected_size);

    /* create & assign matrix */
    src = algo->create(4, 4);
    dst = algo->create(4, 4);

    algo->assign(src, *testin, testin_size);

    /* transpose */
    /*TODO: measure elapsed time */
    algo->transpose(dst, src);

    /* correctness check */
    assert(1 == algo->equal(dst, expect) &&
           "Verification fails");

    /* print result */
    /*TODO: print tranpose elapsed time info*/

    printf("Before transpose:\n");
    algo->print(src);
    printf("\n");

    printf("After transpose:\n");
    algo->print(dst);

    return 0;
}
