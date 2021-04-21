#!/bin/bash -e

TOOL_BASE_DIR=`dirname "$0"`/..
TOOL_NAME=`basename "$0"`
ARGS="$*"

[[ -s "$TOOL_BASE_DIR"/config ]] &&
  . "$TOOL_BASE_DIR"/config

REMOTE_HOST=${REMOTE_HOST:-localhost}
REMOTE_SHELL=${REMOTE_SHELL:-ssh}
REMOTE_SHELL_SHELL_OPT=${REMOTE_SHELL_SHELL_OPT:-}
SYNC_CWD=${SYNC_CWD:-yes}
SYNC_QUIET=${SYNC_QUIET:-no}
SYNC_EXCLUDES=${SYNC_EXCLUDES:-target}
DEST_DIR=${DEST_DIR:-/tmp/remote-builds/`basename "$PWD"`/}

[ "$SYNC_CWD" = true ] && SYNC_CWD=yes
[ "$SYNC_QUIET" = true ] && SYNC_QUIET=yes
[ "$SYNC_QUIET" = yes ] || RSYNC_PROGRESS="--info=progress2"

if [ "$SYNC_CWD" = yes -a \( -e .git -o -e Cargo.toml \) ]; then
  $REMOTE_SHELL $REMOTE_SHELL_SHELL_OPT -- mkdir -p "$DEST_DIR"
  rsync --rsh="$REMOTE_SHELL" \
    -a --delete --compress $RSYNC_PROGRESS --exclude "$SYNC_EXCLUDES" -- \
    . "$REMOTE_HOST":"$DEST_DIR"
fi

$REMOTE_SHELL $REMOTE_SHELL_SHELL_OPT -- sh -l -c "cd \"$DEST_DIR\" 2>/dev/null;\"$TOOL_NAME\" $ARGS"

#FIXME add pulling the results
#FIXME add cleanup option

