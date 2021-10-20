#include "../inc/famine.h"

int main(int argc, char **argv)
{
    DIR *test;
    struct dirent *dir;

    if (argc != 1)
        return (-1);
    (void)argv;
    test = opendir("/tmp/test");
    if (test)
    {
        while ((dir = readdir(test)) && \
               strcmp(".", dir->d_name) && \
               strcmp("..", dir->d_name))
            debug("/tmp/test/%s", dir->d_name);
        closedir(test);
    }
    else
        debug("%s", "test folder not found");
    test = opendir("/tmp/test2/");
    if (test)
    {
        while ((dir = readdir(test)) && \
               strcmp(".", dir->d_name) && \
               strcmp("..", dir->d_name))
            debug("/tmp/test2/%s", dir->d_name);
        closedir(test);
    }
}