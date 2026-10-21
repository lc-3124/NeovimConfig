CXX      ?= g++
CXXFLAGS ?= -O2 -std=c++17 -Wall -Wextra
TARGET   := hypr-cursor

all: $(TARGET)

$(TARGET): hypr-cursor.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

install: $(TARGET)
	install -Dm755 $(TARGET) /usr/local/bin/$(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: all install clean
