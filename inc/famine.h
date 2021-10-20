#pragma once

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdint.h>
#ifndef DEBUG
# define DEBUG 0
#endif
#define debug(fmt, ...) \
        do { if (DEBUG)  fprintf(stderr, "\e[38;5;229m%s:\e%d:%s():\e[39m " fmt"\n", __FILE__, __LINE__, __func__, __VA_ARGS__); } while (0)
