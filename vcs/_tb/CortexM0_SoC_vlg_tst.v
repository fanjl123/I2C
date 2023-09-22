`timescale 1 ns/ 1 ns
module CortexM0_SoC_vlg_tst();

reg clk;
reg RSTn;
reg TXD;
wire scl;
wire sda;
pullup(scl);
pullup(sda);

CortexM0_SoC i1 (
    .clk(clk),
    .RSTn_in(~RSTn),
    .SWDIO( ),
    .SWCLK( ),
    .LED( ),
    .LEDclk( ),
    .SCL(scl ),
    .SDA(sda ),
    .TXD( ),
    .RXD( )
);

I2C_top_test U_I2C_top_test(
  .HCLK            (clk          ),
  .HRESETn         (RSTn         ),
  .scl_pin(scl),
  .sda_pin(sda)
);





initial begin
    clk = 0;
    RSTn=0;
    #100
    RSTn=1;

end

always begin
    #10 clk = ~clk;
end

initial begin
	$fsdbDumpfile("CortexM0_SoC_vlg_tst.fsdb");
	$fsdbDumpvars(0,CortexM0_SoC_vlg_tst);
	// $fsdbDumpMDA();
	// $dumpvars();
	#10000000 $finish;
end

endmodule
