CC = clang
RM = rm
RMFLAGS = -f

test.exe: squish.h squish.c test.c
	$(CC) squish.c test.c -o test.exe

clean:
	$(RM) $(RMFLAGS) test.exe *.o *.obj *.map *compressed.*
