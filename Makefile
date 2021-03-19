PROJECT = apns

DEPS = gun jsx base64url

TEST_DEPS = katana_test katana mixer meck

dep_cowlib = git https://github.com/ninenines/cowlib 2.7.3
dep_gun = git https://github.com/ninenines/gun 1.3.3
dep_jsx = git https://github.com/talentdeficit/jsx v3.0.0
dep_base64url = git https://github.com/dvv/base64url 1.0.1

dep_katana_test = git https://github.com/inaka/katana-test 1.0.1
dep_katana = git https://github.com/inaka/erlang-katana 1.0.0
dep_mixer = git https://github.com/inaka/mixer 1.1.0
dep_meck = git https://github.com/eproxus/meck 0.9.0

ERLC_OPTS += -Werror +debug_info
ERLC_OPTS += -I deps

TEST_ERLC_OPTS += -Werror +debug_info
TEST_ERLC_OPTS += -I deps

CT_OPTS = -erl_args -config test/test.config
CT_LOGS_DIR = ctlogs

include $(if $(ERLANG_MK_FILENAME),$(ERLANG_MK_FILENAME),erlang.mk)
