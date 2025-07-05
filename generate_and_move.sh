#!/bin/bash
set -eu
out=$(realpath "$1")

# Generate ELF via docker and stream it into $tmp
docker exec csr-debug bash -c '
  export USER=root &>/dev/null
  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-} &>/dev/null
  set -eu &>/dev/null
  cd cascade-meta &>/dev/null
  source env.sh &>/dev/null
  tmpdir=$(mktemp -d) &>/dev/null
  CASCADE_JOBS=1 python3 fuzzer/do_genmanyelfs.py 1 "$tmpdir" &>/dev/null
  cat "$tmpdir"/risc0_0.elf
' >"$out"

##!/usr/bin/env bash
#set -eu
#out="$1"
#
## Use a temp file for atomic write
#tmp=$(mktemp)
#
## Call docker exec to generate one ELF input and stream it to $tmp
#if ! docker exec r0 bash -c '
#  export USER=root
#  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}
#  set -eu
#  cd cascade-meta &
#  source env.sh
#  tmpdir=$(mktemp -d)
#  CASCADE_JOBS=1 python3 fuzzer/do_genmanyelfs.py 1 "$tmpdir"
#  cat "$tmpdir"/risc0_0.elf
#' >"$tmp"; then
#  echo "Error: generator failed" >&2
#  rm -f "$tmp"
#  exit 1
#fi
#
## Validate that it’s a proper ELF file
#if file "$tmp" | grep -q ELF; then
#  mv "$tmp" "$out"
#else
#  echo "Error: output is not an ELF file" >&2
#  rm -f "$tmp"
#  exit 1
#fi

#
# #!/usr/bin/bash
# set -eu
# out="$1"
#
# # generate one input into the host‐mounted ~/.tube
# docker exec r0 bash -c '
#   cd cascade-meta &>/dev/null &&
#   source env.sh &>/dev/null &&
#   tmpdir=$(mktemp -d) &&
#   CASCADE_JOBS=1 python3 fuzzer/do_genmanyelfs.py 1 tmpdir &>/dev/null &&
#   cat tmpdir/risc0_0.elf
# ' >$out
