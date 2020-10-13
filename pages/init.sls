# Deploy site to answer ACME challenges
/var/opt/gitlab/nginx/conf/letsencrypt.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://{{ tpldir }}/nginx.jinja
    - template: jinja
    - defaults:
      acme_challenge_dir: /var/opt/gitlab/nginx/www/.well-known/acme-challenge
