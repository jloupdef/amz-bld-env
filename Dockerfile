FROM public.ecr.aws/docker/library/alpine:3.17.2

WORKDIR /
USER root

#####
# The below environment variables need to be defined by the user on running this container.
#####
# Path to the root of the project in the container.
ENV PACKAGE=""

#####
# The below environment variables are used in cmake `find_library` and `find_path` calls.
#####
# Useful JSON (de)serialization
ENV JSON_INC=/data/build/nlohmann_json

# Location of google test sources
ENV GTEST_ROOT=/data/build/test_support/googletest


#####
# Build process
#####

# Install dependencies
RUN apk update && \
    apk add --no-cache \
    bash \
    cmake \
    gcompat \
    gzip \
    libc6-compat \
    make \
    openrc \
    openssh-client \
    openssh-server \
    py3-pip \
    python3 \
    samba \
    sshpass \
    tar \
    unzip \
    wget
	

# Setup protoc
RUN mkdir -p /data/build/protobuf \
    && wget -O /data/build/protobuf/protoc-3.20.3-linux-x86_64.zip \
    https://github.com/protocolbuffers/protobuf/releases/download/v3.20.3/protoc-3.20.3-linux-x86_64.zip
RUN unzip /data/build/protobuf/protoc-3.20.3-linux-x86_64.zip -d /data/build/protobuf bin/protoc
RUN unzip /data/build/protobuf/protoc-3.20.3-linux-x86_64.zip -d /data/build/protobuf 'include/*'

# Setup protobuf includes and libraries
RUN wget -O /data/build/protobuf/protobuf-cpp-3.20.3.zip \
    https://github.com/protocolbuffers/protobuf/releases/download/v3.20.3/protobuf-cpp-3.20.3.zip
RUN unzip /data/build/protobuf/protobuf-cpp-3.20.3.zip -d /data/build/protobuf
RUN cp -r /data/build/protobuf/protobuf-3.20.3/src/* /data/build/protobuf/include
ADD ./lib/libprotobuf.so /data/build/protobuf/lib/

# Bring in the nlohmann json library
RUN mkdir -p /data/build/nlohmann_json/include/nlohmann/ \
    && wget \
        -O /data/build/nlohmann_json/include/nlohmann/json.hpp \
        https://github.com/nlohmann/json/releases/download/v3.9.1/json.hpp


# Install dependencies required for unit tests
RUN mkdir -p /data/build/test_support \
    && wget -O /data/build/test_support/release-1.12.1.zip \
    https://github.com/google/googletest/archive/refs/tags/release-1.12.1.zip
RUN unzip /data/build/test_support/release-1.12.1.zip -d /data/build/test_support/googletest \
    && mv /data/build/test_support/googletest/googletest-release-1.12.1/* /data/build/test_support/googletest
	

# Add dependencies for code coverage
RUN python3 -m pip install --upgrade pip
RUN pip3 install gcovr
RUN pip3 install junit2html
