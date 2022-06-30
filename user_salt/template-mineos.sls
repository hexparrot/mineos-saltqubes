# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Update hq and workers with most recent gems, git repos, etc.
#
# Execute:
#   qubesctl --skip-dom0 --targets=mineos-hq,mineos-worker state.sls template-mineos saltenv=user
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

# symlink to repo from conventional location
/usr/games/minecraft:
  file.symlink:
    - target: /usr/local/games/minecraft

# destination for minio buckets
/var/games/volumes:
  file.symlink:
    - target: /rw/volumes

# symlink minio configuration to usrlocal
/etc/default/minio:
  file.symlink:
    - target: /usr/local/etc/minio

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

## Service Unit Files
/etc/systemd/system:
  file.recurse:
    - name: /etc/systemd/system
    - source: salt://serviceunits

## End Service Unit Files

## bind-dirs config
/usr/lib/qubes-bind-dirs.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644

/usr/lib/qubes-bind-dirs.d/90_qubes_rabbitmq.conf:
  file.managed:
    - contents:
      - "binds+=( '/var/lib/rabbitmq' )"
      - "binds+=( '/var/log/rabbitmq' )"

## End bind-dirs config
