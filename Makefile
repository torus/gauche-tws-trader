TARGET=violet
CFLAGS=$(shell gauche-config -I)
LIBPATH=$(shell gauche-config -L)
TWS_LFLAGS=-pthread -Wall -Wno-switch -Wpedantic -std=c++11
LFLAGS=-luv $(LIBPATH) -lgauche-0.97
LD_LIBRARY_PATH=$(shell gauche-config --sysarchdir)

TWS_ROOT_DIR=./tws/twsapi/source/cppclient
TWS_BASE_SRC_DIR=${TWS_ROOT_DIR}/client
TWS_CFLAGS=-I${TWS_BASE_SRC_DIR} -I${TWS_ROOT_DIR}

.PHONY: adapter tags test

MAKIKI=gosh-modules/makiki
RHEINGAU=./gauche-rheingau

TWS_ADAPTER=./ext/gaucheadapter.a

SCANRESULT=result_$(shell date +%Y%m%d-%H%M).tmp.log

run-docker:
	/usr/local/bin/docker-compose up

SCRIPT=script.scm

build: $(TARGET)

run: $(TARGET) $(MAKIKI)
#	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) ./$(TARGET) $(SCRIPT)
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) nodemon -e scm --ignore gosh-modules/ --ignore gauche-rheingau/ --ignore tools/ --ignore test/ --exec ./$(TARGET) $(SCRIPT)

test:
	docker-compose exec gosh gosh -I. ./test/test-appmain

# run on host
tags:
	etags -l c++ `find . -type f -name '*.h' -or -name '*.cpp'`

# run on host
sum: gain-error.dat

gain-error.dat: sum.scm result.tmp.txt
	docker run -i -w /code -v $(shell pwd):/code --rm practicalscheme/gauche gosh $< < $(SCANRESULT) > $@

scan: $(SCANRESULT)

$(SCANRESULT): scan.scm
	(docker-compose run gosh gosh scan.scm EUR GBP && \
	 docker-compose run gosh gosh scan.scm EUR USD && \
	 docker-compose run gosh gosh scan.scm EUR CHF && \
	 docker-compose run gosh gosh scan.scm GBP USD && \
	 docker-compose run gosh gosh scan.scm GBP CHF && \
	 docker-compose run gosh gosh scan.scm USD CHF) | tee $@

## docker run --rm -p 2222:2222 -v$PWD:/code -w /code -t -i gauche-violet_gosh make debug
debug: $(TARGET) $(MAKIKI)
	gdb -ex "run script.scm" $(TARGET)

$(TARGET): main.c adapter
	$(CXX) -g -I/usr/local/include $(TWS_CFLAGS) -o $(TARGET) main.c $(TWS_ADAPTER) $(CFLAGS) $(LFLAGS) $(TWS_LFLAGS)

$(MAKIKI): $(RHEINGAU)
	$(RHEINGAU)/rh1 install

$(RHEINGAU):
	git clone https://github.com/torus/gauche-rheingau.git $(RHEINGAU)

adapter:
	make -C ext

$(TWS_ADAPTER): adapter

clean: data-clean
	rm -rf *~ *.o $(TARGET) gosh-modules $(RHEINGAU) $(TARGET).dSYM
	make -C ext clean

data-clean:
	rm -rf *.tmp.* *.dat
