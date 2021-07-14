#!/bin/bash -e

TOOL_BASE_DIR=`dirname "$0"`/..
TOOL_NAME=`basename "$0"`
ARGS="$*"

[[ -s "$TOOL_BASE_DIR"/config ]] &&
  . "$TOOL_BASE_DIR"/config

REMOTE_HOST=${REMOTE_HOST:-localhost}
REMOTE_SHELL=${REMOTE_SHELL:-ssh}
REMOTE_SHELL_OPT=${REMOTE_SHELL_OPT:-}
REMOTE_SHELL_SHELL_WRAP=${REMOTE_SHELL_SHELL_WRAP:-}
SYNC_CWD=${SYNC_CWD:-yes}
SYNC_QUIET=${SYNC_QUIET:-yes}
SYNC_EXCLUDES=${SYNC_EXCLUDES:-target}
DEST_DIR=${DEST_DIR:-/tmp/remote-builds/`basename "$PWD"`}

[ "$SYNC_CWD" = true ] && SYNC_CWD=yes
[ "$SYNC_QUIET" = true ] && SYNC_QUIET=yes
[ "$SYNC_QUIET" = yes ] || RSYNC_PROGRESS="--info=progress2"

SYNC_SOURCE="$PWD"
if [ -e .git ] || [ -e Cargo.toml ] || [ -n "`echo $ARGS | grep Cargo.toml`" ]; then
  for a in $ARGS; do
    echo "$a" | grep -q Cargo.toml &&
      SYNC_SOURCE=`dirname "$a"` &&
      DEST_DIR=/tmp/remote-builds/`basename "$SYNC_SOURCE"`
  done
  ARGS=`echo "$ARGS" | sed "s|$SYNC_SOURCE|$DEST_DIR|g"`
else
  unset DEST_DIR
fi

if [ "$SYNC_CWD" = yes ] && [ -n "$DEST_DIR" ]; then
  $REMOTE_SHELL $REMOTE_SHELL_OPT "$REMOTE_HOST" -- mkdir -p "$DEST_DIR"
  rsync --rsh="$REMOTE_SHELL" \
    -a --delete --compress $RSYNC_PROGRESS --exclude "$SYNC_EXCLUDES" -- \
    "$SYNC_SOURCE"/. "$REMOTE_HOST":"$DEST_DIR"/
fi

$REMOTE_SHELL $REMOTE_SHELL_OPT "$REMOTE_HOST" -- $REMOTE_SHELL_SHELL_WRAP ". \$HOME/.cargo/env; cd \"$DEST_DIR\" 2>/dev/null;\"$TOOL_NAME\" $ARGS"

#FIXME add pulling the results
#FIXME add cleanup option

