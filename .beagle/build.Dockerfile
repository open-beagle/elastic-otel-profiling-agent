ARG arch=amd64

FROM registry.cn-qingdao.aliyuncs.com/wod/debian:vtesting-$arch

WORKDIR /go/src/github.com/elastic/otel-profiling-agent

RUN sed -i 's/http\:\/\/deb.debian.org/http\:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources && \
  sed -i 's/http\:\/\/security.debian.org/http\:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources && \
  sed -i 's/http\:\/\/snapshot.debian.org/http\:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources && \
  apt update -y && DEBIAN_FRONTEND=noninteractive apt install ca-certificates -y && \
  sed -i 's/http\:\/\/mirrors.aliyun.com/https\:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources && \
  apt-get update -y && apt-get dist-upgrade -y && apt-get install -y \
    curl wget cmake dwz lsb-release software-properties-common gnupg git clang llvm \
    golang unzip && \
  apt-get clean && \
  rm -rf /etc/localtime && \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN git config --global http.proxy 'socks5://www.ali.wodcloud.com:1283' && \
    git clone --depth 1 --branch v3.1.0 --recursive https://github.com/zyantific/zydis.git && \
    cd zydis && mkdir build && cd build && \
    cmake -DZYDIS_BUILD_EXAMPLES=OFF .. && make -j$(nproc) && make install && \
    cd zycore && make install && \
    cd ../../.. && rm -rf zydis

ARG arch=amd64
RUN mkdir -p .tmp && \
    curl -x socks5://www.ali.wodcloud.com:1283 \
    -L https://github.com/golangci/golangci-lint/releases/download/v1.54.2/golangci-lint-1.54.2-linux-$arch.tar.gz \
    > .tmp/golangci-lint-1.54.2-linux-$arch.tar.gz && \
    tar -xzvf .tmp/golangci-lint-1.54.2-linux-$arch.tar.gz -C .tmp/ && \
    mv .tmp/golangci-lint-1.54.2-linux-amd64/golangci-lint /usr/local/bin/golangci-lint && \
    rm -rf .tmp

# gRPC dependencies
ENV GOPROXY=https://goproxy.cn
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.31.0
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0

RUN                                                                                \
  PB_URL="https://github.com/protocolbuffers/protobuf/releases/download/v24.4/";   \
  PB_FILE="protoc-24.4-linux-$(uname -m | sed 's/aarch64/aarch_64/').zip";         \
  INSTALL_DIR="/usr/local";                                                        \
                                                                                   \
  curl -LO "$PB_URL/$PB_FILE" -x "socks5://www.ali.wodcloud.com:1283"              \
    && unzip "$PB_FILE" -d "$INSTALL_DIR" 'bin/*' 'include/*'                      \
    && chmod +xr "$INSTALL_DIR/bin/protoc"                                         \
    && find "$INSTALL_DIR/include" -type d -exec chmod +x {} \;                    \
    && find "$INSTALL_DIR/include" -type f -exec chmod +r {} \;                    \
    && rm "$PB_FILE"

RUN echo "export PATH=\"\$PATH:\$(go env GOPATH)/bin\"" >> ~/.bashrc

ENTRYPOINT ["/bin/bash", "-l", "-c"]
