FROM debian:bullseye
RUN apt update && apt upgrade -y
RUN apt install -yqq git make gcc gdb valgrind man watch binutils binwalk
RUN apt install -yqq zsh

ARG USERNAME=darodrig
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
RUN su darodrig -c 'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
RUN echo "alias ll=ls -la" > /home/darodrig/.zshrc
CMD /bin/zsh