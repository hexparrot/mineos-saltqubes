# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# qvm.mos-hq
# ============
#
# Update hq and workers with most recent gems, git repos, etc.
#
# Pillar data will also be merged if available within the ``qvm`` pillar key:
#   ``qvm:mos-hq``
#
# located in ``/srv/pillar/dom0/qvm/init.sls``
#
# Execute:
#   qubesctl state.sls mineos saltenv=user
##

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

# update mineos-ruby repository
mineos-repo:
  git.latest:
    - name: https://github.com/hexparrot/mineos-ruby
    - target: /usr/games/minecraft
    - rev: HEAD
    - force_reset: True

