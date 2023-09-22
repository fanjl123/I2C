module AHBlite_I2C(
    input  wire           HCLK,
    input  wire           HRESETn,
    input  wire           HSEL,
    input  wire    [31:0] HADDR,
    input  wire    [1:0]  HTRANS,
    input  wire    [2:0]  HSIZE,
    input  wire    [3:0]  HPROT,
    input  wire           HWRITE,
    input  wire    [31:0] HWDATA,
    input  wire           HREADY,
    output wire           HREADYOUT,
    output reg     [31:0] HRDATA,
    output wire           HRESP,

    output reg           i2c_rxbuf_f,
    output reg           i2c_wr_r,
    input  wire          i2c_wr_slv,
    output reg     [6:0] i2c_adr_r,
    output reg           i2c_start,
    output reg           i2c_stop,
    output reg           i2c_auto,
    output reg           i2c_autodetectack_en,
    output reg           i2c_en,
    output reg           i2c_ack,
    output reg           i2c_ms,
    input  wire          FIFOfull,
    input  wire          FIFOempty,
    input  wire          i2c_rxbf_set,
    input  wire          i2c_nackf_set,
    input  wire          sigbyte_finishf,
    output reg     [7:0] cnt_set,
    input  wire          stop_f,
    output wire          tx_en,
    output wire    [7:0] tx_data,
    input  wire    [7:0] rx_buf
);

assign HRESP = 1'b0;
assign HREADYOUT = 1'b1;

wire read_en;
assign read_en=HSEL&HTRANS[1]&(~HWRITE)&HREADY;

wire write_en;
assign write_en=HSEL&HTRANS[1]&(HWRITE)&HREADY;

reg [3:0] addr_reg;
reg wr_en_reg;
reg rd_en_reg;
reg i2c_nackf;
wire  i2c_wr;

assign i2c_wr= i2c_ms ? i2c_wr_slv : i2c_wr_r;

always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn)
  begin
    i2c_wr_r  <= 1'b1;
    i2c_adr_r <= 7'h5a;
    cnt_set   <= 8'hfa;
    i2c_en <= 1'b0;
    i2c_auto <= 1'b0;
    i2c_autodetectack_en <= 1'b0;
    i2c_stop <= 1'b0;
    i2c_ack <= 1'b0;
    i2c_rxbuf_f <= 1'b0;
    i2c_nackf   <= 1'b0;
    i2c_ms      <= 1'b0;
  end
  else
  begin
    if(wr_en_reg & addr_reg[3:0]==4'h0) {cnt_set,i2c_adr_r,i2c_wr_r}                 <= HWDATA[15:0];
    if(wr_en_reg & addr_reg[3:0]==4'h4) {i2c_en,i2c_auto,i2c_ms,i2c_ack,i2c_autodetectack_en,i2c_stop} <= {HWDATA[7:4],HWDATA[2:1]};
    if(wr_en_reg & addr_reg[3:0]==4'h8) {i2c_nackf,i2c_rxbuf_f} <= {HWDATA[4],HWDATA[0]};
    else if (i2c_rxbf_set)          i2c_rxbuf_f <= 1'b1;
    else if (i2c_nackf_set)         i2c_nackf   <= 1'b1;
    if(wr_en_reg & addr_reg[3:0]==4'h4)  i2c_start <= HWDATA[0];
    else i2c_start <= 1'b0;
	if(stop_f & ~i2c_auto)  i2c_stop <= 1'b0;
  end
end

always@(*) begin
  if(rd_en_reg)
  begin
    case (addr_reg[3:0])
      4'b0000: HRDATA = {16'b0,cnt_set,i2c_adr_r,i2c_wr};
      4'b0100: HRDATA = {24'b0,i2c_en,i2c_auto,i2c_ms,i2c_ack,1'b0,i2c_autodetectack_en,i2c_stop,1'b0};
      4'b1000: HRDATA = {26'b0,sigbyte_finishf,i2c_nackf,FIFOempty,FIFOfull,stop_f,i2c_rxbuf_f};
      4'b1100: HRDATA = {24'b0,rx_buf};
	  default: HRDATA = 32'b0;
    endcase
  end
  else
    HRDATA = 32'b0;
end


always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) addr_reg <= 4'h0;
  else if(read_en || write_en) addr_reg <= HADDR[3:0];
end
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) rd_en_reg <= 1'b0;
  else if(read_en) rd_en_reg <= 1'b1;
  else rd_en_reg <= 1'b0;
end

always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) wr_en_reg <= 1'b0;
  else if(write_en) wr_en_reg <= 1'b1;
  else  wr_en_reg <= 1'b0;
end

assign tx_en = (wr_en_reg & addr_reg==4'hc) ? 1'b1 : 1'b0;
assign tx_data = (wr_en_reg & addr_reg==4'hc) ? HWDATA[7:0] : 8'b0;
endmodule


