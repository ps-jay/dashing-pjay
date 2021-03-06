# vi: set ft=dockerfile sw=4 :

FROM centos:7

MAINTAINER Philip Jay <phil@jay.id.au>

ENV TZ Australia/Melbourne

RUN sed -i 's/enabled=1/enabled=0/' /etc/yum/pluginconf.d/fastestmirror.conf

#--- Install packages
RUN yum update -y \
 && yum install -y \
        epel-release \
        ruby \
        rubygem-bundler \
        https://rpm.nodesource.com/pub_8.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm \
 && yum clean all && rm -rf /var/cache/yum

RUN yum install -y \
        nodejs \
 && yum clean all && rm -rf /var/cache/yum

ADD Gemfile /tmp/

RUN yum install -y \
        gcc \
        gcc-c++ \
        make \
        libstdc++-devel \
        openssl-devel \
        ruby-devel \
        sqlite-devel \
 && echo "Starting gem install, don't worry it probably hasn't hung..." \
 && gem install \
        -g /tmp/Gemfile \
        --no-document \
 && rm /tmp/Gemfile \
 && yum history undo 6 -y \
 && yum clean all && rm -rf /var/cache/yum

#--- Test `yum undo X` has done the right thing
RUN bash -c "if [[ -n '`type gcc`' ]] ; then echo 'Error: gcc still installed' && exit 1 ; fi"
RUN node --version

#--- Add dashing user
RUN useradd -r -s /sbin/nologin \
        -m -d /dashing \
        dashing

#--- Install dashing
USER dashing
WORKDIR /dashing

RUN dashing new `pwd` \
 && rm -f \
     Gemfile \
     config.ru \
     dashboards/* \
     jobs/*

ADD Gemfile /dashing/
RUN bundle install --local

ADD config.ru /dashing/
ADD public/* /dashing/public/
ADD jobs/*.rb /dashing/jobs/
ADD dashboards/*.erb /dashing/dashboards/
ADD widgets/ /dashing/widgets/
RUN curl https://raw.githubusercontent.com/rstacruz/jquery.transit/master/jquery.transit.js -o /dashing/assets/javascripts/jquery.transit.js

EXPOSE 3030
CMD ["dashing", "start"]
