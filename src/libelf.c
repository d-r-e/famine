#include "../inc/famine.h"

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