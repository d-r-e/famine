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
	rm -f /tmp/test/*
	rm -f /tmp/test2/*

fclean: clean
	rm -f $(NAME)

re: fclean all

all: $(NAME)

x: $(NAME)
	./$(NAME)
s: $(NAME) clean
	mkdir -p /tmp/test
	cp /bin/echo /tmp/test/echo
	cp /bin/dir /tmp/test/
	strace -x ./$(NAME)
	cp /bin/dir /tmp/test/
	/tmp/test/echo -e "\033[0;33mFAMINE\033[0m"
	strings /tmp/test/dir | grep --color=always "darodrig"
ss: s
	binwalk -W /tmp/test/echo /bin/echo | less
s10: $(NAME)
	rm -rf /tmp/test/*
	rm -rf /tmp/test2/*
	cp $$(find /bin/ -type f | head -n10 ) /tmp/test
	cp $$(find /bin/ -type f | tail -n10 ) /tmp/test2
	./$(NAME)
	strings /tmp/test/* | grep --color=always "darodrig"
	@strings /tmp/test/* | grep --color=always "darodrig" | wc -l
	strings /tmp/test2/* | grep --color=always "darodrig"
	@strings /tmp/test2/* | grep --color=always "darodrig" | wc -l
s20: $(NAME)
	rm -rf /tmp/test/*
	cp $$(find /bin/ -type f | head -n20 ) /tmp/test
	./$(NAME)
	strings /tmp/test/* | grep --color=always "darodrig"
	@strings /tmp/test/* | grep --color=always "darodrig" | wc -l
s30: $(NAME)
	rm -rf /tmp/test/*
	cp $$(find /bin/ -type f | head -n30 ) /tmp/test
	./$(NAME)
	strings /tmp/test/* | grep --color=always "darodrig"
	@strings /tmp/test/* | grep --color=always "darodrig" | wc -l
s40: $(NAME)
	rm -rf /tmp/test/*
	cp $$(find /bin/ -type f | head -n40 ) /tmp/test
	./$(NAME)
	strings /tmp/test/* | grep --color=always "darodrig"
	@strings /tmp/test/* | grep --color=always "darodrig" | wc -l
test: s10 s20 s30

add: clean test fclean 
	git add $(SRC) Makefile README.md

commit: add
	git commit -m "famine"

push: commit
	git push origin main

PHONY: add commit push test clean fclean all