`timescale 1ns / 1ps
module top_tb (
);
reg clk=0,rst_n=0,K_Night=0;
   top t(
    clk,
   // rst_n,
    debug,
    seg71_d,
    seg71_sel,

    //R Y G
    R1,
    Y1,
    G1,

    R2,
    Y2,
    G2,

    Key_state,
    Key_plus,
    Key_sub
);
always #10 clk=~clk;
initial begin
   // # 50 rst_n=1;
   Key_state=11;
end
endmodule //top_tb
