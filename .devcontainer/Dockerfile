ARG VARIANT="bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}
LABEL maintainer darodrig

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install vim make gcc git valgrind binwalk watch make man binutils binwalk

