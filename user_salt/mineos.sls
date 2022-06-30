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

create firewall vm:
  qvm.present:
    - name: {{ salt['pillar.get']('hosts:network') }}
    - template: fedora-35
    - label: green

turn on firewall service:
  qvm.service:
    - name: {{ salt['pillar.get']('hosts:network') }}
    - enable:
      - qubes-firewall
      - qubes-network

let mos-firewall provide network:
  qvm.prefs:
    - name: {{ salt['pillar.get']('hosts:network') }}
    - provides-network: True

update standalone template:
  cmd.run:
    - name: qubesctl --skip-dom0 --targets=mos-template-tmp state.sls template-mineos saltenv=user

clone vm to templatevm:
  cmd.run:
    - name: qvm-clone -C TemplateVM mos-template-tmp mos-template

mos-template-tmp:
  qvm.absent

create hq appvm:
  qvm.present:
    - name: {{ salt['pillar.get']('hosts:hq') }}
    - template: mos-template
    - label: green

turn on hq services:
  qvm.service:
    - name: {{ salt['pillar.get']('hosts:hq') }}
    - enable:
      - rabbitmq-server
      - minio

{% for host in salt['pillar.get']('hosts:satellites') %}
new worker {{ host }}:
  qvm.present:
    - name: {{ host }}
    - template: mos-template
    - label: green

# qubes rpc bind workers to hq
{{ host }} tcp to hq:
  file.prepend:
    - name: /etc/qubes-rpc/policy/qubes.ConnectTCP
    - text:
      - {{ host }} @default allow,target={{ salt['pillar.get']('hosts:hq') }}
{% endfor %}

{% set VMS = [salt['pillar.get']('hosts:hq')] + salt['pillar.get']('hosts:satellites') %}

{% for vm in VMS %}
change {{vm}} netvm:
  qvm.prefs:
    - name: {{ vm }}
    - netvm: {{ salt['pillar.get']('hosts:network') }}

{% endfor %}

run mineos-update on all vms:
  cmd.run:
    - name: qubesctl --skip-dom0 --targets={{ ','.join(VMS) }} state.sls mineos-update saltenv=user

download profiles on hq:
  cmd.run:
    - name: qubesctl --skip-dom0 --targets={{ salt['pillar.get']('hosts:hq') }} state.sls profiles saltenv=user

