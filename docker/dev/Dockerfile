FROM node:12.5.0-alpine

RUN apk update && apk upgrade \
    && apk --no-cache add zsh python make g++ git unzip \
    && rm -rf /var/cache/apk/*

RUN npm install -g npx

RUN mkdir -p /app

ONBUILD ADD app /app/
WORKDIR /app

EXPOSE 3000
