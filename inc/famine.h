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
#define debug(...) \    do { if (DEBUG)      dprintf(2,"DRIVER_NAME:");    dprintf(2, __VA_ARGS__);    dprintf(2, "\n");   } while (0)