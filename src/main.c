#include "../inc/famine.h"


int main(int argc, char **argv)
{
    DIR *test;
    DIR *test2;

    if (argc != 1)
        return (-1);
    (void)argv;
    test = opendir("/tmp/test");
    if (test)
    {
        closedir(test);
    } else
        debug("%s","test folder not found");
    test2 = opendir("/tmp/test2");
    if (test2)
    {
        closedir(test2);
    } else 
        dprintf(2, "error opening /tmp/test2 folder");

}