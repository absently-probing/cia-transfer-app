# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

CC=gcc
SRC := src
CFLAGS=-I$(SRC) -Wall -std=c99 -pedantic -shared
LFLAGS=
BIN_NAME := libc_types.so
TARGET  := c_files.c
SOURCES := $(wildcard src/*.c)
OBJECTS := $(patsubst %.c, %.o, $(SOURCES))


.PHONY: test test/tests

default: $(BIN_NAME)

$(OBJECTS): $(SRC)/%.o : $(SRC)/%.c
	$(CC) $(CFLAGS) $(LFLAGS) -c $< -o $@

$(TESTOBJ): $(TESTSRC)
	$(CC) $(CFLAGS) -c $(TESTSRC) $(LFLAGS) -o $@

$(BIN_NAME): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) $(LFLAGS) -o $@

test: test/tests

test/tests: $(TESTOBJECTS) $(TESTOBJ)
	$(CC) $(CFLAGS) $(TESTOBJECTS) $(LFLAGS) -o $@

clean:
	rm $(SRC)/*.o
	rm $(BIN_NAME)
