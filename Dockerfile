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
        python-pip \
 && yum clean all && rm -rf /var/cache/yum

ADD Gemfile /tmp/

RUN yum install -y \
        gcc \
        gcc-c++ \
        make \
        libstdc++-devel \
        openssl-devel \
        ruby-devel \
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

#--- Add Python utility
RUN pip install https://github.com/ps-jay/RainEagle/archive/v0.1.8-pjfork.zip

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
ADD jobs/* /dashing/jobs/
ADD dashboards/*.erb /dashing/dashboards/
ADD widgets/ /dashing/widgets/

EXPOSE 3030
CMD ["dashing", "start"]
