
module I2C_Master
(
  input   wire        rst          ,
  input   wire        clk          ,
  output  reg         sclo         ,
  output  reg         scloe        ,
  output  reg         sdao         ,
  input   wire        sdai         ,
  output  reg         sdaoe        ,
  output  wire        i2c_master_int,

  input   wire        i2c_wr_w     ,
  input   wire  [6:0] i2c_adr_w    ,

  input   wire        i2c_start    ,
  input   wire        i2c_stop     ,
  input   wire        i2c_auto     ,
  input   wire        i2c_autodetectack_en     ,
  input   wire        i2c_en       ,
  input   wire        i2c_ack      ,

  input   wire        FIFOempty    ,
  output  wire        FIFOrd_en    ,
  input   wire  [7:0] FIFOdata     ,
  input   wire  [7:0] cnt_set      ,

  output  wire        i2c_rxbf_set ,
  output  reg         i2c_nackf_set,
  output  reg         sigbyte_finishf,
  output  reg         stop_f       ,
  output  wire  [7:0] rx_buf
);

localparam      i2c_idle   = 4'b0000;
localparam    m_i2c_start  = 4'b0001;
localparam    m_i2c_hold   = 4'b0010;
localparam    m_i2c_end1   = 4'b0011;

localparam    m_i2c_ack0   = 4'b1001;
localparam    m_i2c_ack    = 4'b1010;

localparam    m_i2c_addr   = 4'b1100;
localparam    m_i2c_data   = 4'b1101;
localparam    m_i2c_restart= 4'b1110;
localparam    m_i2c_end0   = 4'b1111;


reg           i2c_rstart   ;
reg   [3:0]   pstate       ;
reg   [3:0]   nstate       ;
reg   [7:0]   TX_BUF       ;


assign i2c_master_int = 1'b0;


//UART TX
reg counter_en;
reg [3:0] counter;
reg [7:0] cnt;


reg trans_start;

always@(*)
begin
  if(i2c_auto)
      trans_start = (~FIFOempty) & (~counter_en) & (pstate==i2c_idle) & i2c_en;
  else
      trans_start = i2c_start & (pstate==i2c_idle) & i2c_en;
end

always
@(negedge rst or posedge clk)
begin
    if(~rst) counter_en <= 1'b0;
    else if(trans_start) counter_en <= 1'b1;
    else if(pstate==m_i2c_end1 & nstate==i2c_idle) counter_en <= 1'b0;
end

