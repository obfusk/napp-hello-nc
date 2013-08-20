#!/bin/bash
set -e
p="${1:-${PORT:-8888}}" pipe1=pipe-$$-1 pipe2=pipe-$$-2 pid1= pid2=
rm -f pipe-$$-*; mkfifo "$pipe1" "$pipe2"
cleanup () {
  set +e
  echo "bye (pid1=$pid1, pid2=$pid2)"
  rm -f pipe-$$-*
  [ -z "$pid1" ] || kill "$pid1"
  [ -z "$pid2" ] || kill "$pid2"
}
trap cleanup EXIT
echo "Listening on $p"
while true; do
  nc -l "$p"    < "$pipe1" > "$pipe2" & pid1=$!
  ./server.bash > "$pipe1" < "$pipe2" & pid2=$!
  set +e; wait "$pid1"; ok1=$? pid1=; set -e
  set +e; wait "$pid2"; ok2=$? pid2=; set -e
  [ "$ok1" == 0 -a "$ok2" == 0 ]
done
