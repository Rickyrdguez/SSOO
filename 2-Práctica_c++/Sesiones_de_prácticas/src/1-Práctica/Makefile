CXX = g++
CXXFLAGS = -std=c++23 -Wall -Wextra -Wpedantic

copy: main_copy.cc copy.cc copy.h
	$(CXX) $(CXXFLAGS) main_copy.cc copy.cc -o copy

clean:
	rm -f copy

.PHONY: clean