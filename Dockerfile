FROM ruby:latest
MAINTAINER Campus Code <contato@campuscode.com.br>





RUN apt-get update -qq
RUN apt-get install -y --force-yes vim \
      imagemagick locales

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

RUN mkdir -p /rails-guides-pt-BR
WORKDIR /rails-guides-pt-BR
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

ADD . /rails-guides-pt-BR
