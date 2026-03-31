#!/usr/bin/env bash
set -euo pipefail

./generate.sh
git diff
