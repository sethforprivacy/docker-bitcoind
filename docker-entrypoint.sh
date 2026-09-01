#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
	set -- btc_oneshot "$@"
fi

# Allow the container to be started with `--user`, if running as root drop privileges
if [ "$1" = 'btc_oneshot' -a "$(id -u)" = '0' ]; then
	# Chown only the data-dir subtree (not the whole mounted volume), and
	# only when a host-mounted volume arrives with different ownership.
	if [ -d "$HOME/.bitcoin" ] && [ "$(stat -c %u:%g "$HOME/.bitcoin")" != "$(id -u bitcoin):$(id -g bitcoin)" ]; then
		chown -R bitcoin "$HOME/.bitcoin"
	fi
	exec gosu bitcoin "$0" "$@"
fi

# If not root (i.e. docker run --user $USER ...), then run as invoked
exec "$@"

