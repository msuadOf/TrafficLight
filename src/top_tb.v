`timescale 1ns / 1ps
module top_tb (
);
reg clk=0,rst_n=0,K_Night=0;
reg [2-1:0]Key_state;
reg Key_plus,Key_sub;
top y(
            clk,
    debug,
    seg71_d,
    seg71_sel,
    seg72_d,
    seg72_sel,
    o_R1,
    o_Y1,
    o_G1,
    o_R2,
    o_Y2,
    o_G2,
    o_R1_L,
    o_Y1_L,
    o_G1_L,
    o_R2_L,
    o_Y2_L,
    o_G2_L,
    Key_state,
 Key_plus,
 Key_sub,
    SN74HC595_data,
    SN74HC595_data_clk,
    SN74HC595_refresh_clk

);
always #10 clk=~clk;
initial begin
   // # 50 rst_n=1;
   Key_state=00;
   {Key_plus,Key_sub}=2'b00;
end
endmodule //top_tb
