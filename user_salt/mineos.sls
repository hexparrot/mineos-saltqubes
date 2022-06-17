# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Installs 'mineos-hq' and 'mineos-worker' AppVMs, as well as the 
# templateVM 'mos-template' that supports them.
#
# located in ``/srv/salt/``
#
# Execute:
#   qubesctl state.sls mineos saltenv=user
##

create ruby template:
  qvm.present:
    - name: mos-template-tmp
    - class: StandaloneVM
    - template: fedora-35
    - label: green

update standalone template:
  cmd.run:
    - name: qubesctl --skip-dom0 --targets=mos-template-tmp state.sls template-mineos saltenv=user

clone vm to templatevm:
  cmd.run:
    - name: qvm-clone -C TemplateVM mos-template-tmp mos-template

create hq appvm:
  qvm.present:
    - name: mineos-hq
    - template: mos-template
    - label: green

turn on hq services:
  qvm.service:
    - name: mineos-hq
    - enable:
      - rabbitmq-server
      - minio

create worker vm:
  qvm.present:
    - name: mineos-worker
    - template: mos-template
    - label: green

