# Gitlab CE salt formula

This formula installs and configures [Gitlab Community Edition](https://gitlab.org).

See `pillar.example` for configuration options.


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
