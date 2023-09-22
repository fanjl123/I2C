
module I2C_top_test
(
    input  wire           HCLK,
    input  wire           HRESETn,
    inout  wire           scl_pin,
    inout  wire           sda_pin
);

// wire sda_test;
M24LC02B i2c_slv_test(
        .A0(1'b0),
        .A1(1'b0),
        .A2(1'b0),
        .WP(1'b0),
        .SDA(sda_pin),
        .SCL(scl_pin),
        .RESET(HRESETn)
);



	 // real clockDelay50 = ((1/ (50e6))/2)*(1e9)/8;

	 // reg main_clk = 0;
	 // reg rst = 1;


	// always begin
	  // main_clk = 1'b0;
	  // #clockDelay50;
	  // main_clk = 1'b1;
	  // #clockDelay50;
	// end

	// reg enable = 0;
	// reg rw = 0;
	// reg [7:0] mosi = 0;
	// reg [7:0] reg_addr = 0;
    // reg [6:0] device_addr = 7'b001_0001;
    // reg [15:0] divider = 16'h0003;

    // wire [7:0] miso;
    // wire       busy;

	// i2c_master #(.DATA_WIDTH(8),.REG_WIDTH(8),.ADDR_WIDTH(7))
        // i2c_master_inst(
            // .i_clk(main_clk),
            // .i_rst(rst),
            // .i_enable(enable),
            // .i_rw(rw),
            // .i_mosi_data(mosi),
            // .i_reg_addr(reg_addr),
            // .i_device_addr(device_addr),
            // .i_divider(divider),
            // .o_miso_data(miso),
            // .o_busy(busy),
            // .io_sda(sda_pin),
            // .io_scl(scl_pin)
    // );

    // reg  [7:0] read_data = 0;
    // wire [7:0] data_to_write = 8'hDC;
    // reg [7:0] proc_cntr = 0;

	// always@(posedge main_clk)begin

                // if(proc_cntr < 20 && proc_cntr > 5)begin
                    // proc_cntr <= proc_cntr + 1;
                // end
			  // case (proc_cntr)

			        // 0: begin
                         // rst <= 1;
                         // proc_cntr <= proc_cntr + 1;
			        // end

			        // 1: begin
			             // rst <= 0;
                         // proc_cntr <= proc_cntr + 1;
                    // end

                    // set configration first
                    // 2: begin
                        // rw <= 0; //write operation
                        // reg_addr <= 8'h00; //writing to slave register 0
                        // mosi <= data_to_write; //data to be written
                        // device_addr = 7'b011_1100; //slave address
                        // divider = 16'h0001; //divider value for i2c serial clock
                        // proc_cntr <= proc_cntr + 1;
                    // end

                    // 3: begin
                        // if master is not busy set enable high
                        // if(busy == 0)begin
                            // enable <= 1;
                            // $display("Enabled write");
                            // proc_cntr <= proc_cntr + 1;
                        // end
                    // end

                    // 4: begin
                        // once busy set enable low
                        // if(busy == 1)begin
                            // enable <= 0;
                            // proc_cntr <= proc_cntr + 1;
                        // end
                    // end

                    // 5: begin
                        // as soon as busy is low again an operation has been completed
                        // if(busy == 0) begin
                            // proc_cntr <= proc_cntr + 1;
                            // $display("Master done writing");
                        // end
                    // end

                    // 20: begin
                        // rw <= 1; //write operation
                        // reg_addr <= 8'h00; //writing to slave register 0
                        // mosi <= data_to_write; //data to be written
                        // device_addr = 7'b011_1100; //slave address
                        // divider = 16'h0001; //divider value for i2c serial clock
                        // proc_cntr <= proc_cntr + 1;
                    // end

                    // 21: begin
                        // if(busy == 0)begin
                            // enable <= 1;
                            // $display("Enabled read");
                            // proc_cntr <= proc_cntr + 1;
                        // end
                    // end

                    // 22: begin
                        // if(busy == 1)begin
                            // enable <= 0;
                            // proc_cntr <= proc_cntr + 1;
                        // end
                    // end

                    // 23: begin
                        // if(busy == 0)begin
                            // read_data <= miso;
                            // proc_cntr <= proc_cntr + 1;
                            // $display("Master done reading");
                        // end
                    // end

                    // 24: begin
                        // if(read_data == data_to_write)begin
                            // $display("Read back correct data!");
                        // end
                        // else begin
                            // $display("Read back incorrect data!");
                        // end
                        // proc_cntr <= proc_cntr + 1;
                    // end

                    // 11: begin
                        // do nothing
                    // end


			  // endcase

	// end


endmodule