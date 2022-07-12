all: slowDDR3.v

.PHONY: clean test-questa

clean:
	rm -rf slowDDR3.v \
		ddr3-sdram-verilog-model.zip model \
		tb-iverilog \
		transcript work

slowDDR3.v: slowDDR3.scala
	sbt run

ddr3-sdram-verilog-model.zip:
	wget -N https://media-www.micron.com/-/media/client/global/documents/products/sim-model/dram/ddr3/ddr3-sdram-verilog-model.zip

model: ddr3-sdram-verilog-model.zip ddr3-model-iverilog-patch.patch
	rm -rf model
	unzip -d model ddr3-sdram-verilog-model.zip
	chmod -R +w model
	patch -p1 < ddr3-model-iverilog-patch.patch

model/ddr3.v: model

tb-iverilog: slowDDR3.v tb.v model/ddr3.v model/2048Mb_ddr3_parameters.vh
	iverilog -s tb -Dden2048Mb -Dx16 -g2005-sv -I model -o $@ tb.v slowDDR3.v model/ddr3.v

test-iverilog-run: tb-iverilog
	./tb-iverilog

tb-iverilog-trace: slowDDR3.v tb.v model/ddr3.v model/2048Mb_ddr3_parameters.vh iverilog_dump.v
	iverilog -s tb -s iverilog_dump -Dsg25 -Dden2048Mb -Dx16 -g2005-sv -I model -o $@ tb.v slowDDR3.v model/ddr3.v iverilog_dump.v

test-iverilog-trace-run: tb-iverilog-trace
	./tb-iverilog-trace -fst

test-questa: slowDDR3.v tb.v model/ddr3.v model/2048Mb_ddr3_parameters.vh
	vlog slowDDR3.v
	vlog -sv +define+sg25 +define+x16 +define+den2048Mb +incdir+model model/ddr3.v
	vlog tb.v
	vopt -noincr +noacc tb -o tb_opt

test-questa-run: test-questa
	vsim -c tb_opt -do "runq -a"
