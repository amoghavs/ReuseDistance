TGT = ReuseDistance

LINKSHARED = -lpthread -shared
BUILDSHARED = -fPIC
INCLUDE = -I.
INSTALLTO = /usr/local
EXTOBJ = tree234.o LRUDistanceAnalyzer.o


CXX = g++
CXXFLAGS = -g -O2 -std=c++0x -DHAVE_UNORDERED_MAP -g $(INCLUDE)

DYNTGT = lib$(TGT).so
STATGT = lib$(TGT).a

.PHONY: all install clean depend static dynamic test check doc

all: $(DYNTGT)

dynamic: $(DYNTGT)
static: $(STATGT)

$(DYNTGT): $(TGT).o $(EXTOBJ)
	$(CXX) $(CXXFLAGS) $(LINKSHARED) -o $@ $< $(EXTOBJ)

$(STATGT): $(TGT).o $(EXTOBJ)
	$(AR) cru $@ $< $(EXTOBJ)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(BUILDSHARED) -c -o $@ $<

%.o: %.c
	$(CXX) $(CXXFLAGS) $(BUILDSHARED) -c -o $@ $<

test: $(DYNTGT)
	$(MAKE) -C test/

check: all test
	$(MAKE) -C test/ check

clean:
	rm -rf $(TGT).o $(DYNTGT) $(STATGT) $(EXTOBJ) *.ii *.s
	$(MAKE) -C test/ clean

install: all
	test -d $(INSTALLTO) || mkdir $(INSTALLTO)

	test -d $(INSTALLTO)/lib || mkdir $(INSTALLTO)/lib
	cp $(DYNTGT) $(INSTALLTO)/lib
	chmod +rx $(INSTALLTO)/lib/$(DYNTGT)

	# only install static lib if it exists
	! test -f $(STATGT) || cp $(STATGT) $(INSTALLTO)/lib
	! test -f $(STATGT) || chmod +rx $(INSTALLTO)/lib/$(STATGT)

	test -d $(INSTALLTO)/include || mkdir $(INSTALLTO)/include
	cp $(TGT).hpp $(INSTALLTO)/include
	chmod +r $(INSTALLTO)/include/$(TGT).hpp

	test -d $(INSTALLTO)/man || mkdir $(INSTALLTO)/man
	test -d $(INSTALLTO)/man/man3 || mkdir $(INSTALLTO)/man/man3
	cp docs/man/man3/* $(INSTALLTO)/man/man3

depend:
	g++ -E -MM $(INCLUDE) $(TGT).cpp > DEPENDS

doc:
	$(MAKE) -C docs/

include DEPENDS
