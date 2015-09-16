BASES=centos6 ubuntu-trusty debian
REPOS=pjsip asterisk chan_respoke

$(BASES):
	$(MAKE) $(foreach repo,$(REPOS),$@.$(repo))

$(foreach base,$(BASES),$(base)-dev):
	$(MAKE) $(foreach repo,$(REPOS),$@.$(repo))

$(foreach base,$(BASES),$(base).pjsip):
	docker build -f docker/pjsip/Dockerfile.$(basename $@) -t pjsip:$(basename $@) docker/pjsip

$(foreach base,$(BASES),$(base).asterisk):
	docker build -f docker/asterisk/Dockerfile.$(basename $@) -t asterisk:$(basename $@) docker/asterisk

$(foreach base,$(BASES),$(base).chan_respoke):
	docker build -f docker/chan_respoke/Dockerfile.$(basename $@) -t chan_respoke:$(basename $@) docker/chan_respoke

repos/pjsip:
	svn co http://svn.pjsip.org/repos/pjproject/trunk repos/pjsip

repos/asterisk:
	git clone https://gerrit.asterisk.org/asterisk $@

repos/chan_respoke:
	git clone git://github.com/respoke/chan_respoke.git $@

$(foreach base,$(BASES),$(base)-dev.pjsip): repos/pjsip
	./builder.sh $@

$(foreach base,$(BASES),$(base)-dev.asterisk): repos/asterisk
	./builder.sh $@

$(foreach base,$(BASES),$(base)-dev.chan_respoke): repos/chan_respoke
	./builder.sh $@

distclean:
	echo $(foreach base,$(BASES),pjsip:$(base)) \
		$(foreach base,$(BASES),pjsip-dev:$(base)) \
		$(foreach base,$(BASES),asterisk:$(base)) \
		$(foreach base,$(BASES),asterisk-dev:$(base)) \
		$(foreach base,$(BASES),chan_respoke:$(base)) \
		$(foreach base,$(BASES),chan_respoke-dev:$(base)) | \
		xargs -n 1 docker inspect -f '{{.Id}}' | \
		xargs docker rmi
