NAME=famine
SRC=src/main.c src/libft.c  src/files.c src/libelf.c src/famine.c
INC=inc/$(NAME).h inc/libft.h
OBJ = $(SRC:.c=.o)
OTHERF = Makefile README.md .gitignore .devcontainer
BRANCH = main
DEBUG = 1
CC= gcc
FLAGS= -Wall -Wextra -Werror -Wformat-security -DDEBUG=$(DEBUG) -fsanitize=address
COPY= /bin/bash /bin/ls /usr/bin/env test/hw /bin/echo
$(NAME): $(OBJ)
	$(CC) $(FLAGS) $(OBJ) -o $(NAME)

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

c:
	rm -rf /tmp/test
	mkdir -p /tmp/test
	cp $(COPY) /tmp/test/
v: $(NAME)
	valgrind ./$(NAME)
x: $(NAME) c
	./$(NAME)
.PHONY: all re clean fclean add commit push