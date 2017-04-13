CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra

GIT_HOOKS := .git/hooks/applied
OUT ?= .build

EXECUTABLE := tests/test_matrix

OBJS := \
		naive_transpose.o \
		sse_transpose.o \
		sse_prefetch_transpose

OBJS := $(addprefix $(OUT)/,$(OBJS))
deps := $(OBJS:%.o=%.o.d)

.PHONY: all
all: $(GIT_HOOKS) $(OUT) $(EXECUTABLE)

tests/%_transpose: $(OBJS) tests/%_transpose.c
	$(CC) $(CFLAGS) -c -o $@ $^

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