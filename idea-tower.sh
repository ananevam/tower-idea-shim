#! /usr/bin/env bash

# Tower.app gives us these parameters:
LOCAL="$1"
REMOTE="$2"

# Sanitize LOCAL path
if [[ ! "$LOCAL" =~ ^/ ]]; then
	LOCAL=$(echo "$LOCAL" | sed -e 's/^\.\///')
	LOCAL="$PWD/$LOCAL"
fi

# Sanitize REMOTE path
if [[ ! "$REMOTE" =~ ^/ ]]; then
	REMOTE=$(echo "$REMOTE" | sed -e 's/^\.\///')
	REMOTE="$PWD/$REMOTE"
fi

MERGING="$4"
BACKUP="/tmp/$(date +"%Y%d%m%H%M%S")"

APPLICATION_PATH="/Applications/IntelliJ IDEA 15.app"
CMD="/Applications/IntelliJ IDEA 15.app/Contents/MacOS/idea"

if [ -n "$MERGING" ]; then
  BASE="$3"
	MERGE="$4"

	# Sanitize BASE path
	if [[ ! "$BASE" =~ ^/ ]]; then
		BASE=$(echo "$BASE" | sed -e 's/^\.\///')
		BASE="$PWD/$BASE"

		if [ ! -f "$BASE" ]; then
			BASE=/dev/null
		fi
	fi

	# Sanitize MERGE path
	if [[ ! "$MERGE" =~ ^/ ]]; then
		MERGE=$(echo "$MERGE" | sed -e 's/^\.\///')
		MERGE="$PWD/$MERGE"

		if [ ! -f "$MERGE" ]; then
			# For conflict "Both Added", Git does not pass the merge param correctly in current versions
			MERGE=$(echo "$LOCAL" | sed -e 's/\.LOCAL\.[0-9]*//')
		fi
	fi

	sleep 1 # required to create different modification timestamp
	touch "$BACKUP"

  "$CMD" "merge" "$LOCAL" "$REMOTE" "$BASE" "$MERGE" 2>/dev/null
else
  "$CMD" "diff" "$LOCAL" "$REMOTE" 2>/dev/null
fi

if [ -n "$MERGING" ]; then
	# Check if the merged file has changed
	if [ "$MERGE" -ot "$BACKUP" ]; then
		exit 1
	fi
fi

exit 0
