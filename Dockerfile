FROM nginx:alpine
RUN apk add --no-cache openssh-client supervisor
RUN rm /etc/nginx/conf.d/default.conf
COPY default.conf.template /etc/nginx/templates/
COPY docker-entrypoint.d/20-setup-ssh.sh /docker-entrypoint.d/
COPY docker-entrypoint.d/30-generate-custom-config.sh /docker-entrypoint.d/
COPY docker-entrypoint.d/40-generate-htpasswd.sh /docker-entrypoint.d/
COPY docker-entrypoint.d/50-generate-networkconf.sh /docker-entrypoint.d/
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY www/* /usr/share/nginx/html/error/
RUN chmod +x /entrypoint.sh /docker-entrypoint.d/20-setup-ssh.sh /docker-entrypoint.d/30-generate-custom-config.sh /docker-entrypoint.d/40-generate-htpasswd.sh /docker-entrypoint.d/50-generate-networkconf.sh
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
