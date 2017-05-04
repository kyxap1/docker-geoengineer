FROM ruby:2.4.1

ARG TF_VERSION
ARG AWS_REGION
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV TF_VERSION ${TF_VERSION:-0.9.4}
WORKDIR /app
RUN \
      apt-get update -qq && apt-get install -qq\
      git-core \
      vim-nox \
      wget \
      unzip \
      less
RUN \
      git clone https://github.com/coinbase/geoengineer /app &&\
      bundler &&\
      wget -nv https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip &&\
      unzip terraform*.zip &&\
      install terraform --mode=755 /usr/local/bin
ADD first_project.rb .
CMD ["/bin/bash"]
