.PHONY: all tests run-cmd run-tests

TEST_SRCS := $(wildcard tests/*.c)
TESTS := $(TEST_SRCS:.c=.out)

SOBJS := client.so lpuvfs.so
PRELOAD := $(PWD)/client.so:$(PWD)/lpuvfs.so

CFLAGS := -g -std=gnu99 -fPIC

all: $(SOBJS)

int.o: int.c
	gcc $(CFLAGS) -c int.c -o int.o
ll.o: ll.c
	gcc $(CFLAGS) -c ll.c -o ll.o
canon.o: canon.c
	gcc $(CFLAGS) -c canon.c -o canon.o
vfs.o: vfs.c
	gcc $(CFLAGS) -c vfs.c -o vfs.o
lpuvfs.so: int.o ll.o canon.o vfs.o
	gcc -shared -fPIC int.o ll.o canon.o vfs.o -o lpuvfs.so

client.o: client.c
	gcc $(CFLAGS) -c client.c -o client.o
client.so: client.o
	gcc -shared -fPIC client.o -o client.so

%.out: %.c
	gcc $(CFLAGS) $< -o $@

find-syms:
	LD_DEBUG=all $(CMD) 2>&1 | grep 'Looking up' | grep -v ' _'

run-cmd: $(SOBJS)
	LD_PRELOAD=$(PRELOAD) $(CMD)
debug-cmd: $(SOBJS)
	LD_DEBUG=all LD_PRELOAD=$(PRELOAD) $(CMD)
run-tests: $(SOBJS) $(TESTS)
	LD_PRELOAD=$(PRELOAD) tests/open.out /fake/file1
	LD_PRELOAD=$(PRELOAD) tests/fopen.out /fake/file1
	LD_PRELOAD=$(PRELOAD) tests/dirlist.out /fake

clean:
	rm *.so *.o
	rm $(TESTS)
