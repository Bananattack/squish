DC = dmd
RM = rm
RMFLAGS = -f

test.exe: squish.d test.d
	$(DC) squish.d test.d -oftest

clean:
	$(RM) $(RMFLAGS) test.exe *.o *.obj *.map *compressed.*
