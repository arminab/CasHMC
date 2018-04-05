##################################################################################
#  CasHMC v1.3 - 2017.07.10
#  A Cycle-accurate Simulator for Hybrid Memory Cube
#
#  Copyright 2016, Dong-Ik Jeon
#                  Ki-Seok Chung
#                  Hanyang University
#                  estwings57 [at] gmail [dot] com
#  All rights reserved.
##################################################################################

CXXFLAGS=-O3 -g -DDEBUG_LOG
EXE_NAME=CasHMC
LIB_NAME=libcashmc.so
STATIC_LIB_NAME := libcashmc.a
LIB_NAME_MACOS=libcashmc.dylib
SRCDIR=sources

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(addsuffix .o, $(basename $(SRC)))

LIB_SRC := $(filter-out RunSim.cpp,$(SRC))
LIB_OBJ := $(addsuffix .o, $(basename $(LIB_SRC)))

#build portable objects (i.e. with -fPIC)
POBJ = $(addsuffix .po, $(basename $(LIB_SRC)))

REBUILDABLES=$(OBJ) $(POBJ) $(EXE_NAME) $(LIB_NAME) $(STATIC_LIB_NAME) $(LIB_NAME_MACOS)

all: $(EXE_NAME)

#   $@ target name, $^ target deps, $< matched pattern
$(EXE_NAME): $(OBJ)
	$(CXX) $(LINK_FLAGS) -o $@ $^ 
	@echo "Built $@ successfully" 

$(LIB_NAME): $(POBJ)
	g++ -g -shared -Wl,-soname,$@ -o $@ $^
	@echo "Built $@ successfully"

$(STATIC_LIB_NAME): $(LIB_OBJ)
	$(AR) crs $@ $^

$(LIB_NAME_MACOS): $(POBJ)
	g++ -dynamiclib -o $@ $^
	@echo "Built $@ successfully"

#include the autogenerated dependency files for each .o file
-include $(OBJ:.o=.dep)
-include $(POBJ:.po=.deppo)

# build dependency list via gcc -M and save to a .dep file
%.dep : %.cpp
	@$(CXX) -M $(CXXFLAGS) $< > $@
	
%.deppo : %.cpp
	@$(CXX) -M $(CXXFLAGS) -MT"$*.po" $< > $@
	
# build all .cpp files to .o files
%.o : %.cpp
	g++ $(CXXFLAGS) -o $@ -c $<

#po = portable object .. for lack of a better term
%.po : %.cpp
	g++ $(CXXFLAGS) -DLOG_OUTPUT -fPIC -o $@ -c $<

clean: 
	-rm -f $(REBUILDABLES) $(SRCDIR)/*.dep $(SRCDIR)/*.deppo
