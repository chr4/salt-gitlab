# This state installs a gitlab-runner and optionally also deploys its configuration (config.toml)
# from pillar data.
#
# When this node is intended to serve as a bastion for a docker-machine based autoscaling cluster,
# that is when a config.toml is provided that contains a runner section of the following form, then
# the pillar key [gitlab-runner.needs-docker-machine=True] can be used to inject the correct state
# ordering dependencies.
#
#  [[runners]]
#    executor = "docker+machine"
#    ...
#
# See [https://github.com/chr4/salt-docker] for some useful substates to prepare the required
# docker base setup. In particular see states
#   - docker
#   - docker.login
#   - docker.machine

{# Optionally inject docker include #}
{% if salt['pillar.get']('gitlab-runner:docker-machine', False) %}
include:
  - docker
  - docker.machine
{% endif %}

# Use the official Gitlab apt repository
gitlab-runner-repo:
  pkgrepo.managed:
    - name: deb https://packages.gitlab.com/runner/gitlab-runner/{{ grains['os']|lower }}/ {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/runner_gitlab-runner.list
    - key_url: https://packages.gitlab.com/gpg.key

gitlab-runner:
{# Optionally inject docker dependencies #}
{% if salt['pillar.get']('gitlab-runner:docker-machine', False) %}
  pkg.installed:
    - require:
      - pkg: docker
      # ensure that docker-machine has been deployed
      - file: /usr/local/bin/docker-machine
      # the presence of the following files ensures that docker-machine was initialised correctly
      - file: /root/.docker/machine/certs/cert.pem
      - file: /root/.docker/machine/certs/ca.pem
      - file: /root/.docker/machine/certs/key.pem
      - file: /root/.docker/machine/certs/ca-key.pem
{% else %}
  pkg.installed: []
{% endif %}
{# Optionally deploy config #}
{% if salt['pillar.get']('gitlab-runner:config', none) is not none %}
  file.managed:
    - name: /etc/gitlab-runner/config.toml
    - user: root
    - group: root
    - mode: 600
    - contents_pillar: gitlab-runner:config
    - require:
      - pkg: gitlab-runner
{% endif %}
  service.running:
    - enable: true
    - require:
      - pkg: gitlab-runner

{# Optionally deploy custom systemd timeout override #}
{% if salt['pillar.get']('gitlab-runner:systemd-timeout-stop-sec', none) is not none %}
# Ensure that the gitlab-runner service terminates gracefully when stopped by systemd.
# See https://docs.gitlab.com/runner/configuration/init.html#overriding-systemd
/etc/systemd/system/gitlab-runner.service.d/kill.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - dir_mode: 755
    - require_in:
        - pkg: gitlab-runner
    - contents: |
        [Service]
        TimeoutStopSec={{ salt['pillar.get']('gitlab-runner:systemd-timeout-stop-sec') }}
        KillSignal=SIGQUIT
{% endif %}
