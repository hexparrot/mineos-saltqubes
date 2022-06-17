# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Update hq and workers with most recent gems, git repos, etc.
#
# Execute:
#   qubesctl --skip-dom0 --targets=mineos-hq,mineos-worker state.sls mineos-update saltenv=user
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

