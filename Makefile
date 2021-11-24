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
s: $(NAME)
	mkdir -p /tmp/test
	cp /bin/echo /tmp/test/echo
	cp /bin/dir /tmp/test/
	strace -x ./$(NAME)
	cp /bin/dir /tmp/test/
	/tmp/test/echo -e "\033[0;33mFAMINE\033[0m"
	strings /tmp/test/dir | grep --color=always "darodrig"
ss: s
	binwalk -W /tmp/test/echo /bin/echo | less

test: s

add: test fclean 
	git add $(SRC) Makefile README.md

commit: add
	git commit -m "famine"

push: commit
	git push origin main

PHONY: add commit push test clean fclean all