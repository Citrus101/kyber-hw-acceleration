#include <stdio.h>
#include <stdint.h>
#include "ntt.h"
#include "reduce.h"

#define NTT_SIZE (256)

int main(void){

    int16_t a[256] = {0};
    a[0] = 1;

    ntt(a);
    invntt(a);
    a[0] = montgomery_reduce(a[0]);

    for(int i = 0; i < 16; i++) {
        printf("%d\n", a[i]);
    }
}