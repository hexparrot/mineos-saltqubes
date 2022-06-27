# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Copy over files in salt://skel to every server already created
# Ideal for allow/ban lists, oplists, etc.
#
# Execute:
#   qubesctl --skip-dom0 --targets=mineos-worker state.sls skel saltenv=user
##

{% set user = salt['pillar.get']('hosts:worker_username') %}

/home/{{ user }}:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}

{% if salt['file.directory_exists']("/home/"+user+"/minecraft") %}
/home/{{ user }}/minecraft:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
{% endif %}

{% set alldirs = salt['cmd.run']('ls -1 /home/'+user+'/minecraft/servers').splitlines() %}
{% for each_dir in alldirs %}
{% if salt['file.directory_exists']('/home/'+user+'/minecraft/servers/'+each_dir) %}

/home/{{ user }}/minecraft/servers/{{ each_dir }}:
  file.recurse:
    - user: {{ user }}
    - group: {{ user }}
    - source: salt://skel
    - include_empty: True

{% endif %}
{% endfor %}

