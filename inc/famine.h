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
#include <elf.h>
#include <sys/mman.h>
#include "../inc/libft.h"

#ifndef DEBUG
# define DEBUG 0
#endif
#define debug(fmt, ...)                                                             \
        do                                                                          \
        {                                                                           \
                if (DEBUG)                                                          \
                        fprintf(stderr, "\e[38;5;229m%s:%d: %s():\e[39m " fmt "\n", \
                                __FILE__, __LINE__, __func__, __VA_ARGS__);         \
        } while (0)

/** LIBELF **/
int is_elf_64(void *mem, size_t size);
/** ****** **/

int handle_file(const char *filepath, int (*f)(int), int mode);
void handle_folder(const char *path, int (*f)(int), int mode);