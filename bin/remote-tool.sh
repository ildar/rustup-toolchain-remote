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
REMOTE_SHELL_STDIO_TRANS=${REMOTE_SHELL_STDIO_TRANS:-yes}
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

# FIXME: FW doesn't work yet
STDIO_TRANS_FW=cat
STDIO_TRANS_RE=cat
[ "$REMOTE_SHELL_STDIO_TRANS" = true ] && REMOTE_SHELL_STDIO_TRANS=yes
[ "$REMOTE_SHELL_STDIO_TRANS" = yes ] && \
  STDIO_TRANS_FW="sed s|$SYNC_SOURCE|$DEST_DIR|g" &&
  STDIO_TRANS_RE="sed s|$DEST_DIR|$SYNC_SOURCE|g"

if [ "$SYNC_CWD" = yes ] && [ -n "$DEST_DIR" ]; then
  $REMOTE_SHELL $REMOTE_SHELL_OPT "$REMOTE_HOST" -- mkdir -p "$DEST_DIR"
  rsync --rsh="$REMOTE_SHELL" \
    -a --delete --compress $RSYNC_PROGRESS --exclude "$SYNC_EXCLUDES" -- \
    "$SYNC_SOURCE"/. "$REMOTE_HOST":"$DEST_DIR"/
fi

# FIXME: FW doesn't work yet
#perl -MFcntl -e 'fcntl STDIN, F_SETFL, fcntl(STDIN, F_GETFL, 0) | O_NONBLOCK'
#$STDIO_TRANS_FW | \
$REMOTE_SHELL $REMOTE_SHELL_OPT "$REMOTE_HOST" -- $REMOTE_SHELL_SHELL_WRAP ". \$HOME/.cargo/env; cd \"$DEST_DIR\" 2>/dev/null;\"$TOOL_NAME\" $ARGS" | \
$STDIO_TRANS_RE

#FIXME add pulling the results
#FIXME add cleanup option

