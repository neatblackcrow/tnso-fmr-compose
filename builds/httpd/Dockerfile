FROM httpd:2.4-alpine

COPY ./httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./tls/nso_certificate.crt /usr/local/apache2/conf/tls/nso_certificate.crt
COPY --chmod=600 ./tls/nso_certificate.key /usr/local/apache2/conf/tls/nso_certificate.key