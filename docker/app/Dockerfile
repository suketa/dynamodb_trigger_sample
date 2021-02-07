FROM ruby:2.7.2-slim-buster

ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y less curl unzip && \
    gem install aws-sdk && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip && rm -rf ./aws

WORKDIR /app

