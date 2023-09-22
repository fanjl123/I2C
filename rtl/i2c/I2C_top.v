
module I2C_top
(
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
    output wire    [31:0] HRDATA,
    output wire           HRESP,

    input  wire            scli,
    output wire            sclo,
    output wire            scloe,
    input  wire            sdai,
    output wire            sdao,
    output wire            sdaoe,

    output wire            i2c_int
);

wire [7:0] tx_data;



//FIFO 8bit-16depth
wire FIFOrd_en;
wire FIFOempty;
wire FIFOfull;
wire tx_en;
wire FIFOrd_en_master;
wire FIFOrd_en_slaver;
wire FIFOwr_en;
wire [7:0] FIFOdata;
wire [7:0] cnt_set;

//FIFO write control
assign FIFOwr_en = (~FIFOfull) & tx_en;
assign FIFOrd_en = FIFOrd_en_slaver | FIFOrd_en_master;
FIFO FIFO(
    .clock(HCLK),
    .sclr(HRESETn),
    .rdreq(FIFOrd_en),
    .wrreq(FIFOwr_en),
    .full(FIFOfull),
    .empty(FIFOempty),
    .data(tx_data),
    .q(FIFOdata)
);
wire       s_sdao  ;
wire       s_sdaoe ;
wire       m_sdao  ;
wire       m_sdaoe ;
wire       i2c_wr_slv ;

wire [7:0] rx_buf;
wire [7:0] rx_buf_slv;
wire [7:0] rx_buf_mst;
wire       i2c_rxbf_set;
wire       i2c_rxbf_set_slv;
wire       i2c_rxbf_set_mst;
wire       i2c_nackf_set;
// wire       i2c_nackf_set_slv;
wire       i2c_nackf_set_mst;
wire       sigbyte_finishf;
wire       i2c_ms;
wire       i2c_master_int;
wire       i2c_slver_int;
wire       i2c_ack;
wire [6:0] i2c_adr_w;
wire       i2c_wr_w;
wire       i2c_start;
wire       i2c_stop;
wire       i2c_auto;
wire       i2c_autodetectack_en;
wire       i2c_en;
wire       i2c_rxbuf_f;
wire       stop_f;
assign     i2c_int = i2c_master_int | i2c_slver_int | i2c_rxbuf_f;
assign     i2c_rxbf_set=(i2c_ms)? i2c_rxbf_set_slv:i2c_rxbf_set_mst ;
assign     i2c_nackf_set=(i2c_ms)? 1'b0:i2c_nackf_set_mst ;
assign     rx_buf      =(i2c_ms)? rx_buf_slv      :rx_buf_mst       ;
assign     sdao=(i2c_ms)? s_sdao:m_sdao;
assign     sdaoe=(i2c_ms)? s_sdaoe:m_sdaoe;




I2C_Slver u_I2C_Slver
(
  .rst           (HRESETn         ) ,
  .clk           (HCLK            ) ,
  .scli          (scli            ) ,
  .sdai          (sdai            ) ,
  .sdao          (s_sdao          ) ,
  .sdaoe         (s_sdaoe         ) ,
  .i2c_slver_int (i2c_slver_int   ) ,
  .i2c_en        (i2c_en & i2c_ms ) ,
  .i2c_ack       (i2c_ack         ) ,
  .i2c_adr       (i2c_adr_w       ) ,
  .i2c_wr_r      (i2c_wr_slv      ) ,
  .FIFOempty     (FIFOempty       ) ,
  .FIFOrd_en     (FIFOrd_en_slaver) ,
  .FIFOdata      (FIFOdata        ) ,
  .i2c_rxbf_set  (i2c_rxbf_set_slv) ,
  .rx_buf        (rx_buf_slv      )
);


I2C_Master u_I2C_Master
(
  .rst           (HRESETn         ) ,
  .clk           (HCLK            ) ,
  .sclo          (sclo            ) ,
  .scloe         (scloe           ) ,
  .sdai          (sdai            ) ,
  .sdao          (m_sdao          ) ,
  .sdaoe         (m_sdaoe         ) ,
  .i2c_master_int(i2c_master_int  ) ,
  .i2c_wr_w      (i2c_wr_w        ) ,
  .i2c_adr_w     (i2c_adr_w       ) ,
  .i2c_start     (i2c_start       ) ,
  .i2c_stop      (i2c_stop        ) ,
  .i2c_auto      (i2c_auto        ) ,
  .i2c_autodetectack_en      (i2c_autodetectack_en        ) ,
  .i2c_en        (i2c_en & ~i2c_ms) ,
  .i2c_ack       (i2c_ack         ) ,
  .FIFOempty     (FIFOempty       ) ,
  .FIFOrd_en     (FIFOrd_en_master) ,
  .FIFOdata      (FIFOdata        ) ,
  .cnt_set       (cnt_set         ) ,
  .i2c_rxbf_set  (i2c_rxbf_set_mst) ,
  .i2c_nackf_set (i2c_nackf_set_mst) ,
  .sigbyte_finishf (sigbyte_finishf) ,
  .stop_f        (stop_f          ) ,
  .rx_buf        (rx_buf_mst      )
);

AHBlite_I2C u_AHBlite_I2C
(
  .HCLK            (HCLK            ),
  .HRESETn         (HRESETn         ),
  .HSEL            (HSEL            ),
  .HADDR           (HADDR           ),
  .HTRANS          (HTRANS          ),
  .HSIZE           (HSIZE           ),
  .HPROT           (HPROT           ),
  .HWRITE          (HWRITE          ),
  .HWDATA          (HWDATA          ),
  .HREADY          (HREADY          ),
  .HREADYOUT       (HREADYOUT       ),
  .HRDATA          (HRDATA          ),
  .HRESP           (HRESP           ),
  .i2c_rxbuf_f     (i2c_rxbuf_f     ),
  .i2c_wr_r        (i2c_wr_w        ),
  .i2c_wr_slv      (i2c_wr_slv      ),
  .i2c_adr_r       (i2c_adr_w       ),
  .i2c_start       (i2c_start       ),
  .i2c_stop        (i2c_stop        ),
  .i2c_auto        (i2c_auto        ),
  .i2c_autodetectack_en        (i2c_autodetectack_en        ),
  .i2c_en          (i2c_en          ),
  .i2c_ack         (i2c_ack         ),
  .i2c_ms          (i2c_ms          ),
  .FIFOfull        (FIFOfull        ),
  .FIFOempty       (FIFOempty       ),
  .i2c_rxbf_set    (i2c_rxbf_set    ),
  .i2c_nackf_set   (i2c_nackf_set   ),
  .sigbyte_finishf (sigbyte_finishf ),
  .cnt_set         (cnt_set         ),
  .stop_f          (stop_f          ),
  .tx_en           (tx_en           ),
  .tx_data         (tx_data         ),
  .rx_buf          (rx_buf          )
);

endmodule