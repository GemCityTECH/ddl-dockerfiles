#!/bin/sh

set -euo pipefail

apk update
apk cache clean
apk upgrade --no-cache
rm /var/cache/apk/*
