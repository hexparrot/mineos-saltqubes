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

{% if salt['cmd.run']('qubesdb-read /qubes-service/minio') == "1" %}

# bring over object store creds
/usr/local/etc/objstore.yml:
  file.managed:
    - source: salt://files/objstore.yml.j2
    - template: jinja

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

# bring over amqp (rabbitmq) creds
/usr/local/etc/amqp.yml:
  file.managed:
    - source: salt://files/amqp.yml.j2
    - template: jinja

run rabbitmq service at boot:
  file.append:
    - name: /rw/config/rc.local
    - text:
      - systemctl start rabbitmq-server
      - rabbitmq-plugins enable rabbitmq_management

rabbitmq-server:
  service.running

# create primary admin
{{ salt['pillar.get']('amqp:user') }}:
  rabbitmq_user.present:
    - password: {{ salt['pillar.get']('amqp:password') }}
    - force: True
    - tags:
      - administrator
    - perms:
      - '/':
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

# download mineos-ruby repository
mineos-repo:
  git.latest:
    - name: https://github.com/hexparrot/mineos-ruby
    - target: /usr/local/games/minecraft
    - rev: HEAD
    - force_reset: True

# symlink to persistent area for game data
/usr/games/minecraft:
  file.symlink:
    - target: /usr/local/games/minecraft

## update ruby
# update bundler
update bundler:
  cmd.run:
    - name: bundle update --bundler
    - cwd: /usr/local/games/minecraft

# update the rubies
gem update:
  cmd.run:
    - name: bundle update
    - cwd: /usr/local/games/minecraft

# now for user
{% for item in ('eventmachine','ox') %}
gemadd_{{ item }}:
  gem.installed:
    - name: {{ item }}
    - user: user
{% endfor %}
## end ruby

