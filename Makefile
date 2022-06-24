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
	wget https://media-www.micron.com/-/media/client/global/documents/products/sim-model/dram/ddr3/ddr3-sdram-verilog-model.zip

model: ddr3-sdram-verilog-model.zip
	rm -rf model
	unzip -d model ddr3-sdram-verilog-model.zip
	chmod -R +w model

# FIXME: Patch STOP_ON_ERROR and DEBUG parameters
model/ddr3.v: model

tb-iverilog: slowDDR3.v tb.v model/ddr3.v model/2048Mb_ddr3_parameters.vh
	cd model && \
		iverilog -g2005-sv -o ../tb-iverilog ../tb.v ../slowDDR3.v ddr3.v -Dden2048Mb -Dx16

test-iverilog-run: tb-iverilog
	./tb-iverilog

test-questa: slowDDR3.v tb.v model/ddr3.v model/2048Mb_ddr3_parameters.vh
	vlog slowDDR3.v
	cd model && \
		vlog -work ../work -sv +define+x16 +define+den2048Mb ddr3.v
	vlog tb.v

test-questa-run: test-questa
	vsim -c tb