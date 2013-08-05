#!/bin/bash
set -e
p="${1:-${PORT:-8888}}"
[ -e pipe ] && rm -f pipe; mkfifo pipe
trap 'rm -f pipe' EXIT
while true; do nc -l "$p" < pipe | ./server.bash > pipe; done
