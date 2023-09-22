`timescale 1ns/1ns
module I2C_Slver
(
  input   wire        rst           ,
  input   wire        clk           ,
  input   wire        scli          ,
  input   wire        sdai          ,
  output  reg         sdao          ,
  output  reg         sdaoe         ,
  output  wire        i2c_slver_int ,
  input   wire        i2c_en        ,
  input   wire        i2c_ack       ,
  input   wire  [6:0] i2c_adr       ,
  output  reg         i2c_wr_r      ,
  input   wire        FIFOempty     ,
  output  wire        FIFOrd_en     ,
  input   wire  [7:0] FIFOdata      ,
  output  wire        i2c_rxbf_set  ,
  output  wire  [7:0] rx_buf

);

localparam      i2c_idle  = 4'h0;
localparam    s_i2c_addr  = 4'h1;
localparam    s_i2c_ack0  = 4'h2;
localparam    s_i2c_ack   = 4'h3;
localparam    s_i2c_data  = 4'h4;

reg   [3:0]   pstate       ;
reg   [3:0]   nstate       ;
wire          s_start      ;
wire          s_end        ;
reg    [3:0]  scli_shift   ;
reg    [3:0]  sdai_shift   ;
reg    [1:0]  scli_r       ;
reg    [1:0]  sdai_r       ;
wire          scli_pos     ;
wire          scli_neg     ;
wire          sdai_pos     ;
wire          sdai_neg     ;
assign        scli_pos     =  scli_r[0] & ~scli_r[1];
assign        scli_neg     = ~scli_r[0] &  scli_r[1];
assign        sdai_pos     =  sdai_r[0] & ~sdai_r[1];
assign        sdai_neg     = ~sdai_r[0] &  sdai_r[1];
assign        s_start      =  scli_r[0] &  sdai_neg;
assign        s_end        =  scli_r[0] &  sdai_pos;


assign FIFOrd_en    = (~FIFOempty) & (pstate==s_i2c_data & nstate==s_i2c_ack) & i2c_wr_r;
assign i2c_rxbf_set = (~i2c_wr_r) & (pstate==s_i2c_data & nstate==s_i2c_ack);
assign i2c_slver_int = 1'b0;
always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    scli_shift <=  4'b0;
    sdai_shift <=  4'b0;
    scli_r     <=  2'b0;
    sdai_r     <=  2'b0;
  end
  else if(i2c_en)
  begin
    scli_shift <=  {scli_shift[2:0],scli};
    sdai_shift <=  {sdai_shift[2:0],sdai};
    if     (&scli_shift)   scli_r[0]  <=  1'b1;  else if(|scli_shift)  scli_r[0]  <=  1'b0;
    if     (&sdai_shift)   sdai_r[0]  <=  1'b1;  else if(|sdai_shift)  sdai_r[0]  <=  1'b0;
    scli_r[1]  <=  scli_r[0];
    sdai_r[1]  <=  sdai_r[0];
  end
end


reg  [3:0] bit_cnt;
reg   [7:0]  i2c_buf;
assign rx_buf = i2c_buf;
always
@(negedge rst or posedge clk)
begin
  if(~rst)
    i2c_buf <= 8'hff;
  else
  begin
    if(pstate==s_i2c_data  & i2c_wr_r)
    begin
      if(scli_neg)
	  begin
        if(|bit_cnt)i2c_buf <= {i2c_buf[6:0],sdai};
        else        i2c_buf <= FIFOdata;
      end
    end
    else if(scli_pos)
      i2c_buf <= {i2c_buf[6:0],sdai};
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    bit_cnt <= 4'h0;
  else
  begin
    if(pstate != nstate)
      bit_cnt <= 4'h0;
    else if(pstate==s_i2c_data & i2c_wr_r)
	begin
	  if(scli_neg)
        bit_cnt <= bit_cnt + 1'b1;
    end
    else if(scli_pos)
      bit_cnt <= bit_cnt + 1'b1;
  end
end
wire  state_change;

assign state_change = i2c_wr_r ? scli_neg : scli_pos;


always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    i2c_wr_r        <= 1'b0 ;
  end
  else
  begin
    if(pstate==s_i2c_addr & scli_pos & (&bit_cnt[2:0]))
      i2c_wr_r        <= sdai;
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
    begin  sdao   = 1'b0;           sdaoe = 1'b0;     end
  else if(pstate!=i2c_idle & nstate==i2c_idle)
    begin  sdao   = 1'b0;           sdaoe = 1'b0;     end
  else
    case(pstate)
      s_i2c_ack0  : if(scli_neg     )begin  sdao   = i2c_ack;           sdaoe = 1'b1;     end
      s_i2c_data  : begin
	                  if(state_change)
	                  begin
					    if(|bit_cnt)sdao   = i2c_buf[6];
						else sdao   = FIFOdata[7];
					  end
					  if(scli_neg & (~(|bit_cnt[3:0])))  sdaoe =  i2c_wr_r;
					end
      s_i2c_ack   : if(scli_neg     )begin  sdao   = i2c_ack;           sdaoe = ~i2c_wr_r;end
    endcase
end


always
@(negedge rst or posedge clk)
begin
  if(~rst)
    pstate <= i2c_idle;
  else
    pstate <= nstate;
end

always
@(*)
begin
  nstate = pstate;
  if(s_end)
    nstate = i2c_idle;
  else if(s_start)
    nstate = s_i2c_addr;
  else
  begin
    case(pstate)
      s_i2c_addr  : if(scli_pos & (&bit_cnt[2:0]))begin if(i2c_buf[6:0]==i2c_adr)nstate = s_i2c_ack0 ;  else  nstate = i2c_idle;end
      s_i2c_ack0  : if(scli_pos) nstate = s_i2c_data;
      s_i2c_data  : if(scli_pos & (&bit_cnt[2:0])) nstate = s_i2c_ack ;
      s_i2c_ack   : if(scli_pos)
                    begin
                      if(i2c_wr_r && i2c_buf[0])
                        nstate = i2c_idle;
                      else
                        nstate = s_i2c_data;
                    end
      default     :;
    endcase
  end
end



endmodule