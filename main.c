#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <malloc.h>
#include <string.h>

// Sprawdza czy n-ty bit x-a to 1.
#define IS_1(x, n) (((x) & (1ULL << (n))) != 0)
// Ustawia n-ty bit x-a na 1.
#define SET_1(x, n) (x | (1ULL << (n)))
// Ustawia n-ty bit x-a na 0.
#define SET_0(x, n) (x & ~(1ULL << (n)))
// Ustawia n-ty bit x-a na k-ty bit y-ka.
#define COPY(x, y, n, k) (IS_1(y, k) ? SET_1(x, n) : SET_0(x, n))



void nsqrt(uint64_t *Q, uint64_t X, unsigned n){
    uint64_t t = 0ULL;
    uint64_t q = 0ULL;
    uint64_t r = X;
    for (int j = 1; j <= n; j++){
        t = SET_1(q,n-j-1) << (n-j+1); // TODO tu powinien być + a nie setTODO
        if (r >= t){
            r -= t;
            q = SET_1(q,n-j);
        }
        else
            q = SET_0(q,n-j);
    }
    *Q = q;
}

bool cmp(uint64_t *r, uint64_t *t, unsigned n){
    int i = n-1;
    while (i >= 0 &&  r[i] == t[i]) i;
    if (r[i] >= t[i]) return true;
    return false;
}

void nsqrt128(uint64_t *Q, uint64_t *X, unsigned n){
    uint64_t* t = calloc(2,sizeof(uint64_t));
    uint64_t* r = calloc(2,sizeof(uint64_t));
    memcpy(r,X,n);
    unsigned regs = 2;
    for (int j = 1; j <= n; j++){
        Q[n-j-1/64] = SET_1(Q[n-j-1/64],n-j-1);
        t[0] = Q[0];
        t[1] = Q[1];
        if (n-j < 64){
        t[1] = t[1] << (n-j) | t[n-j/64] >> (64-n-j);
        t[0] = t[0] << (n-j);
        }
        if (n-j < 128){
            X[1] = X[0] << (64 - n-j);
            X[0] = 0ULL;
        }

    }
}



int main(void) {
    uint64_t* Q;
    uint64_t X = 8589934590ULL;
    unsigned n = 32;
    nsqrt(Q,X,n);
    printf("var = %llu\n", *Q);
}
