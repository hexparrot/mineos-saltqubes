# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# qvm.mos-hq
# ============
#
# Installs 'mineos-hq' and 'mineos-worker' AppVMs, as well as the 
# templateVM that supports them.
#
# Pillar data will also be merged if available within the ``qvm`` pillar key:
#   ``qvm:mos-hq``
#
# located in ``/srv/pillar/dom0/qvm/init.sls``
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

clone vm to templatevm:
  cmd.run:
    - name: qvm-clone -C TemplateVM mos-template-tmp mos-template

give templatevm network access:
  qvm.prefs:
    - name: mos-template
    - netvm: sys-firewall

remove tmp vm:
  cmd.run:
    - name: qvm-remove -f mos-template-tmp

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

