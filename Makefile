CC ?= gcc
CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra -g -I.
LDFLAGS = -lpthread

GIT_HOOKS := .git/hooks/applied
OUT ?= .build

EXEC = \
	   tests/test_matrix \
	   naive_transpose \
	   sse_transpose \
	   sse_prefetch_transpose

OBJS := \
		stopwatch.o \
		naive_transpose.o \
		sse_transpose.o \
		sse_prefetch_transpose.o

OBJS := $(addprefix $(OUT)/,$(OBJS))
deps := $(OBJS:%.o=%.o.d)

.PHONY: all
all: $(GIT_HOOKS) $(OUT) $(EXEC)

tests/test_matrix: $(OBJS) tests/test_matrix.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%_transpose: $(OBJS) tests/test_matrix.c
	$(CC) $(CFLAGS) -D$(subst _transpose,,$@) -o $@ $^ $(LDFLAGS)

$(OUT)/%.o: impl/%.c $(OUT)
	$(CC) $(CFLAGS) -c -o $@ -MMD -MF $@.d $<

$(OUT):
	@mkdir -p $@

check: $(EXEC)
	@for test in $^ ; \
	do \
		echo "Execute $$test..." ; $$test && echo "OK!\n" ; \
	done
data: $(EXEC)
	for i in `seq 1 100`; do  \
		printf "$$i " >> time.txt ; \
		./naive_transpose >> time.txt ; \
		printf " " >> time.txt; \
		./sse_transpose >> time.txt; \
		printf " " >> time.txt; \
		./sse_prefetch_transpose >> time.txt; \
		printf "\n" >> time.txt ; \
	done 

plot: data
	gnuplot scripts/plot/plot.gp

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

clean:
	$(RM) $(EXEC) $(OBJS) $(deps)
	@rm -rf $(OUT)
	rm -f time.png time.txt
-include $(deps)
