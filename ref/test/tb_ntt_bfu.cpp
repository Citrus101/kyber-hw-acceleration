#include <verilated.h>
#include "Vntt_bfu.h"
#include <iostream>
#include <cstdlib>
#include <cstdint>

#define Q 3329

int16_t montgomery_reduce(int32_t a) {
    int32_t m = (int16_t)a * 62209;
    int32_t t = (a - m * 3329) >> 16;

    if (t < 0) t += 3329;
    return (int16_t)t;
}

int16_t mod_q(int32_t x) {
    x %= 3329;
    if (x < 0) x += 3329;
    return (int16_t)x;
}

int16_t to_mont(int16_t x) {
    return mod_q((int32_t)x * 2285);
}

int16_t from_mont(int16_t x) {
    return montgomery_reduce(x);
}

// Golden Kyber butterfly
void golden_bfu(int16_t a, int16_t b, int16_t zeta,
                int16_t &a_out, int16_t &b_out) {

    int16_t t = montgomery_reduce((int32_t)zeta * b);

    int32_t ap = a + t;
    int32_t am = a - t;

    a_out = mod_q(ap);
    b_out = mod_q(am);
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vntt_bfu* top = new Vntt_bfu;

    int errors = 0;

    // -----------------------------
    // Directed tests
    // -----------------------------
    int16_t test_a[]   = {100, -200, 1234, -4096, 0, 3328};
    int16_t test_b[]   = {50,  300,  -123, 2048, -1, 1};
    int16_t test_zeta[] = {3, -5, 17, -33, 3328, -3329};

    int num_tests = 6;

    for (int i = 0; i < num_tests; i++) {
        top->a = test_a[i];
        top->b = test_b[i];
        top->zeta = test_zeta[i];

        top->eval();

        int16_t ref_a, ref_b;
        golden_bfu(test_a[i], test_b[i], test_zeta[i], ref_a, ref_b);

        std::cout << "Test " << i << ": ";

        if (top->a_out != ref_a || top->b_out != ref_b) {
            std::cout << "FAIL\n";
            errors++;
        } else {
            std::cout << "PASS\n";
        }
        std::cout << "  Inputs : a=" << test_a[i]
                    << " b=" << test_b[i]
                    << " zeta=" << test_zeta[i] << "\n";
        std::cout << "  DUT    : a_out=" << top->a_out
                    << " b_out=" << top->b_out << "\n";
        std::cout << "  REF    : a_out=" << ref_a
                    << " b_out=" << ref_b << "\n";
    }

    // -----------------------------
    // Summary
    // -----------------------------
    if (errors == 0) {
        std::cout << "\n✅ ALL TESTS PASSED\n";
    } else {
        std::cout << "\n❌ ERRORS: " << errors << "\n";
    }

    delete top;
    return errors;
}
