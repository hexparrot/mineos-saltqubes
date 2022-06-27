# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Copy over files in salt://skel to every server already created
# Ideal for allow/ban lists, oplists, etc.
#
# Execute:
#   qubesctl --skip-dom0 --targets=mineos-worker state.sls skel saltenv=user
##

{% set alldirs = salt['cmd.run']('ls -1a -A /home/user/minecraft/servers/').split('\n') %}
{% for each_dir in alldirs %}

copy file skeleton to server {{ each_dir }}:
  file.recurse:
    - user: user
    - group: user
    - name: /home/user/minecraft/servers/{{ each_dir }}/
    - source: salt://skel
    - include_empty: True

{% endfor %}

