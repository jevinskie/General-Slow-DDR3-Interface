all: slowDDR3.v

VERILATOR_JOBS := 8

.PHONY: clean generate-model-patch \
	test-iverilog-run test-iverilog-trace-run \
	test-questa test-questa-run \
	test-verilator-run

clean:
	rm -rf slowDDR3.v \
		ddr3-sdram-verilog-model.zip model-unpatched model \
		tb-iverilog \
		transcript work \
		obj_dir

slowDDR3.v: slowDDR3.scala
	sbt run

ddr3-sdram-verilog-model.zip:
	wget -N https://media-www.micron.com/-/media/client/global/documents/products/sim-model/dram/ddr3/ddr3-sdram-verilog-model.zip

model-unpatched: ddr3-sdram-verilog-model.zip
	rm -rf $@
	unzip -d $@ ddr3-sdram-verilog-model.zip
	chmod -R +w $@

model: model-unpatched ddr3-model-patch.patch
	rm -rf $@
	cp -R model-unpatched $@
	patch -p0 < ddr3-model-patch.patch

model/ddr3.v: model

generate-model-patch:
	diff -u model-unpatched model | perl -pe "s/(^(---|\+\+\+)\s+\S+).*/\1/" > ddr3-model-patch.patch

tb-iverilog: slowDDR3.v slowDDR3_tb.v model/ddr3.v model/2048Mb_ddr3_parameters.vh
	iverilog -s tb -Dden2048Mb -Dx16 -g2005-sv -I model -o $@ slowDDR3_tb.v slowDDR3.v model/ddr3.v

test-iverilog-run: tb-iverilog
	./tb-iverilog

tb-iverilog-trace: slowDDR3.v slowDDR3_tb.v model/ddr3.v model/2048Mb_ddr3_parameters.vh iverilog_dump.v
	iverilog -s tb -s iverilog_dump -Dsg25 -Dden2048Mb -Dx16 -g2005-sv -I model -o $@ slowDDR3_tb.v slowDDR3.v model/ddr3.v iverilog_dump.v

test-iverilog-trace-run: tb-iverilog-trace
	./tb-iverilog-trace -fst

test-questa: slowDDR3.v slowDDR3_tb.v model/ddr3.v model/2048Mb_ddr3_parameters.vh
	vlog slowDDR3.v
	vlog -sv +define+sg25 +define+x16 +define+den2048Mb +incdir+model model/ddr3.v
	vlog slowDDR3_tb.v
	vopt -noincr +noacc tb -o tb_opt

test-questa-run: test-questa
	vsim -c tb_opt -do "runq -a"

obj_dir/VslowDDR3_tb: slowDDR3.v slowDDR3_tb.v model/ddr3.v model/2048Mb_ddr3_parameters.vh
	verilator --timing --exe tb-verilator.cpp --cc slowDDR3_tb.v --cc slowDDR3.v --cc model/ddr3.v +define+sg25 +define+x16 +define+den2048Mb +incdir+model -Wno-WIDTH -Wno-MULTIDRIVEN -Wno-CASEX -Wno-CASEINCOMPLETE -Wno-UNSIGNED -Wno-REALCVT -Wno-ZERODLY
	CXXFLAGS="-Wno-unknown-warning-option" make -j $(VERILATOR_JOBS) -C obj_dir -f VslowDDR3_tb.mk VslowDDR3_tb

test-verilator-run: obj_dir/VslowDDR3_tb
	./obj_dir/VslowDDR3_tb
