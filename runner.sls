# Use the official Gitlab apt repository
gitlab-runner-repo:
  pkgrepo.managed:
    - name: deb https://packages.gitlab.com/runner/gitlab-runner/{{ grains['os']|lower }}/ {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/runner_gitlab-runner.list
    - key_url: https://packages.gitlab.com/runner/gitlab-runner/gpgkey

gitlab-runner:
  pkg.installed: []
  service.running:
    - enable: true
    - require:
      - pkg: gitlab-runner
