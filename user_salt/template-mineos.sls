# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Update hq and workers with most recent gems, git repos, etc.
#
# Execute:
#   qubesctl --skip-dom0 --targets=mineos-hq,mineos-worker state.sls mineos-update saltenv=user
##

install main packages:
  pkg.installed:
    - pkgs:
      - screen
      - wget
      - git
      - tree
      - rsync
      - rdiff-backup
      - rabbitmq-server
      - pam-devel
      - ruby
      - ruby-devel
      - java-latest-openjdk
      - net-tools
      - telnet

# ruby gems installed
{% for item in ('inifile','get_process_mem','minitar','eventmachine','bunny','usagewatch','airborne','async_sinatra','thin','aws-sdk-s3','sinatra-websocket','bcrypt','httparty','rpam2','rubyzip','ox') %}
{{item}}:
  gem.installed:
    - user: root
{% endfor %}

# create minio-user account
minio-user:
  user.present:
    - fullname: Minio Service User
    - shell: /usr/sbin/nologin
    - createhome: True
    - system: True

# install minio from direct download
minio:
  cmd.run:
    - name: wget -nc -q -O /usr/bin/minio https://dl.min.io/server/minio/release/linux-amd64/minio
    - creates: /usr/bin/minio

# ensure minio is executable
/usr/bin/minio:
  file.managed:
    - owner: minio-user
    - mode: 550

# symlink to persistent area for game data
/var/games/minecraft:
  file.symlink:
    - target: /rw/vargames/minecraft

# destination for minio buckets
/var/games/volumes:
  file.symlink:
    - target: /rw/volumes

# default minio configuration
/etc/default/minio:
  file.managed:
    - contents:
      - MINIO_VOLUMES="/rw/volumes"
      - MINIO_OPTS="--address localhost:9000"

# download and install minio cli browser
mc_miniobrowser:
  cmd.run:
    - name: wget -nc -q -O /usr/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
    - creates: /usr/bin/mc

# ensure mc is executable
/usr/bin/mc:
  file.managed:
    - owner: minio-user
    - mode: 550

# append system services for minio
/etc/systemd/system/minio.service:
  file.managed:
    - source: salt://files/minio.service

# download mineos-ruby repository
mineos-repo:
  git.latest:
    - name: https://github.com/hexparrot/mineos-ruby
    - target: /usr/games/minecraft
    - rev: HEAD
    - force_reset: True

