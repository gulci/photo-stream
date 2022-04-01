ARG  BASE_IMAGE=ruby:3.0.3-alpine3.15
FROM ${BASE_IMAGE}

ENV VIPSVER 8.12.2
RUN apk update && apk upgrade &&\
    apk add --update --no-cache build-base glib-dev libexif-dev expat-dev tiff-dev jpeg-dev libgsf-dev git rsync lftp openssh \
    python3 py-pip py-cffi py-cryptography \
    && pip install --upgrade pip \
    && apk add --virtual build-deps gcc libffi-dev python3-dev linux-headers musl-dev openssl-dev \
    && pip install gsutil \
    && apk del build-deps \
    && rm -rf /var/cache/apk/*

RUN wget -O ./vips-$VIPSVER.tar.gz https://github.com/libvips/libvips/releases/download/v$VIPSVER/vips-$VIPSVER.tar.gz

RUN tar -xvzf ./vips-$VIPSVER.tar.gz && cd vips-$VIPSVER && ./configure && make && make install

COPY ./ /photo-stream 

WORKDIR /photo-stream

RUN mkdir -p photos/original

RUN mkdir -p /etc/periodic/1min/ && cp /photo-stream/crons/gsutil-rsync-cron /etc/periodic/1min/
RUN touch /var/log/gsutil-rsync-cron.log
RUN ./scripts/cron-setup.sh

RUN ruby -v && gem install bundler jekyll &&\
    bundle config --local build.sassc --disable-march-tune-native &&\
    bundle install

EXPOSE 4000

ENTRYPOINT /scripts/gsutil-rsync.sh & crond & bundle exec jekyll serve --host 0.0.0.0
