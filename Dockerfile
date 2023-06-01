FROM public.ecr.aws/amazonlinux/amazonlinux:2

WORKDIR /
USER root

# Install dependencies
RUN yum makecache \
  && yum update -y \
  && yum install -y \
    clang-10.0.0 \
    clang-tools-extra-10.0.0 \
    gcc.x86_64 \
    gcc-c++.x86_64 \
    glibc-devel.x86_64 \
    make.x86_64 \
    unzip.x86_64 \
    cmake3.x86_64 \
    tar.x86_64 \
    doxygen.x86_64 \
    graphviz.x86_64 \
    qemu-kvm \
    wget \
    gzip \
    which \
    bridge-utils \
    openssh-clients \
  && yum clean all \
  && rm -rf /var/cache/yum

# Setup cmake
RUN ln -s /usr/bin/cmake3 /usr/bin/cmake \
    && ln -s /usr/bin/ctest3 /usr/bin/ctest

# Setup protoc
RUN mkdir -p /protobuf \
    && wget -O /protobuf/protoc-3.20.1-linux-x86_64.zip \
    https://github.com/protocolbuffers/protobuf/releases/download/v3.20.1/protoc-3.20.1-linux-x86_64.zip
RUN unzip /protobuf/protoc-3.20.1-linux-x86_64.zip -d /protobuf bin/protoc
RUN unzip /protobuf/protoc-3.20.1-linux-x86_64.zip -d /protobuf 'include/*'

# Setup protobuf includes and libraries
RUN wget -O /protobuf/protobuf-cpp-3.20.1.zip \
    https://github.com/protocolbuffers/protobuf/releases/download/v3.20.1/protobuf-cpp-3.20.1.zip
RUN unzip /protobuf/protobuf-cpp-3.20.1.zip -d /protobuf
RUN cp -r /protobuf/protobuf-3.20.1/src/* /protobuf/include

# Bring in the nlohmann json library
RUN mkdir -p /nlohmann_json/include/nlohmann/ \
    && wget \
        -O /nlohmann_json/include/nlohmann/json.hpp \
        https://github.com/nlohmann/json/releases/download/v3.9.1/json.hpp
