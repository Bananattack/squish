CC = clang
RM = rm
RMFLAGS = -f

test.exe: squish.h squish.c test.c
	$(CC) -ansi -pedantic -Wall -Werror squish.c test.c -otest

clean:
	$(RM) $(RMFLAGS) test.exe *.o *.obj *.map *compressed.*
