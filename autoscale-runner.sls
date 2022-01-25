# This state installs a gitlab runner which is designed to act as a bastion node
# for an autoscaling setup using docker-machine.
# See [https://github.com/chr4/salt-docker] for some useful substates to prepare
# the required docker base setup. In particular see states
#   - docker
#   - docker.login
#   - docker.machine
# In addition to installing the runner binary itself it supports the installation
# of a set of pre-registered runner configurations by populating the config.toml.

# Use the official Gitlab apt repository
gitlab-runner-repo:
  pkgrepo.managed:
    - name: deb https://packages.gitlab.com/runner/gitlab-runner/{{ grains['os']|lower }}/ {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/runner_gitlab-runner.list
    - key_url: https://packages.gitlab.com/gpg.key


# Install the runner
gitlab-runner:
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
  # ensure the service is down before updating the config below
  service.dead:
    - enable: false
    - require:
      - pkg: gitlab-runner


# TODO: deploy config.toml TODO
#/etc/gitlab-runner/config.toml:
#  file.managed: []


# now that everything is in place, ensure the service is up and running
#gitlab-runner-service:
#  service.running:
#    - name: gitlab-runner
#    - enable: true
#    - require:
#      - pkg: gitlab-runner
#      - file: /etc/gitlab-runner/config.toml
