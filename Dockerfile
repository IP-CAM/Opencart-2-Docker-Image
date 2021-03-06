FROM byjg/php:7.1-fpm-nginx

WORKDIR /var/www/html

ENV OPENCART_VER 3.0.2.0
ENV OPENCART_MD5 41c7e7ec49d389fc4c2204efb40289e6
ENV OPENCART_URL https://github.com/opencart/opencart/archive/${OPENCART_VER}.tar.gz
ENV OPENCART_FILE opencart.tar.gz
ENV OPENCART_DATA /data

COPY assets/default.conf /etc/nginx/conf.d
COPY assets/patch /tmp/patch
COPY assets/cmd.sh /cmd.sh

RUN set -xe \
    && apk add --no-cache wget tar rsync \
    && wget ${OPENCART_URL} -O ${OPENCART_FILE} \
    && echo "${OPENCART_MD5}  ${OPENCART_FILE}" | md5sum -c \
    && tar xzf ${OPENCART_FILE} --strip 2 --wildcards '*/upload/' \
    && patch -p2 < /tmp/patch \
    && mkdir ${OPENCART_DATA}/ \
    && touch ${OPENCART_DATA}/config.php \
    && ln -s ${OPENCART_DATA}/config.php config.php \
    && touch ${OPENCART_DATA}/admin-config.php \
    && ln -s ${OPENCART_DATA}/admin-config.php admin/config.php \
    && rm -rf install \
    && rm ${OPENCART_FILE} \
    && chown -R nobody:nobody /var/www \
    && chown -R nobody:nobody ${OPENCART_DATA} \
    && mkdir /opt \
    && mv admin/controller/extension     /opt/admin_controller_extension \
    && mv admin/language                 /opt/admin_language \
    && mv admin/model/extension          /opt/admin_model_extension \
    && mv admin/view/image               /opt/admin_view_image \
    && mv admin/view/javascript          /opt/admin_view_javascript \
    && mv admin/view/stylesheet          /opt/admin_view_stylesheet \
    && mv admin/view/template/extension  /opt/admin_view_template_extension \
    && mv catalog/controller/extension   /opt/catalog_controller_extension \
    && mv catalog/language               /opt/catalog_language \
    && mv catalog/model/extension        /opt/catalog_model_extension \
    && mv catalog/view/javascript        /opt/catalog_view_javascript \
    && mv catalog/view/theme             /opt/catalog_view_theme \
    && mv system/config                  /opt/system_config \
    && mv system/library                 /opt/system_library \
    && mv image/catalog                  /opt/image_catalog

CMD [ "/cmd.sh" ]
