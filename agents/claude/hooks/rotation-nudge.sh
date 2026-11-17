#!/usr/bin/env bash
# Wrapper: runs the hook of the same name from the coordinating skill (dancorreia-swe/skills),
# which agents-sync installs into ~/.agents/skills for every target user. The hook's code lives
# only there; edit it in the skills repo. Skill not installed yet: allow (exit 0).
h="$HOME/.agents/skills/coordinating/hooks/$(basename "$0")"
[ -r "$h" ] || exit 0
exec bash "$h"
