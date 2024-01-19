FROM nginx:alpine

# set main params
ARG BUILD_ARGUMENT_ENV=dev
ENV ENV=$BUILD_ARGUMENT_ENV
ARG ADMIN_EMAIL=youraccount@gmail.com
ENV ADMIN_EMAIL=$ADMIN_EMAIL

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    rm -rf /etc/nginx/conf.d/*

RUN sed -i 's#dl-cdn.alpinelinux.org#mirrors.aliyun.com#g' /etc/apk/repositories



# COPY ./$BUILD_ARGUMENT_ENV/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./$BUILD_ARGUMENT_ENV/*.conf /tmp/nginx/
COPY ./5-init_nginx_conf.sh /docker-entrypoint.d/
RUN chmod +x /docker-entrypoint.d/5-init_nginx_conf.sh
COPY ./6-init_ssl.sh /tmp/

RUN if [ "$ENV" = "prod" ] || [ "$ENV" = "staging" ]; then \
      apk add certbot certbot-nginx && \
      echo "30 2,14 * * * certbot renew --quiet" >> /etc/crontab && \
      cp /tmp/6-init_ssl.sh /docker-entrypoint.d/  && \
      sed -i 's|ADMIN_EMAIL|'"${ADMIN_EMAIL}"'|g' /docker-entrypoint.d/6-init_ssl.sh && \
      chmod +x /docker-entrypoint.d/6-init_ssl.sh; \
    fi


