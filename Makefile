9cc: src/nim_9cc.nim
	nim c src/nim_9cc.nim

test: src/nim_9cc
	chmod a+x ./test.sh && ./test.sh

clean:
	rm -f src/nim_9cc *.o *~ tmp*

.PHONY: test clean