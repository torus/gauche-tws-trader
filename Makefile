TARGET=violet
CFLAGS=$(shell gauche-config -I)
LIBPATH=$(shell gauche-config -L)
LFLAGS=-luv $(LIBPATH) -lgauche-0.97
LD_LIBRARY_PATH=$(shell gauche-config --sysarchdir)

MAKIKI=gosh-modules/makiki
RHEINGAU=./gauche-rheingau

SCANRESULT=result.tmp.txt

run-docker:
	/usr/local/bin/docker-compose up

build: $(TARGET)

run: $(TARGET) $(MAKIKI)
#	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) ./$(TARGET)
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) nodemon -e scm --ignore gosh-modules/ --ignore gauche-rheingau/ --exec ./$(TARGET)

# run on host
sum: gain-error.dat

gain-error.dat: sum.scm result.tmp.txt
	docker run -i -w /code -v $(shell pwd):/code --rm practicalscheme/gauche gosh $< < $(SCANRESULT) > $@

scan: $(SCANRESULT)

$(SCANRESULT): scan.scm
	docker-compose exec gosh gosh scan.scm | tee $@

## docker run --rm -p 2222:2222 -v$PWD:/code -w /code -t -i gauche-violet_gosh make debug
debug: $(TARGET) $(MAKIKI)
	gdb -ex run $(TARGET)

$(TARGET): main.c
	$(CXX) -g -I/usr/local/include -o $(TARGET) main.c $(CFLAGS) $(LFLAGS)

$(MAKIKI): $(RHEINGAU)
	$(RHEINGAU)/rh1 install

$(RHEINGAU):
	git clone https://github.com/torus/gauche-rheingau.git $(RHEINGAU)

clean: data-clean
	rm -rf *~ *.o $(TARGET) gosh-modules $(RHEINGAU) $(TARGET).dSYM

data-clean:
	rm -rf *.tmp.* *.dat
