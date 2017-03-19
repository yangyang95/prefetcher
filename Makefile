CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra

GIT_HOOKS := .git/hooks/applied

EXECUTABLE := naive_transpose \
	 		 sse_transpose sse_prefetch_transpose

all: $(GIT_HOOKS) $(EXECUTABLE)

%_transpose: main.c
	$(CC) $(CFLAGS) -D$(subst _transpose,,$@) -o $@ main.c

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

clean:
	$(RM) $(EXECUTABLE)
