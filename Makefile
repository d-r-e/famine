NAME=famine
SRC=src/main.c src/libft.c  src/files.c src/libelf.c
INC=inc/$(NAME).h inc/libft.h
OBJ = $(SRC:.c=.o)
OTHERF = Makefile Dockerfile README.md .gitignore .devcontainer
BRANCH = main
DEBUG = 1
FLAGS= -Wall -Wextra -Werror -Wformat-security -DDEBUG=$(DEBUG) -fsanitize=address

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
	git add $(SRC) $(INC) $(OTHERF)

commit: add
	git commit -m "darodrig"

push: commit
	git push origin $(BRANCH)

x: $(NAME)
	./$(NAME)
.PHONY: all re clean fclean add commit push