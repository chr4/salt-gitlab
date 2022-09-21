# Gitlab CE salt formula

This formula installs and configures [Gitlab Community Edition](https://gitlab.org).

See `pillar.example` for configuration options.


## gitlab:registry-garbage-collect

This formula will clean up unused images from Gitlab Registry every night.

It calls `gitlab-ctl registry-garbage-collect` via a systemd service.

You can configure it to also delete untagged manifests and the time it will be run (if needed) via pillars, see [pillar.example](pillar.example) for details.



# Gitlab CI Runner

`gitlab-runner` can be installed from the official repository using the `gitlab.runner` state.

It is possible to optionally deploy a full, possibly pre-registered, runner configuration through `gitlab-runner.config`.
When omitted, the runner is set up in pristine state and must be registered manually (see below).
Besides the runner `config.toml` it is also possible to deploy a custom systemd timeout override.

For the special case where a provided `config.toml` utilises a _docker-machine_ executor there is a separate boolean key `gitlab-runner.docker-machine` that necessarily must be set to `True` such that the underlying docker requirements can be included.
The injected dependency assumes the presence of exactly the following docker formula: https://github.com/chr4/salt-docker.

## Registering CI Runners

To register a runner with a Gitlab instance, use `gitlab-runner register` to negotiate a fresh runner token and a skeleton `config.toml`.
The command is interactive, and supports a wide spectrum of options.
Even more options can then be manually entered/adjusted in the generated config.
See the [offical runner docs](https://docs.gitlab.com/runner/) for details.

For later reference, here's some example code of how to potentially automate registration. This is not done, as the registration posibilities are pretty vast:

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
