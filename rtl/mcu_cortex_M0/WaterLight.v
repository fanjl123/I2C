module WaterLight(
    input [1:0] WaterLight_mode,
    input [31:0] WaterLight_speed,
    input clk,
    input RSTn,
    output reg [1:0] LED,
    output wire LEDclk
);

//------------------------------------------------------
//  PWM
//------------------------------------------------------

reg [31:0] pwm_cnt;

always@(posedge clk or negedge RSTn) begin
    if(~RSTn) pwm_cnt <= 32'b0;
    else if(pwm_cnt == WaterLight_speed) pwm_cnt <= 32'b0;
    else pwm_cnt <= pwm_cnt + 1'b1;
end

reg light_clk;

always@(posedge clk or negedge RSTn) begin
    if(~RSTn) light_clk <= 1'b0;
    else if(pwm_cnt == WaterLight_speed) light_clk <= ~light_clk;
end

assign LEDclk = light_clk;

//------------------------------------------------------
//  LEFT MODE
//------------------------------------------------------

//2023-6-25修改-周
//reg [1:0] mode1;

/*always@(posedge light_clk or negedge RSTn) begin
    if(~RSTn) mode1 <= 2'b11;
    else begin
         mode1 <= 2'b10;
        
    end
end
*/
//------------------------------------------------------
//  RIGHT MODE
//------------------------------------------------------

/*reg [1:0] mode2;

always@(posedge light_clk or negedge RSTn) begin
    if(~RSTn) mode2 <= 2'b00;
    else begin
         mode2 <= 2'b10;
    end
end*/

//------------------------------------------------------
//  FLASH MODE
//------------------------------------------------------
wire [1:0] mode1;
wire [1:0] mode2;
wire [1:0] mode3;

assign mode1 = (light_clk == 1'b0) ? 2'b01 : 2'b00;
assign mode2 = (light_clk == 1'b0) ? 2'b10 : 2'b00;
assign mode3 = (light_clk == 1'b0) ? 2'b11 : 2'b00;

//------------------------------------------------------
//  OUTPUT MUX
//------------------------------------------------------

always@(*) begin
    case(WaterLight_mode)
    2'b01 : begin LED = mode1;end  
    2'b10 : begin LED = mode2;end
    2'b11 : begin LED = mode3;end
    default : begin LED = 2'b00;end
    endcase
end

endmodule
