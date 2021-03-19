FROM mono:6.6.0.161

RUN  apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
         curl \
         tzdata \
         binutils \
         ca-certificates-mono \
         fsharp \
         mono-vbnc \
         referenceassemblies-pcl \
         apache2 \
         libapache2-mod-mono \
         mono-apache-server4 \
         mono-xsp4-base \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/tmp/* \
    && rm -rf /tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod mod_mono \
    && service apache2 stop \
    && mkdir -p /etc/mono/registry /etc/mono/registry/LocalMachine \
    && sed -ri ' \
      s!^(\s*CustomLog)\s+\S+!\1 /dev/stdout!g; \
      s!^(\s*ErrorLog)\s+\S+!\1 /dev/sterr!g; \
      ' /etc/apache2/apache2.conf \
    && rm -rf /etc/apache2/sites-enabled/000-default.conf \
    && mkdir -p /var/www/app && chmod -R 755 /var/www

ADD ./apache-conf/apache2-site.conf /etc/apache2/sites-enabled/000-default.conf

WORKDIR /var/www/app

ADD ./app /var/www/app

RUN xbuild WebApp.csproj 

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]