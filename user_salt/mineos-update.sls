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
    - contents:
      - "amqp:"
      - "  host: {{ salt['pillar.get']('amqp:host') }}"
      - "  port: {{ salt['pillar.get']('amqp:port') }}"
      - "  user: {{ salt['pillar.get']('amqp:user') }}"
      - "  pass: {{ salt['pillar.get']('amqp:pass') }}"
      - "  vhost: {{ salt['pillar.get']('amqp:vhost') }}"

# bring over object store creds (all nodes)
/usr/local/etc/objstore.yml:
  file.managed:
    - contents:
      - "object_store:"
      - "  host: http://{{ salt['pillar.get']('object-store:host') }}:{{ salt['pillar.get']('object-store:port') }}"
      - "  access_key: {{ salt['pillar.get']('object-store:access_key') }}"
      - "  secret_key: {{ salt['pillar.get']('object-store:secret_key') }}"

{% if salt['cmd.run']('qubesdb-read /qubes-service/minio') == "1" %}

# minio defaults
/usr/local/etc/minio:
  file.managed:
    - contents:
      - MINIO_VOLUMES="/rw/volumes"
      - MINIO_OPTS="--address {{ salt['pillar.get']('object-store:host') }}:{{ salt['pillar.get']('object-store:port') }} --console-address :{{ salt['pillar.get']('object-store:console') }}"
      - MINIO_ROOT_USER="{{ salt['pillar.get']('object-store:access_key') }}"
      - MINIO_ROOT_PASSWORD="{{ salt['pillar.get']('object-store:secret_key') }}"
    - owner: minio-user
    - mode: 400

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

## Start ruby stuff
# ruby gems installed
{% for item in ('inifile','get_process_mem','minitar','eventmachine','bunny','usagewatch','airborne','async_sinatra','thin','aws-sdk-s3','sinatra-websocket','bcrypt','httparty','rpam2','rubyzip','ox') %}
{{item}}:
  gem.installed:
    - user: root
{% endfor %}

# now for user
{% for item in ('eventmachine','ox') %}
gemadd_{{ item }}:
  gem.installed:
    - name: {{ item }}
    - user: user
{% endfor %}

# download mineos-ruby repository
mineos-repo:
  git.latest:
    - name: https://github.com/hexparrot/mineos-ruby
    - target: /usr/local/games/minecraft
    - rev: HEAD
    - force_reset: True

update bundler:
  cmd.run:
    - name: bundle update --bundler
    - cwd: /usr/local/games/minecraft

# install the rubies
install the bundle:
  cmd.run:
    - name: bundle install
    - cwd: /usr/local/games/minecraft

# now update them, for some reason
update bundle:
  cmd.run:
    - name: bundle update
    - cwd: /usr/local/games/minecraft
## End ruby stuff

