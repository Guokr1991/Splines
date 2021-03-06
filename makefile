# get the type of OS currently running
OS=$(shell uname)
PWD=$(shell pwd)

LIB_SPLINE = libSplines.a
LIB_GC     = libGenericContainer.a

CC   = gcc
CXX  = g++
INC  = -I./src -I./include
LIBS = -L./lib -lSplines -lGenericContainer
DEFS =

# check if the OS string contains 'Linux'
ifneq (,$(findstring Linux, $(OS)))
  #LIB_SPLINE = libSplines.so
  #LIB_GC     = libGenericContainer.so
  LIBS     = -static -L./lib -lSplines -lGenericContainer
  CXXFLAGS = -Wall -O3 -fPIC -Wno-sign-compare
  AR       = ar rcs
endif

# check if the OS string contains 'Darwin'
ifneq (,$(findstring Darwin, $(OS)))
  CC       = clang
  CXX      = clang++
  #LIB_SPLINE = libSplines.dylib
  #LIB_GC     = libGenericContainer.dylib
  LIBS     = -L./lib -lSplines -lGenericContainer
  CXXFLAGS = -Wall -O3 -fPIC -Wno-sign-compare
  AR       = libtool -static -o
endif

SRCS = \
src/SplineAkima.cc \
src/SplineAkima2D.cc \
src/SplineBSpline.cc \
src/SplineBessel.cc \
src/SplineBiCubic.cc \
src/SplineBiQuintic.cc \
src/SplineBilinear.cc \
src/SplineConstant.cc \
src/SplineCubic.cc \
src/SplineCubicBase.cc \
src/SplineHermite.cc \
src/SplineLinear.cc \
src/SplinePchip.cc \
src/SplineQuintic.cc \
src/SplineQuinticBase.cc \
src/SplineSet.cc \
src/SplineSetGC.cc \
src/Splines.cc \
src/SplinesBivariate.cc \
src/SplinesCinterface.cc \
src/SplinesUnivariate.cc

OBJS  = $(SRCS:.cc=.o)
DEPS  = src/Splines.hh src/SplinesCinterface.h
MKDIR = mkdir -p

# prefix for installation, use make PREFIX=/new/prefix install
# to override
PREFIX    = /usr/local
FRAMEWORK = Splines

all: lib
	mkdir -p bin
	$(CXX) $(INC) $(CXXFLAGS) -o bin/test1 tests/test1.cc $(LIBS)
	$(CXX) $(INC) $(CXXFLAGS) -o bin/test2 tests/test2.cc $(LIBS)
	$(CXX) $(INC) $(CXXFLAGS) -o bin/test3 tests/test3.cc $(LIBS)
	$(CXX) $(INC) $(CXXFLAGS) -o bin/test4 tests/test4.cc $(LIBS)
	$(CXX) $(INC) $(CXXFLAGS) -o bin/test5 tests/test5.cc $(LIBS)
	#$(CXX) $(CXXFLAGS) -o bin/test6 tests/test6.cc $(LIBS)

lib: lib/$(LIB_GC) lib/$(LIB_SPLINE)

src/%.o: src/%.cc $(DEPS)
	$(CXX) $(INC) $(CXXFLAGS) $(DEFS) -c $< -o $@ 

src/%.o: src/%.c $(DEPS)
	$(CC) $(INC) $(CFLAGS) $(DEFS) -c -o $@ $<

lib/libSplines.a: $(OBJS)
	$(AR) lib/libSplines.a $(OBJS) 

lib/libSplines.dylib: $(OBJS)
	$(CXX) -shared -o lib/libSplines.dylib $(OBJS) 

lib/libSplines.so: $(OBJS)
	$(CXX) -shared -o lib/libSplines.so $(OBJS) 

lib/$(LIB_GC):
	$(MKDIR) include ; cd GC ; make CXXFLAGS="$(CXXFLAGS)" lib ; make PREFIX="$(PWD)" install 


install: lib
	cp src/Splines.hh          $(PREFIX)/include
	cp src/SplinesCinterface.h $(PREFIX)/include
	cp lib/$(LIB_SPLINE)       $(PREFIX)/lib

install_as_framework: lib
	$(MKDIR) $(PREFIX)/include/$(FRAMEWORK)
	cp src/Splines.hh          $(PREFIX)/include/$(FRAMEWORK)
	cp src/SplinesCinterface.h $(PREFIX)/include/$(FRAMEWORK)
	cp lib/$(LIB_SPLINE)       $(PREFIX)/lib

run:
	./bin/test1
	./bin/test2
	./bin/test3
	./bin/test4
	./bin/test5
	#./bin/test6

doc:
	doxygen
	
clean:
	rm -f lib/libSplines.* lib/libGenericContainer.* src/*.o

	rm -rf bin
	