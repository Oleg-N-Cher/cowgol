hide = @

BOOTSTRAP = \
	cowboot bootstrap/bootstrap.lua bootstrap/cowgol.c bootstrap/cowgol.h

TEST_SRCS =	\
	$(wildcard tests/*.test.cow) \
	$(wildcard src/*.test.cow)

TEST_BINS = $(patsubst %.test.cow,.obj/%.test.exe,$(TEST_SRCS))
TEST_STAMPS = $(patsubst %.test.cow,.obj/%.stamp,$(TEST_SRCS))

TOKENISER_SRCS = \
	src/string_lib.cow \
	src/ctype_lib.cow \
	src/numbers_lib.cow \
	src/things.cow \
	src/tokeniser/strings.cow \
	src/tokeniser/lexer.cow \
	src/_token_names.cow \
	src/tokeniser/tokeniser.cow \
	src/_token_maker.cow \
	src/tokeniser/main.cow

PARSER_SRCS = \
	src/string_lib.cow \
	src/ctype_lib.cow \
	src/numbers_lib.cow \
	src/things.cow \
	src/_token_names.cow \
	src/iops.cow \
	src/parser/tokenreader.cow \
	src/parser/symbols.cow \
	src/parser/iopwriter.cow \
	src/parser/main.cow

THINGSHOWER_SRCS = \
	src/string_lib.cow \
	src/things.cow \
	src/utils/stringtable.cow \
	src/thingshower/thingshower.cow

IOPSHOWER_SRCS = \
	src/string_lib.cow \
	src/iops.cow \
	src/things.cow \
	src/utils/stringtable.cow \
	src/utils/iopreader.cow \
	src/iopshower/iopshower.cow

all: tests bin/tokeniser bin/parser bin/thingshower bin/iopshower

bin/tokeniser: $(TOKENISER_SRCS) $(BOOTSTRAP)
	@echo BUILD $@
	@mkdir -p $(dir $@)
	$(hide) ./cowboot -o $@ $(TOKENISER_SRCS)

bin/parser: $(PARSER_SRCS) $(BOOTSTRAP)
	@echo BUILD $@
	@mkdir -p $(dir $@)
	$(hide) ./cowboot -o $@ $(PARSER_SRCS)

bin/thingshower: $(THINGSHOWER_SRCS) $(BOOTSTRAP)
	@echo BUILD $@
	@mkdir -p $(dir $@)
	$(hide) ./cowboot -o $@ $(THINGSHOWER_SRCS)

bin/iopshower: $(IOPSHOWER_SRCS) $(BOOTSTRAP)
	@echo BUILD $@
	@mkdir -p $(dir $@)
	$(hide) ./cowboot -o $@ $(IOPSHOWER_SRCS)

.phony: tests
tests: $(TEST_STAMPS)

$(TEST_BINS) parser: cowboot bootstrap/bootstrap.lua bootstrap/cowgol.c bootstrap/cowgol.h
$(TEST_BINS): tests/_test.cow
.obj/src/numbers_lib.test.exe: src/numbers_lib.cow
.obj/src/string_lib.test.exe: src/string_lib.cow

.PRECIOUS: $(TEST_BINS)
.obj/%.test.exe: %.test.cow
	@echo BUILDTEST $@
	@mkdir -p $(dir $@)
	$(hide) ./cowboot -o $@ $(sort $(filter-out %.test.cow, $(filter %.cow, $^))) $<

.obj/%.stamp: .obj/%.test.exe
	@echo TEST $@
	@mkdir -p $(dir $@)
	$(hide) $<
	$(hide) touch $@

src/_token_names.cow: src/tokens.txt src/mk-token-names.awk
	@echo TOKEN_NAMES $@
	@mkdir -p $(dir $@)
	$(hide) awk -f src/mk-token-names.awk src/tokens.txt > src/_token_names.cow

src/_token_maker.cow: src/tokens.txt src/mk-token-maker.awk
	@echo TOKEN_MAKER $@
	@mkdir -p $(dir $@)
	$(hide) awk -f src/mk-token-maker.awk src/tokens.txt > src/_token_maker.cow

clean:
	$(hide) rm -rf .obj bin
