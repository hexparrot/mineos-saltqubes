# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Update hq and workers with most recent gems, git repos, etc.
#
# Execute:
#   qubesctl --skip-dom0 --targets=mineos-hq,mineos-worker state.sls mineos-update saltenv=user
##

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

minio:
  service.running:
    - enable: True

{% else %}
# stuff to run when it is an ordinary worker
# that needs to conenct to minio
{% endif %}

{% if salt['cmd.run']('qubesdb-read /qubes-service/rabbitmq-server') == "1" %}

# bring over amqp (rabbitmq) creds
/usr/local/etc/amqp.yml:
  file.managed:
    - source: salt://files/amqp.yml.j2
    - template: jinja

rabbitmq-server:
  service.running:
    - enable: True

rabbitmq_management:
  rabbitmq_plugin.enabled: []

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
{% endif %}

## update ruby
# update bundler
update bundler:
  cmd.run:
    - name: bundle update --bundler
    - cwd: /usr/games/minecraft

# update the rubies
gem update:
  cmd.run:
    - name: bundle update
    - cwd: /usr/games/minecraft

# now for user
{% for item in ('eventmachine','ox') %}
gemadd_{{ item }}:
  gem.installed:
    - name: {{ item }}
    - user: user
{% endfor %}
## end ruby

