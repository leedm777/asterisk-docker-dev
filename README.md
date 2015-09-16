# Asterisk docker dev

Scripts for using Docker for cross-distro Asterisk development.

I just reworked how these scripts work, so I should probably write some docs for
it. For now, here are some clues that might help you figure it out.

```bash
# builds PJSIP, Asterisk and chan_respoke for Trusty
$ make ubuntu-trusty

# Build chan_respoke from git, using a builder container and incremental
# compilation
$ make ubuntu-trusty-dev:chan_respoke

# And you can do the same for centos6
$ make centos6
```
