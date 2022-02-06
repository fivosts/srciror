#! /bin/bash

CURR_DIR=$( cd $( dirname $0 ) && pwd )

# Set up paths to where compiled tools are here
export SRCIROR_COVINSTRUMENTATION_LIB=$CURR_DIR/../IRMutation/InstrumentationLib/SRCIRORCoverageLib.o
export SRCIROR_LLVMMutate_LIB=$CURR_DIR/../llvm-build/Release+Asserts/lib/LLVMMutate.so
export SRCIROR_LLVM_BIN=$CURR_DIR/../llvm-build/Release+Asserts/bin/

# generate coverage
rm -f /tmp/llvm_mutate_trace # remove any existing coverage
rm -rf ~/.srciror # remove logs and results from previous runs
echo "SRCIROR: Instrumenting for Coverage"
python $CURR_DIR/../PythonWrappers/irCoverageClang test.c -o test
# run the executable to collect coverage
./test
echo "the collected coverage is under /tmp/llvm_coverage"


# generate mutation opportunities
echo "SRCIROR: generating mutation opportunities"
python $CURR_DIR/../PythonWrappers/irMutationClang test.c
echo "The generated mutants are under ~/.srciror/bc-mutants/ffff"

# TODO: intersect with coverage
# generate one mutant executable
file_name=`cat ~/.srciror/ir-coverage/hash-map | grep "test.c" | cut -f1 -d:`
mutations=`cat ~/.srciror/bc-mutants/ffff | cut -f1 -d,`
mutations_array=($mutations)
let "c=0"
for i in "${mutations[@]}"
do
	echo "file name is: $file_name and mutation requested is: $mutation" 
	echo "$file_name:$mutation" > ~/.srciror/mutation_request.txt
	python $CURR_DIR/../PythonWrappers/irVanillaClang test.c
	mv test.ll test-$c.ll
	let "c++"
done
