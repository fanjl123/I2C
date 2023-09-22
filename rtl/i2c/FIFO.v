

//it is just a normal FIFO
module FIFO(
    input clock,
    input sclr,

    input rdreq, wrreq,
    output reg full, empty,

    input [7 : 0] data,
    output [7 : 0] q

);

reg [7 : 0] mem [15 : 0];
reg [3 : 0] wp, rp;
reg w_flag, r_flag;

// initial
// begin
// wp=0;
// w_flag=0;
// rp=0;
// r_flag=0;
// end

wire [3 : 0]  wp_w ;
wire   w_flag_w ;
assign wp_w = (&wp) ? 0 : wp+1;
assign w_flag_w = (&wp) ? ~w_flag : w_flag;


always @(posedge clock) begin
    if (~sclr) begin
        wp <= 0;
        w_flag <= 0;
    end else if(!full && wrreq) begin
        wp<= wp_w;
        w_flag <= w_flag_w;
    end
end

always @(posedge clock) begin
    if(wrreq && !full)begin
        mem[wp] <= data;
    end
end
wire [3 : 0]  rp_w    ;
wire   r_flag_w ;
assign rp_w     = (&rp) ? 0 : rp+1;
assign r_flag_w = (&rp) ? ~r_flag : r_flag;


always @(posedge clock) begin
    if (~sclr) begin
        rp<=0;
        r_flag <= 0;
    end else if(!empty && rdreq) begin
        rp<=      rp_w;
        r_flag <= r_flag_w;
    end
end

assign q = mem[rp];

always @(*) begin
    if(wp==rp)begin
        if(r_flag==w_flag)begin
            full <= 0;
            empty <= 1;
        end else begin
            full <= 1;
            empty <= 0;
        end
    end else begin
        full <= 0;
        empty <= 0;
    end
end



endmodule