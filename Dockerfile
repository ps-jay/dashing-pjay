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
 && yum clean all

RUN yum install -y \
        nodejs \
        https://kojipkgs.fedoraproject.org//packages/http-parser/2.7.1/3.el7/x86_64/http-parser-2.7.1-3.el7.x86_64.rpm \
 && yum clean all

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
 && yum history undo 5 -y \
 && yum clean all

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

EXPOSE 3030
CMD ["dashing", "start"]
