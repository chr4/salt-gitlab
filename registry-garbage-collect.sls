# Install systemd timer and service for registry garbage collection
/etc/systemd/system/gitlab-registry-garbage-collect.service:
  file.managed:
    - source: salt://{{ tpldir }}/registry-garbage-collect.service.jinja
    - template: jinja
    - defaults:
      delete_manifests: {{ salt['pillar.get']('gitlab:registry:garbage_collect:manifests', false) }}
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/gitlab-registry-garbage-collect.service

gitlab-registry-garbage-collect.timer:
  service.running:
    - enable: true
    - watch:
      - file: /etc/systemd/system/gitlab-registry-garbage-collect.timer
    - require:
      - file: /etc/systemd/system/gitlab-registry-garbage-collect.timer
      - cmd: systemctl daemon-reload
  file.managed:
    - name: /etc/systemd/system/gitlab-registry-garbage-collect.timer
    - source: salt://{{ tpldir }}/registry-garbage-collect.timer.jinja
    - template: jinja
    - defaults:
      on_calendar: {{ salt['pillar.get']('gitlab:registry:garbage_collect:on_calendar', '02:00') }}
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/gitlab-registry-garbage-collect.timer
