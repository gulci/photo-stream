#!/bin/sh
gsutil -o Credentials:gs_service_key_file=/photo-stream/gsa.json rsync -d -r gs://$PHOTO_STREAM_BUCKET /photo-stream/photos/original
