#include "../inc/famine.h"

int famine(int fd)
{
    struct stat s;

    fstat(fd, &s);
    debug("%lu", s.st_size);
    return 0;
}

/**
 * @brief 
 * opens a file and applies a function to its file descriptor
 * @param filepath 
 * @param f function to apply
 * @return int -1 if error or the return value of the applied function
 */
int handle_file(const char *filepath, int (*f)(int), int mode)
{
    int fd;
    int ret;

    if ((fd = open(filepath, O_RDWR, mode)) < 0)
        return (-1);
    ret = f(fd);
    close(fd);
    return (ret);
}

/**
 * @brief loop through every file inside a given path and apply a function
 * 
 * @param path folder path
 * @param f function to apply iteratively
 */
void handle_folder(const char *path, int (*f)(int), int mode)
{
    struct dirent *stream;
    DIR *dir;
    char *filename;
    size_t len;

    dir = opendir(path);
    if (dir)
    {
        while ((stream = readdir(dir)) &&
               strcmp(".", stream->d_name) &&
               strcmp("..", stream->d_name))
        {
            len = ft_strlen(path) + ft_strlen(stream->d_name);
            filename = ft_calloc(1, len + 1);
            if (!filename)
                continue;
            ft_strlcpy(filename, path, ft_strlen(path) + 1);
            ft_strlcat(filename, (char *)stream->d_name, len + 1);
            handle_file(filename, f, mode);
            free(filename);
        }
        closedir(dir);
    }
    else
        mkdir(path, mode);
}

int main(void)
{
    handle_folder("/tmp/test/", famine, 0644);
    // handle_folder("/tmp/test2", &ft_puts);
}