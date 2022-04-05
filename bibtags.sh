#!/bin/sh
#
# Create an editor tags file out of the specified .bib files
#
# Copyright 1992-2022 Diomidis Spinellis
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#

set -euo pipefail

if [ -z "$1" ] ; then
  echo "Usage: $0 file ..." 1>&2
  exit 1
fi

awk '
  BEGIN { seen[""] = seen["\r"] = 1 }

  /^@/ && !seen[$2] {
    gsub("\r", "")
    seen[$2] = 1
    printf "%s\t%s\t?^%s?\n", $2, FILENAME, $0}' \
  FS='[,{ 	(]*' "$@" |
LC_ALL=C sort >tags
