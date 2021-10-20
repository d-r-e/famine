NAME=famine
SRC=src/main.c
OBJ = $(SRC:.c=.o)
FLAGS= -Wall -Wextra -Werror -Wformat-security -fsanitize=address
$(NAME): $(OBJ)
	gcc $(FLAGS) $(OBJ) -o $(NAME)

%.o: %.c $(INC)
		gcc $(FLAGS) -c -o $@ $<