# This helper state can be used to deploy custom systemd options for the gitlab-runner service

include:
  - gitlab.runner

# Ensure that the gitlab-runner service terminates gracefully when stopped
# by systemd. See https://docs.gitlab.com/runner/configuration/init.html#overriding-systemd
# The long (2h) timeout ensures that started CI jobs are allowed to run to completion.
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
        TimeoutStopSec=7200
        KillSignal=SIGQUIT
