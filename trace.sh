#!/bin/sh

drv=$(nix-instantiate --show-trace --arg pkg "$*" $(dirname $(realpath --canonicalize-existing $0))/build-agent) || exit

nix-store --realise "$drv"

nix-store --read-log "$drv" | sed -n '
	1,/^===== begin autobake-agent summary =====$/d
	/^===== end autobake-agent summary =====$/q
	p
' | less