wire half_bit_en;
wire quarter_bit_en;
assign half_bit_en = (cnt==cnt_set);
assign quarter_bit_en = (cnt=={1'b0,cnt_set[7:1]});

always
@(negedge rst or posedge clk)
begin
    if(~rst)
      cnt <= 8'h0;
    else if(counter_en)
    begin
      if(pstate!=nstate | cnt==cnt_set)
        cnt <= 8'h0;
      else
        cnt <= cnt + 1'b1;
    end
end




always
@(negedge rst or posedge clk)
begin
    if(~rst)
      counter <= 4'h0;
    else if(counter_en & half_bit_en)
    begin
      if(pstate!=nstate)
        counter <= 4'h0;
      else
        counter <= counter + 1'b1;
    end
end

reg  i2c_wr_r;
wire    state_change0;
wire    state_change1;
wire    tx_shift_change;
wire    rx_shift_change;
// wire    rx_ack_change;
assign    state_change0 = counter[0] & half_bit_en;
assign    state_change1 = &counter[3:0] & half_bit_en;
assign tx_shift_change  = ~counter[0] & quarter_bit_en;
assign rx_shift_change  =  counter[0] & quarter_bit_en;
// assign rx_ack_change    =  counter[0] & quarter_bit_en & pstate[3] & ~pstate[2];



assign FIFOrd_en = (~FIFOempty) & tx_shift_change & pstate==m_i2c_data & (~(|counter[3:1]));
assign  i2c_rxbf_set = (pstate==m_i2c_data & i2c_wr_r & rx_shift_change & (&counter[3:1]));

always@(*)
begin
  if(rx_shift_change & pstate[3] & ~pstate[2])
  begin
    if(~pstate[0] & i2c_wr_r)  i2c_nackf_set = 1'b0;
	else i2c_nackf_set = sdai;
  end
  else
    i2c_nackf_set = 1'b0;
end

assign  rx_buf = (i2c_wr_r)?TX_BUF : 8'h0;


always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    i2c_rstart    <= 1'b0;
    i2c_wr_r      <= 1'b0;
    stop_f        <= 1'b0;
  end
  else
  begin
    if(counter_en)
    begin
      if(i2c_start) i2c_rstart    <= 1'b1;
      else if(nstate==m_i2c_restart && pstate!=m_i2c_restart) i2c_rstart    <= 1'b0;
    end
    if(nstate==m_i2c_start & pstate!=m_i2c_start) i2c_wr_r<=i2c_wr_w;
    if(nstate==i2c_idle & pstate==m_i2c_end1) stop_f<=1'b1;
    else if(nstate==m_i2c_start & pstate==i2c_idle) stop_f<=1'b0;
  end
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
    case(pstate)
        i2c_idle  : if(trans_start  ) nstate = m_i2c_start;
      m_i2c_start : if(state_change0) nstate = m_i2c_addr;
      m_i2c_addr  : if(state_change1) nstate = m_i2c_ack0;
      m_i2c_ack0  : if(state_change0)
                    begin
                      if(i2c_auto)
                      begin
					    if(i2c_autodetectack_en & TX_BUF[0])                              nstate = m_i2c_restart;
                        else nstate = m_i2c_data;
                      end
                      else
                      begin
                        if      (i2c_stop)                                    nstate = m_i2c_end0;
                        else  if(~i2c_wr_r & i2c_rstart)                      nstate = m_i2c_restart;
                        else  if(FIFOempty)                                   nstate = m_i2c_hold;
                        else                                                  nstate = m_i2c_data;
                      end
                    end
      m_i2c_data  : if(state_change1) nstate = m_i2c_ack;
      m_i2c_ack   : if(state_change0)
                    begin
                      if(i2c_auto)
                      begin
                        if (FIFOempty)          nstate = m_i2c_end0;
                        else                    nstate = m_i2c_data;
                      end
                      else
                      begin
                        if      (i2c_stop)                                    nstate = m_i2c_end0;
                        else  if(~i2c_wr_r & i2c_rstart)                      nstate = m_i2c_restart;
                        else  if(FIFOempty)                                   nstate = m_i2c_hold;
                        else                                                  nstate = m_i2c_data;
                      end
                    end
      m_i2c_hold  : if(state_change0)
                    begin
                      if     (i2c_stop)                                       nstate = m_i2c_end0 ;
                      else if(~i2c_wr_r &i2c_rstart)                          nstate = m_i2c_restart;
                      else if(~FIFOempty)                                     nstate = m_i2c_data;
                      else                                                    nstate = m_i2c_hold;
                    end
      m_i2c_restart: if(state_change0)                                        nstate = m_i2c_start;
      m_i2c_end0   : if(state_change0)                                        nstate = m_i2c_end1;
      m_i2c_end1   : if(state_change0)                                        nstate = i2c_idle;
      default      :;
    endcase
end


wire   ack_feedback_oe;
assign ack_feedback_oe = i2c_wr_r & ((~FIFOempty & i2c_auto) | (~i2c_stop & ~i2c_auto));

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    TX_BUF <= 8'h00;
    sdao   <= 1'b1;
    sdaoe  <= 1'b0;
    sigbyte_finishf  <= 1'b0;
  end
  else
  begin
    if(tx_shift_change)
    case (pstate)
      m_i2c_start  : begin    sdao   <= 1'b0                ; sdaoe <= 1'b1            ;  end
      m_i2c_ack0   : begin    sdao   <= 1'b0                ; sdaoe <= 1'b0            ;  end
      m_i2c_ack    : begin    sdao   <= i2c_ack             ; sdaoe <=  ack_feedback_oe;  end
      m_i2c_restart: begin    sdao   <= 1'b1                ; sdaoe <= 1'b1            ;  end
      m_i2c_end0   : begin    sdao   <= 1'b0                ; sdaoe <= 1'b1            ;  end
      m_i2c_end1   : begin    sdao   <= 1'b1                ; sdaoe <= 1'b1            ;  end
      m_i2c_addr   : begin
                       if(|counter[3:1])
                         begin TX_BUF <= {TX_BUF[6:0],sdai};   sdao   <= TX_BUF[6]           ;end
                       else
                         begin TX_BUF <= {i2c_adr_w,i2c_wr_r};   sdao   <= i2c_adr_w[6]           ;end
                       sdaoe <= 1'b1     ;
                     end
      m_i2c_data   : begin
                       if(~i2c_wr_r)
                       begin
                         if(|counter[3:1])
                           begin TX_BUF <= {TX_BUF[6:0],sdai};   sdao   <= TX_BUF[6]           ;end
                         else
                           begin TX_BUF <= FIFOdata;   sdao   <= FIFOdata[7]           ;end
                       end
                       sdaoe <= ~i2c_wr_r;
                     end
    endcase
    else if(rx_shift_change)
    casex (pstate)
      m_i2c_ack0   :  begin sigbyte_finishf <= 1'b1;    TX_BUF <= {TX_BUF[6:0],sdai}; end
      m_i2c_ack    :  begin sigbyte_finishf <= 1'b1;                                  end
      m_i2c_data   :  if(i2c_wr_r)  TX_BUF <= {TX_BUF[6:0],sdai};
    endcase

    if((pstate!=m_i2c_end0 & nstate==m_i2c_end0) | (pstate!=m_i2c_data & nstate==m_i2c_data) | (pstate!=m_i2c_addr & nstate==m_i2c_addr)) sigbyte_finishf <= 1'b0;
  end
end

always
@(negedge rst or posedge clk)
begin
  if(~rst)
  begin
    sclo <= 1'b0;
    scloe<= 1'b0;
  end
  else
  begin
    if(nstate[3])
      sclo <= counter[0];
    else
      sclo <= 1'b1;
    if(pstate==i2c_idle & nstate==m_i2c_start)
      scloe <= 1'b1;
    else if(pstate==m_i2c_end1 & nstate==i2c_idle)
      scloe <= 1'b0;
  end
end

endmodule