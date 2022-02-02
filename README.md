# Gitlab CE salt formula

This formula installs and configures [Gitlab Community Edition](https://gitlab.org).

See `pillar.example` for configuration options.


## gitlab:registry-garbage-collect

This formula will clean up unused images from Gitlab Registry every night.

It calls `gitlab-ctl registry-garbage-collect` via a systemd service.

You can configure it to also delete untagged manifests and the time it will be run (if needed) via pillars, see [pillar.example](pillar.example) for details.



# Gitlab CI Runner

`gitlab-runner` can be installed from the official repository using the `gitlab.runner` state.

To register a runner with a Gitlab instance, use the following command: `gitlab-runner register`.

For later reference, here's some example code of howto automate registration. This is not done, as the registration posibilities are pretty vast:

```yaml
cmd.run:
  - creates: /etc/gitlab-runner/config.toml
  - name: |
      gitlab-runner register \
        --non-interactive \
        --name {{ salt['pillar.get']('gitlab:hostname') }} \
        --registration-token salt['pillar.get']('gitlab:runner_token') \
        --url {{ salt['pillar.get']('gitlab:base_url')}} \
        --executor docker \
        --docker-image alpine
```


# Gitlab Pages

`gitlab.pages` can be used to configure letsencrypt config file for nginx to listen on port 80 and serve .well-known directory for ACME challenges.

When using this, port 80 shall be disabled in gitlab itself and nginx config shall be added in `gitlab.rb`:

```
pages_nginx['redirect_http_to_https'] = false
nginx['redirect_http_to_https'] = false
nginx['custom_nginx_config'] = "include /var/opt/gitlab/nginx/conf/letsencrypt.conf;"
```

TLS certificates for required gitlab groups/users can be added by using altnames like in following config:

```
letsencrypt['alt_names'] = %w(group1.gitlab.pages.tld grpup2.gitlab.pages.tld)
pages_nginx['ssl_certificate'] = '/etc/gitlab/ssl/gitlab.io.ki.crt'
pages_nginx['ssl_certificate_key'] = '/etc/gitlab/ssl/gitlab.io.ki.key'

```
