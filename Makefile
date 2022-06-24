all: slowDDR3.v

.PHONY: clean test-iverilog test-questa

clean:
	rm -rf slowDDR3.v \
		ddr3-sdram-verilog-model.zip model \
		work

slowDDR3.v: slowDDR3.scala
	sbt run

ddr3-sdram-verilog-model.zip:
	wget https://media-www.micron.com/-/media/client/global/documents/products/sim-model/dram/ddr3/ddr3-sdram-verilog-model.zip

model: ddr3-sdram-verilog-model.zip
	rm -rf model
	unzip -d model ddr3-sdram-verilog-model.zip
	chmod -R +w model

test-iverilog: slowDDR3.v tb.v model/ddr3.v

test-questa: slowDDR3.v tb.v model/ddr3.v
	vlog slowDDR3.v
	pushd model
	vlog +define+x16 +define+den2048Mb ddr3.v
	popd
	vlog tb.v
