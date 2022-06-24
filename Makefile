

all: slowDDR3.v

.PHONY: clean test

clean:
	rm -rf slowDDR3.v ddr3-sdram-verilog-model.zip model

slowDDR3.v: slowDDR3.scala
	sbt run

ddr3-sdram-verilog-model.zip:
	wget https://media-www.micron.com/-/media/client/global/documents/products/sim-model/dram/ddr3/ddr3-sdram-verilog-model.zip

model: ddr3-sdram-verilog-model.zip
	unzip -d model ddr3-sdram-verilog-model.zip

test: slowDDR3.v tb.v model/ddr3.v
