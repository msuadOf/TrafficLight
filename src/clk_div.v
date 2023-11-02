module clk_div #(
    parameter div_n_RegWith = 10
) (
    input  wire                     clk,
    input  wire [div_n_RegWith-1:0] div_n,
    input  wire                     rst_n,
    output wire                     clk_out
);
  //div clock
  reg                     div_clk;

  reg [div_n_RegWith-1:0] div_clk_cnt;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) div_clk_cnt = 0;
    else if (div_clk_cnt < div_n) div_clk_cnt = div_clk_cnt + 1;
    else div_clk_cnt = 0;
  end

  always @(*) begin

    if (div_clk_cnt <= (div_n / 2)) div_clk = 1;
    else div_clk = 0;

  end

  assign clk_out = (div_n == 0) ? (clk) : (div_clk);
endmodule  //clk_div
