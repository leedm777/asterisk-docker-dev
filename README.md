# Asterisk docker dev

Scripts for using Docker for cross-distro Asterisk development.

## prerequisites

These scripts utilize Docker, so you need to have it installed. See the [Docker docs][] for 
installation instructions. Before proceeding, you should be able to run `docker images` to 
see a list of images docker knows about.

## quick start

```bash
# builds PJSIP, Asterisk and chan_respoke for Trusty
$ make ubuntu-trusty

# Build chan_respoke from git, using a builder container and incremental compilation
$ make ubuntu-trusty-dev:chan_respoke

# And you can do the same for centos6
$ make centos6
```

## developing chan_respoke

One great use of this project is for doing chan_respoke development on a non-linux machine.
The Makefile contains "-dev" targets that will utilize the `builder.sh` script. This script
creates a Docker image that knows to build the target image from source code on your local
computer, instead of source code pulled inside the running container. These "builder" images
are very quick to rebuild, and thus make local development a breeze.

To begin development of chan_respoke, run the following:

```bash
make ubuntu-trusty.pjsip ubuntu-trusty.asterisk ubuntu-trusty-dev.chan_respoke
```

This will get you a base set of images for pjsip, asterisk, and chan_respoke, and clone the
chan_respoke repo onto your local computer at `repos/chan_respoke`. Then you can just make
changes to the source in the `repos/chan_respoke` directory, then run:

```bash
make ubuntu-trusty-dev.chan_respoke
```

to re-build the image with your modified source.

## license
[MIT](LICENSE.txt)

[Docker docs]: https://docs.docker.com/
