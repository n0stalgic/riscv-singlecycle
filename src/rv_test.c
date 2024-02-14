#include <string.h>

extern unsigned __stacktop;

int f1(void);
int f2(void);

int main(void)
{
    int a = 0x12345678;
    int b = 0x87654321;
    int c = 0x50;
    int sum = a + b;

    int s1 = f1();
    int s2 = f2();

    int res;

    sum = a + b + s1 - s2;
    if ((unsigned int) sum < 100)
    {
        res = 0xdeadbabe;
    }
    else 
    {
        res = 0xabadbabe;
    }

    if (c >= 0x25)
    {
        res = 0xbabecafe;
    }
    else 
    {
        res = 0xdeadfa11;
    }

    if ((unsigned int) c >= 0x50)
        res = 0xcafebabe;
    else
        res = 0xdeadbeef;

    while (1);
}

int f1(void)
{
    int x = 34;
    int y = 23;

    return x << y;
}

int f2(void)
{
    int a = 1050;
    int b = 2424;

    return ~(b ^ a);
}