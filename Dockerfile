FROM ruby:latest
MAINTAINER Campus Code <contato@campuscode.com.br>

RUN apt-get update -qq
RUN apt-get install -y --force-yes vim \
      imagemagick

RUN mkdir -p /rails-guides-pt-BR
WORKDIR /rails-guides-pt-BR
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

ADD . /rails-guides-pt-BR
