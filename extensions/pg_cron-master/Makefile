# src/test/modules/pg_cron/Makefile
EXTENSION = pg_cron
EXTVERSION = 1.0

DATA_built = $(EXTENSION)--$(EXTVERSION).sql
DATA = $(wildcard $(EXTENSION)--*--*.sql)

# compilation configuration
MODULE_big = $(EXTENSION)
OBJS = $(patsubst %.c,%.o,$(wildcard src/*.c))
libpq_srcdir=/home/agraph/AgensGraph/include/postgresql
PG_CPPFLAGS = -std=c99 -Wall -Wextra -Werror -Wno-unused-parameter -Wno-maybe-uninitialized -Wno-implicit-fallthrough -Iinclude -I/home/agraph/AgensGraph/include/postgresql -I/home/agraph/AgensGraph/include/postgresql/server -I/home/agraph/AgensGraph/include/postgresql/internal -I/home/agraph/AgensGraph/include
SHLIB_LINK = $(libpq)
EXTRA_CLEAN += $(addprefix src/,*.gcno *.gcda) # clean up after profiling runs

PG_CONFIG = pg_config
#PGXS := $(shell $(PG_CONFIG) --pgxs)
PGXS := /home/agraph/AgensGraph/lib/postgresql/pgxs/src/makefiles/pgxs.mk
include $(PGXS)

$(EXTENSION)--1.0.sql: $(EXTENSION).sql $(EXTENSION)--0.1--1.0.sql
	cat $^ > $@
