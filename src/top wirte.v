module top (
    input  wire clk,
    input wire rst_n,
    output wire [1:0] debug,
    output wire [7-1:0] seg71_d,
    output wire [4-1:0] seg71_sel

);


   wire clk_10k;
   wire clk_500;
   wire clk_1s;
   clk_div  #(
    .div_n_RegWith(64)
   )c1(
    .clk(clk),
    .div_n(12_000_000-1),
   .rst_n(1),
    .clk_out(clk_1s)
);
   clk_div  #(
    .div_n_RegWith(64)
   )c2(
    .clk(clk),
    .div_n(12_000_000/500-1),
   .rst_n(1),
    .clk_out(clk_500)
);
   

   wire [32:0] none;
// seg7 seg1(
//     .clk(clk_500),
//     .reset_n(1),
//     .q_a({4'd1,4'd2,4'd3,4'd4}),
//     .data({seg71_d,none[0]}),
//     .sel(seg71_sel)
//);
 numlight l2(
        .clk_500(clk_500),
        
        .fir(1),
        .sec(2),
        .thi(3),
        .fou(4),
        
        .bitchose(seg71_sel),
        .num(seg71_d)
    );
assign debug={clk,clk_1s};


endmodule //top