# Setup official gitlab community repository
gitlab_repo:
  pkgrepo.managed:
    - name: deb https://packages.gitlab.com/gitlab/gitlab-ce/ubuntu/ {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/gitlab_gitlab-ce.list
    - key_url: https://packages.gitlab.com/gpg.key
    - require_in:
      - pkg: gitlab-ce

gitlab-ce:
  pkg.installed: []

/etc/gitlab/gitlab.rb:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://{{ tpldir }}/gitlab.rb.jinja
    - template: jinja
    - require:
      - pkg: gitlab-ce
  cmd.run:
    - name: gitlab-ctl reconfigure
    - onchanges:
      - file: /etc/gitlab/gitlab.rb
