ARG VARIANT="bullseye"
FROM debian:${VARIANT}
LABEL maintainer darodrig

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install curl vim nasm make clang gcc git valgrind binwalk watch make man binutils binwalk
RUN apt-get install -y zsh
RUN curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
CMD /bin/zsh