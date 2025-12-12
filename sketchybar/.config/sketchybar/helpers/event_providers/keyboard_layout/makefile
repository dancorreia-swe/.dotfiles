bin/keyboard_layout_monitor: keyboard_layout_monitor.m ../sketchybar.h | bin
	clang -framework Foundation -framework Carbon -O3 $< -o $@

bin:
	mkdir bin

clean:
	rm -rf bin

.PHONY: clean