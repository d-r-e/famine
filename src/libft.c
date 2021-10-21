#include "../inc/famine.h"

/*! ft_strlen
 * @param s string to read
 * @returns (unsigned long) length of the string
 */
size_t	ft_strlen(const char *s)
{
	unsigned long	i;

	i = 0;
	while (s && s[i])
		++i;
	return (i);
}

/*! ft_strcmp
 * @param s1 string to compare
 * @param s2 string to compare
 * @returns (int) lexicographical difference of both strings, or 0 if equal
 */
int ft_strcmp(const char *s1, const char *s2)
{
	int diff = 0;

	if (!s1 || !s2)
		return(diff);
	while (s1[diff] && s2[diff] && s1[diff] == s2[diff])
		diff++;
	return s2[diff] - s1[diff];
}

/*!
 * @fn ft_strncmp
 * @param	s1	string to compare
 * @param	s2	string to compare
 * @param	n		compare up to this amount of bytes
 * @returns (int) lexicographical difference of both strings, or 0 if equal
 */
int ft_strncmp(const char *s1, const char *s2, unsigned int n)
{
	int diff = 0;

	if (!s1 || !s2)
		return(diff);
	while (--n > 0 && s1[diff] && s2[diff] && s1[diff] == s2[diff])
		diff++;
	return s2[diff] - s1[diff];
}
/*!
 * @fn ft_memcpy
 * @param	dest	destination of the copy
 * @param	src		source or origin, bytes to read
 * @param	n		size of the bytes to read
 * @returns a pointer to the destination or null if error
 */
void *ft_memcpy(void *dest, const void *src, size_t n)
{
	size_t	i;

	if (!dest && !src && n > 0)
		return (NULL);
	i = 0;
	while (i < n)
	{
		((unsigned char*)dest)[i] = ((unsigned char*)src)[i];
		i++;
	}
	return ((unsigned char*)dest);
}

/**
 * @fn ft_puts: prints a string to the standard output followed by a new line
 * @param s string to write (needs to be null terminated)
 * */
size_t ft_puts(const char *s)
{
    int ret;

	if (!s)
		return (0);
	ret = write(1, s, ft_strlen(s));
	ret += write(1, "\n", 1);
    return (ret);
}

/** 
 * @brief
 * Gets the absolute value of a number
 * @param val number to evaluate
 * @return long long
 * */
long long ft_abs(long long val)
{
	return (val > 0 ? val : -val);
}

/**
 * @brief 
 * Allocates memory for the specified amount of elemnts
 * and sets all memory to zero.
 * @param n elements
 * @param size of each element
 * @return char* pointing to the allocated memory or NULL if error
 */
char *ft_calloc(size_t n, size_t size)
{
	char *ptr;

	ptr = malloc(n * size);
	if (!ptr)
		return (ptr);
	for (uint i = 0; i < (n * size); ++i)
	{
		ptr[i] = 0;
	}
	return (ptr);
}

/**
 * @brief checks if the character given as parameter is alphanumeric
 * 
 * @param c char to check
 * @return int 1 if true or 0 if false
 */
int	ft_isalnum(int c)
{
	return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
		|| (c >= '0' && c <= '9'));
}

/**
 * @brief checks if the character given as parameter is printable
 * 
 * @param c char to check
 * @return int 1 if true or 0 if false
 */
int ft_isprint(char c)
{
	return (c >= 32 && c <= 126);
}

/**
 * @brief 
 * checks if the character given as a parameter is a number
 * @param c char to evaluate
 * @return int 
 */
int ft_isnum(int c)
{
	return (c >= '0' && c <= '9');
}

/**
 * @brief 
 * finds a string in a string
 * @param haystack string to inspect
 * @param needle fragment to find
 * @param len maximum size of the string to find
 * @return char* pointer to the string found or null if nothing was found
 */
char	*ft_strnstr(const char *haystack, const char *needle, size_t len)
{
	size_t	i;
	size_t	j;

	if (*needle == '\0')
		return ((char*)haystack);
	i = 0;
	while (haystack[i] != '\0' && i < len)
	{
		j = 0;
		if (haystack[i] == needle[j] &&
				(i + ft_strlen(needle)) <= len)
		{
			while (needle[j] == haystack[i + j] && needle[j] != '\0')
				j++;
			if (j == ft_strlen(needle))
				return ((char*)&(haystack[i]));
		}
		i++;
	}
	return (NULL);
}

size_t	ft_strlcpy(char *dst, const char *src, size_t dstsize)
{
	unsigned int	count;

	if (!src)
		return (0);
	if (dstsize == 0)
		return (ft_strlen(src));
	count = 0;
	while (dstsize > 1 && *src)
	{
		*dst = *src;
		++dst;
		++src;
		--dstsize;
		++count;
	}
	*dst = '\0';
	while (*dst || *src)
	{
		if (*src)
		{
			++src;
			++count;
		}
	}
	return (count);
}

/**
 * @brief concatenates strings safely
 * 
 * @param dst destination
 * @param src source of the copy
 * @param dstsize sum of the original lenght plus the new one plus one more character to null-terminate
 * @return size_t 
 */
size_t	ft_strlcat(char *dst, const char *src, size_t dstsize)
{
	size_t i;
	size_t j;

	i = 0;
	j = 0;
	while (dst[i] != '\0' && i < dstsize)
		i++;
	while (src[j] != '\0' && (i + j + 1) < dstsize)
	{
		dst[i + j] = src[j];
		j++;
	}
	if (i < dstsize)
		dst[i + j] = '\0';
	return (i + ft_strlen(src));
}