NAME=famine
SRC=src/famine.s
OBJ=src/famine.o
NASM=nasm

$(NAME): $(OBJ)
	ld $(OBJ) -o $(NAME)

$(OBJ): $(SRC)
	$(NASM) -felf64 -g $(SRC)
clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

all: $(NAME)

x: $(NAME)
	./$(NAME)

test: x

add: test fclean 
	git add $(SRC) Makefile README.md

commit: add
	git commit -m "famine"

push: commit
	git push origin main

PHONY: add commit push test clean fclean all