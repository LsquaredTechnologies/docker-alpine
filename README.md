## Introduction 

This is a customized Alpine Linux Docker image.

# Usage

```Dockerfile
FROM lsquared/alpine:3.5
RUN apk add --no-cache mysql-client
```

## Build

Run build.sh from the master branch.

## Contribute

1. Add another version/tag

If you want to add a new version or tag, simply duplicate a folder in the `versions` folder.
Change the `Dockerfile` and `options` files to your needs and re-build.

1. Modify tags

In `options` files, it's possible to change the tags for the generated images.
E.g.

- in `alpine-3.4`, we use this tag: `lsquared/alpine:3.4`
- in `alpine-3.5`, we use this tag: `lsquared/alpine:3.5`
- in `alpine-3.6`, we use this tag: `lsquared/alpine:3.6`
- in `alpine-3.7`, we use this tags: `lsquared/alpine:3.7` and `lsquared/alpine:latest`
- in `alpine-3.8`, we use this tags: `lsquared/alpine:3.8` and `lsquared/alpine:edge`

You can add as many tags as you want.

1. Modify image contents

TODO modify the `mkimage-alpine.sh` file
