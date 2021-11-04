ARG VARIANT="bullseye"
FROM debian:${VARIANT}
LABEL maintainer darodrig

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install vim fasm nasm make clang gcc git valgrind binwalk watch make man binutils binwalk nasm
RUN apt-get install -y zsh
CMD /bin/zsh