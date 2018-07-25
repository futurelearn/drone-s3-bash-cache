#!/bin/bash

set -e

if [ -z "$PLUGIN_MOUNT" ]; then
  echo "Must specify directories to cache. Exiting!"
  exit 1
fi

if [ -z "$PLUGIN_BUCKET" ]; then
  echo "Must provide S3 bucket name. Exiting!"
  exit 1
fi

VERBOSE=""

if [[ -n "$PLUGIN_VERBOSE" && "$PLUGIN_VERBOSE" == "true" ]]; then
  VERBOSE="-v"
fi

CACHE_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/$DRONE_BRANCH"
FALLBACK_PATH="$DRONE_REPO_OWNER/$DRONE_REPO_NAME/master"

PATHS_TO_TAR=$(echo $PLUGIN_MOUNT | sed 's/,/ /g')

echo "Starting at $(date)"

if [[ -n "$PLUGIN_REBUILD" && "$PLUGIN_REBUILD" == "true" ]]; then

  PATHS=""
  echo "Compressing selected paths:"
  for i in $PATHS_TO_TAR; do
    if test -e $i; then
      PATHS+=" ${i}"
      echo "Adding ${i}"
    else
      echo "Cannot find ${i}. Skipping."
    fi
  done

  if [[ $PATHS == "" ]]; then
    echo "No paths found for cache. Moving on..."
    exit 0
  else
    tar cf - $PATHS | pigz $VERBOSE > archive.tgz
  fi

  echo "Compression complete, uploading to S3"

  s3cmd $VERBOSE sync archive.tgz s3://$PLUGIN_BUCKET/$CACHE_PATH/archive.tgz

  echo "Upload completed!"

  echo "Finished! Exiting at $(date)" && exit 0
elif [[ -n "$PLUGIN_RESTORE" && "$PLUGIN_RESTORE" == "true" ]]; then

  if s3cmd get s3://$PLUGIN_BUCKET/$CACHE_PATH/archive.tgz archive.tgz; then
    echo "Cache downloaded successfully."
  elif s3cmd get s3://$PLUGIN_BUCKET/$FALLBACK_PATH/archive.tgz archive.tgz; then
    echo "Cache downloaded successfully."
  else
    echo "Cannot find cache. Skipping!"
    exit 0
  fi

  echo "Uncompressing cache file."
  unpigz $VERBOSE < archive.tgz | tar $VERBOSE -xC .
  echo "Cache uncompressed."

  echo "Finished! Exiting at $(date)" && exit 0
else
  echo "Must provide either restore or rebuild flag. Exiting!"
  exit 1
fi
