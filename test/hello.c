#include <unistd.h>
#include <elf.h>

int main()

{
    printf("%d\n", sizeof( Elf64_Phdr));
    write(1, "Hello World\n", 13);
}