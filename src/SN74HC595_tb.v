module SN74HC595_tb (
);
reg clk=0,rst_n=0;
always #10 clk=~clk;
initial #50 rst_n=1;
SN74HC595 z1(
       clk,
       rst_n,
       8'b0000_1111,
      SN74HC595_data,
    SN74HC595_data_clk,
    SN74HC595_refresh_clk
);
endmodule //SN74HC595