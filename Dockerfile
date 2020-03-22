FROM alpine:latest

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apk --update add git bash curl && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

RUN git clone https://github.com/bats-core/bats-core.git && \
  cd bats-core && \
  git checkout v1.1.0 && \
  ./install.sh /usr/local && \
  cd .. && \
  rm -rf bats-core

RUN git clone https://github.com/ztombol/bats-support /usr/local/libexec/bats-support && \
  cd /usr/local/libexec/bats-support && \
  git checkout v0.3.0

RUN git clone https://github.com/jasonkarns/bats-assert-1 /usr/local/libexec/bats-assert && \
  cd /usr/local/libexec/bats-assert && \
  git checkout v2.0.0

RUN package=shellcheck-v0.7.0 && \
  archive=$package.linux.x86_64.tar.xz && \
  curl -O https://shellcheck.storage.googleapis.com/$archive && \
  tar xf $archive && \
  mv $package/shellcheck /usr/local/bin && \
  rm -rf $archive $package

RUN curl -Lo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  chmod +x /usr/local/bin/jq

ENV BITBUCKET_REST_API_AUTH key:secret

RUN echo 'set -o vi' >> /root/.bashrc

CMD ["/bin/bash"]
