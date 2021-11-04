NAME=famine

SRC=src/famine.s
OBJ=src/famine.o
NASM=nasm

$(OBJ): $(SRC)
	$(NASM) -felf64 $(SRC)
$(NAME): $(OBJ)
	ld $(OBJ) -o $(NAME)
clean:
	rm -f $(OBJ)
fclean: clean
	rm -f $(NAME)

re: fclean all

all: $(NAME)

x: $(NAME)
	./$(NAME)

test: x

add: re test fclean
	git add $(SRC) Makefile Dockerfile README.md

commit: add
	git commit -m "famine"

push: commit
	git push origin main

PHONY: add commit push test clean fclean all