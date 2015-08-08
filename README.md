# Asterisk docker dev

Scripts for using Docker for cross-distro Asterisk development.

Frequently, when developing Asterisk, it's useful to build/run/test on multiple
distros. Rather than having a bunch of virtual machines lying around, this repo
allows a local Asterisk repo to be built and run in [Docker][] containers.

These scripts are optimized for a build/run/test cycle, and are not recommended
for anything other than Asterisk development and testing.

These scripts also build an Asterisk image that has `chan_respoke` installed,
because [Respoke][] is pretty cool.

## Usage

```bash
$ git clone https://github.com/leedm777/asterisk-docker-dev
$ git clone https://gerrit.asterisk.org/asterisk
$ cd asterisk
# Develop; make changes; try things out
$ ../asterisk-docker-dev/build.sh
```

The resulting images are `asterisk:${FLAVOR}` and `chan_respoke:${FLAVOR}`.

## Options

Use the `FLAVOR` environment variable to test Asterisk on other distros.

 * `ubunty-trusty` (default)
 * `centos6`

## Notes

The Asterisk source tree is mounted as a volume, and built in place. The good
news is that this means that if you make incremental changes, it will rebuild
incrementally (instead of rebuilding from scratch as Docker normally likes to
do).

When switching flavors, it's recommended to `make distclean` in order to clear
out anything from the other distro.

The build also mounts a volume as a `ccache` directory, which may help build
speed in some circumstances.

 [Docker]: https://www.docker.com/
 [Respoke]: https://www.respoke.io/
