# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Update hq and workers with most recent gems, git repos, etc.
#
# Execute:
#   qubesctl --skip-dom0 --targets=mineos-hq,mineos-worker state.sls mineos-update saltenv=user
##

/rw/config/rc.local:
  file.managed:
    - mode: 0755

# bring over amqp (rabbitmq) creds (all nodes)
/usr/local/etc/amqp.yml:
  file.managed:
    - source: salt://files/amqp.yml.j2
    - template: jinja

# bring over object store creds (all nodes)
/usr/local/etc/objstore.yml:
  file.managed:
    - source: salt://files/objstore.yml.j2
    - template: jinja

{% if salt['cmd.run']('qubesdb-read /qubes-service/minio') == "1" %}

/rw/volumes:
  file.directory:
    - user: minio-user
    - makedirs: True

# reload new unit files for systemd
systemctl_reload:
  module.run:
    - name: service.systemctl_reload

run minio service at boot:
  file.append:
    - name: /rw/config/rc.local
    - text:
      - systemctl start minio

minio:
  service.running

{% else %}

# stuff to run when it is an ordinary worker
# that needs to connect to minio
run minio tcp connector at boot:
  file.append:
    - name: /rw/config/rc.local
    - text:
      - systemctl start qubes-minio.socket

qubes-minio.socket:
  service.running

{% endif %}

{% if salt['cmd.run']('qubesdb-read /qubes-service/rabbitmq-server') == "1" %}

run rabbitmq service at boot:
  file.append:
    - name: /rw/config/rc.local
    - text:
      - systemctl start rabbitmq-server
      - rabbitmq-plugins enable rabbitmq_management

rabbitmq-server:
  service.running

/mineos:
  rabbitmq_vhost.present

# create primary admin
{{ salt['pillar.get']('amqp:user') }}:
  rabbitmq_user.present:
    - password: {{ salt['pillar.get']('amqp:pass') }}
    - force: True
    - tags:
      - administrator
    - perms:
      - '/':
        - ".*"
        - ".*"
        - ".*"
      - '/mineos':
        - ".*"
        - ".*"
        - ".*"
    - runas: rabbitmq

{% else %}

# stuff to run when it is an ordinary worker
# that needs to conenct to amqp
run rabbitmq tcp connector at boot:
  file.append:
    - name: /rw/config/rc.local
    - text:
      - systemctl start qubes-amqp.socket

qubes-amqp.socket:
  service.running

{% endif %}

# currently designating the rabbitmq server to be the hq.
{% if salt['cmd.run']('qubesdb-read /qubes-service/rabbitmq-server') == "1" %}

start mineos-hq daemon:
  file.append:
    - name: /rw/config/rc.local
    - text:
      - systemctl start mineos-hq

{% else %}

start mrmanager daemon:
  file.append:
    - name: /rw/config/rc.local
    - text:
      - systemctl start mineos-mrmanager

{% endif %}

# download mineos-ruby repository
mineos-repo:
  git.latest:
    - name: https://github.com/hexparrot/mineos-ruby
    - target: /usr/local/games/minecraft
    - rev: HEAD
    - force_reset: True

# now for user
{% for item in ('eventmachine','ox') %}
gemadd_{{ item }}:
  gem.installed:
    - name: {{ item }}
    - user: user
{% endfor %}
## end ruby

