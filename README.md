# drone-s3-bash-cache

Inspired by https://github.com/Drillster/drone-volume-cache

This is a Drone cache written in Bash that compresses paths set using "mount",
and uploads the result to an Amazon S3 bucket. It is specifically designed for
our narrow use case and so probably isn't that useful for other people.

It replaces the official [S3 cache plugin](https://github.com/drone-plugins/drone-s3-cache).

My motivation for writing my own cache plugin was mostly for simplicity. I was
also after performance gains as I was seeing slow unpack times with the official
plugin and was finding it difficult to debug.

It uses [s3cmd](https://github.com/s3tools/s3cmd) for the S3 operation.

For compression it uses [pigz](https://zlib.net/pigz/) since this is multithreaded
and we're compressing a lot of files in our cache.

Any cache expiry should be handled by S3 expiration settings.

## Docker

To build, run:

`docker build --rm -t surminus/drone-s3-bash-cache .`
