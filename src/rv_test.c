extern unsigned __stacktop;
int f1(void);

int main(void)
{
    int a = 0x12345678;
    int b = 0x87654321;
    int sum = a + b;

    int s1 = f1();

    sum = a + b + s1;

    while (1);
}

int f1(void)
{
    int x = 34;
    int y = 23;

    return x << y;
}
