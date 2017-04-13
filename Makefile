CC ?= gcc
CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra -g -I.
LDFLAGS = -lpthread

GIT_HOOKS := .git/hooks/applied
OUT ?= .build

EXEC = tests/test_matrix

OBJS := \
		stopwatch.o \
		naive_transpose.o \
		sse_transpose.o

OBJS := $(addprefix $(OUT)/,$(OBJS))
deps := $(OBJS:%.o=%.o.d)

.PHONY: all
all: $(GIT_HOOKS) $(OUT) $(EXEC)

tests/test_matrix: $(OBJS) tests/test_matrix.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(OUT)/%.o: impl/%.c $(OUT)
	$(CC) $(CFLAGS) -c -o $@ -MMD -MF $@.d $<

$(OUT):
	@mkdir -p $@

check: $(EXEC)
	@for test in $^ ; \
	do \
		echo "Execute $$test..." ; $$test && echo "OK!\n" ; \
	done

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

clean:
	$(RM) $(EXEC) $(OBJS) $(deps)
	@rm -rf $(OUT)

-include $(deps)