DC = dmd
RM = rm
RMFLAGS = -f

test.exe: squish.d test.d
	$(DC) squish.d test.d -oftest.exe

clean:
	$(RM) $(RMFLAGS) test.exe *.o *.obj *.map *compressed.*
