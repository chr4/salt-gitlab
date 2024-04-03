{% set edition = salt['pillar.get']('gitlab:edition', 'gitlab-ce') %}

# Setup official gitlab community repository
gitlab_repo:
  pkgrepo.managed:
    - name: deb https://packages.gitlab.com/gitlab/{{ edition }}/ubuntu/ {{ grains['oscodename'] }} main
    - file: /etc/apt/sources.list.d/gitlab_{{ edition }}.list
    - key_url: https://packages.gitlab.com/gpg.key
    - require_in:
      - pkg: {{ edition }}

{{ edition }}:
  pkg.installed: []

# Deploy signing_key.gpg if options are given in pillar.
# Make sure it's not existent if not.
{% if salt['pillar.get']('gitlab:gitaly:signing_key', None) != none %}
/etc/gitlab/gitaly-ui.key:
  file.managed:
    - user: git
    - group: root
    - mode: 600
    - contents_pillar: gitlab:gitaly:signing_key
    - require:
      - pkg: {{ edition }}
{% endif %}

/etc/gitlab/gitlab.rb:
  file.managed:
    - user: root
    - group: root
    - mode: 600 # Config file might contain credentials
    - source: salt://{{ tpldir }}/gitlab.rb.jinja
    - template: jinja
    - require:
      - pkg: {{ edition }}
  cmd.run:
    - name: gitlab-ctl reconfigure
    - onchanges:
      - file: /etc/gitlab/gitlab.rb

# In case /var/opt/gitlab/backups is a mountpoint, we need to make sure permissions are adjusted
/var/opt/gitlab/backups:
  file.directory:
    - user: git
    - group: root
    - mode: 0700
