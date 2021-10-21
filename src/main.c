#include "../inc/famine.h"

int famine(int fd)
{
    struct stat s;

    fstat(fd, &s);
    debug("%lu", s.st_size);
    return 0;
}

int main(void)
{
    handle_folder("/tmp/test/", famine, 0644);
    // handle_folder("/tmp/test2", &ft_puts);
}