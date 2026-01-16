
__attribute__((noinline))
int fib_debug(int n)
{
    if (n < 2)
        return n;

    int a = fib_debug(n-1);  // first recursive call
    int b = fib_debug(n-2);  // second recursive call
    return a + b;
}

int main(void)
{
    int a = fib_debug(4);
    return a;
}
