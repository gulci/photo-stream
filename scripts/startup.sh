#!/bin/sh
/photo-stream/scripts/gsutil-rsync.sh
crond
bundle exec jekyll serve --host 0.0.0.0
