#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <string.h>

#define LW_BRIDGE_BASE  0xFF200000
#define LW_BRIDGE_SPAN  0x00200000
#define DCT_BASE_OFFSET 0x0200

typedef struct {
    const char *name;
    short input[8];
    short expected[8];
} test_case_t;

static test_case_t tests[] = {
    {
        "All zeros",
        {0, 0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 0}
    },
    {
        "All same (128)",
        {128, 128, 128, 128, 128, 128, 128, 128},
        {724, 0, 0, 0, 0, 0, 0, 0}
    },
    {
        "Ramp 10-80",
        {10, 20, 30, 40, 50, 60, 70, 80},
        {255, -182, 0, -19, 0, -6, 0, -1}
    },
    {
        "Alternating +/-100",
        {100, -100, 100, -100, 100, -100, 100, -100},
        {0, 144, 0, 170, 0, 255, 0, 725}
    },
    {
        "Single impulse",
        {100, 0, 0, 0, 0, 0, 0, 0},
        {71, 139, 131, 118, 100, 79, 54, 28}
    },
    {
        "Sine-like",
        {0, 71, 100, 71, 0, -71, -100, -71},
        {0, 453, -217, -257, 0, -51, -1, -12}
    },
};

int run_test(volatile int *dct, test_case_t *t) {
    /* Write 8 input pixels */
    for (int i = 0; i < 8; i++)
        dct[i] = (int)t->input[i];

    /* Wait for state machine: IDLE->COMPUTE->OUTPUT */
    usleep(1000);

    /* Read 8 DCT outputs */
    short result[8];
    for (int i = 0; i < 8; i++)
        result[i] = (short)(dct[i] & 0xFFFF);

    /* Compare against expected */
    int pass = 1;
    for (int i = 0; i < 8; i++) {
        if (result[i] != t->expected[i]) {
            pass = 0;
            break;
        }
    }

    printf("Test: %-25s %s\n", t->name, pass ? "PASS" : "FAIL");

    if (!pass) {
        printf("  Input:    ");
        for (int i = 0; i < 8; i++) printf("%6d", t->input[i]);
        printf("\n  Expected: ");
        for (int i = 0; i < 8; i++) printf("%6d", t->expected[i]);
        printf("\n  Got:      ");
        for (int i = 0; i < 8; i++) printf("%6d", result[i]);
        printf("\n");
    }

    return pass;
}

int main() {
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("open /dev/mem"); return 1; }

    void *lw_bridge = mmap(NULL, LW_BRIDGE_SPAN,
                           PROT_READ | PROT_WRITE,
                           MAP_SHARED, fd, LW_BRIDGE_BASE);
    if (lw_bridge == MAP_FAILED) { perror("mmap"); return 1; }

    volatile int *dct = (volatile int *)(lw_bridge + DCT_BASE_OFFSET);

    int num_tests = sizeof(tests) / sizeof(tests[0]);
    int passed = 0;

    printf("Running %d DCT tests...\n\n", num_tests);

    for (int i = 0; i < num_tests; i++) {
        if (run_test(dct, &tests[i]))
            passed++;
    }

    printf("\n%d/%d tests passed\n", passed, num_tests);

    munmap(lw_bridge, LW_BRIDGE_SPAN);
    close(fd);
    return (passed == num_tests) ? 0 : 1;
}
