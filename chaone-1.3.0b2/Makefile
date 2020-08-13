# Generated automatically from Makefile.in by configure.
#
# Makefile for chaone
#

CC = gcc
DEFS =   -Wall -I/usr/include/libxml2 -I/usr/include -DKANJICODE=\"EUC-JP\" -DXSLFILE=\"/sp/ipa/syn/chaone/chaone-1.2.0b8/chaone_t_EUC-JP.xsl\"
LIBS =  -L/usr/lib -lxml2 -L/usr/lib -lxslt -lexslt

SRCS = chaone.c
OBJS = $(SRCS:.c=.o)
PROG = chaone

all: $(PROG)

$(PROG): $(OBJS)
	$(CC) -o $@ $(OBJS) $(LIBS)

.c.o:
	$(CC) $(DEFS) -c -o $@ $<

clean:
	rm -f $(OBJS)

