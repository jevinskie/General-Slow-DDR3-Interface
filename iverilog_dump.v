module iverilog_dump();

initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb.ddr_interface);
end

endmodule
