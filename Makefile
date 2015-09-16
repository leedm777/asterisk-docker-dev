BASES=centos6 ubuntu-trusty debian
REPOS=pjsip asterisk chan_respoke

$(BASES):
	$(MAKE) $(foreach repo,$(REPOS),$@.$(repo))

$(foreach base,$(BASES),$(base).pjsip):
	docker build -f docker/pjsip/Dockerfile.$(basename $@) -t pjsip:$(basename $@) docker/pjsip

$(foreach base,$(BASES),$(base).asterisk):
	docker build -f docker/asterisk/Dockerfile.$(basename $@) -t asterisk:$(basename $@) docker/asterisk

$(foreach base,$(BASES),$(base).chan_respoke):
	docker build -f docker/chan_respoke/Dockerfile.$(basename $@) -t chan_respoke:$(basename $@) docker/chan_respoke

repos/pjproject:
	svn co http://svn.pjsip.org/repos/pjproject/trunk repos/pjproject

repos/asterisk:
	git clone https://gerrit.asterisk.org/asterisk $@

repos/chan_respoke:
	git clone git://github.com/respoke/chan_respoke.git $@

$(foreach base,$(BASES),$(base).pjsip-builder): repos/pjproject
	docker build -f docker/pjsip/Dockerfile.$(basename $@)-builder -t pjsip-builder:$(basename $@) docker/pjsip
	docker ps -qa --filter name=pjsip-builder | xargs docker rm
	docker run --name pjsip-builder \
		-v $$(pwd)/repos/pjproject:/usr/src/pjproject \
		pjsip-builder:$(basename $@) \
		/build-pjsip
	docker commit \
		--author "David M. Lee, II <dlee@digium.com>" \
		-c 'CMD [/bin/bash]' \
		pjsip-builder pjsip:${BASE}
	docker rm pjsip-builder

$(foreach base,$(BASES),$(base).asterisk-builder): repos/asterisk

$(foreach base,$(BASES),$(base).chan_respoke-builder): repos/chan_respoke

distclean:
	echo $(foreach base,$(BASES),pjsip:$(base)) \
		$(foreach base,$(BASES),pjsip-builder:$(base)) \
		$(foreach base,$(BASES),asterisk:$(base)) \
		$(foreach base,$(BASES),asterisk-builder:$(base)) \
		$(foreach base,$(BASES),chan_respoke:$(base)) \
		$(foreach base,$(BASES),chan_respoke-builder:$(base)) | \
		xargs -n 1 docker inspect -f '{{.Id}}' | \
		xargs docker rmi
