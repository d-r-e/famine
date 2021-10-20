NAME=famine
SRC=src/main.c
OBJ = $(SRC:.c=.o)
BRANCH = main
FLAGS= -Wall -Wextra -Werror -Wformat-security -fsanitize=address
$(NAME): $(OBJ)
	gcc $(FLAGS) $(OBJ) -o $(NAME)

%.o: %.c $(INC)
		gcc $(FLAGS) -c -o $@ $<

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

all: $(NAME)

add: fclean
	git add .gitignore Makefile $(SRC) $(INC) Dockerfile

commit: add
	git commit -m "darodrig"

push: commit
	git push origin $(BRANCH)

x: $(NAME)
	./$(NAME)
.PHONY: all re clean fclean add commit push