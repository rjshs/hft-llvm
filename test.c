#include <stdio.h>

int foo(int z) {
    printf("%d\n", z);
    return z + 1;
}

int main() {
    int x = 5;
    foo(x);
    return 0;
}
