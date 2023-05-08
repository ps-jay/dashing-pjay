# vi: set ft=dockerfile sw=4 :

FROM ruby:3.1-alpine3.17

MAINTAINER Philip Jay <phil@jay.id.au>

ENV TZ Australia/Melbourne

RUN apk update \
 && apk upgrade
 
RUN apk add \
        bash \
        build-base \
        curl \
        nodejs \
        tzdata

ADD Gemfile /tmp/

RUN echo "Starting gem install, don't worry it probably hasn't hung..." \
 && gem install \
        -g /tmp/Gemfile \
        --no-document

#--- Add smashing user
RUN adduser -S -s /sbin/nologin \
        -h /smashing \
        smashing

#--- Install smashing
USER smashing
WORKDIR /smashing

RUN smashing new `pwd` \
 && rm -f \
     Gemfile \
     config.ru \
     dashboards/* \
     jobs/*

ADD Gemfile /smashing/
RUN bundle install --local

RUN curl --silent --fail --show-error \
        -o /smashing/assets/javascripts/jquery.transit.js \
        https://raw.githubusercontent.com/rstacruz/jquery.transit/master/jquery.transit.js

ADD config.ru /smashing/
ADD public/* /smashing/public/
ADD jobs/*.rb /smashing/jobs/
ADD dashboards/*.erb /smashing/dashboards/
ADD widgets/ /smashing/widgets/

EXPOSE 3030
CMD ["smashing", "start"]
