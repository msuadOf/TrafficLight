module SN74HC595 (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [8-1:0] i_buf,
    output wire         SN74HC595_data,
    output wire         SN74HC595_data_clk,
    output wire         SN74HC595_refresh_clk
);
  wire data, data_clk;


  clk_div #(
      .div_n_RegWith(64)
  ) _SN74HC595_div_500_ (
      .clk    (clk),
      .div_n  ({0, 12_000_000/12_000 - 1}),
      .rst_n  (rst_n),
      .clk_out(data_clk)
  );

  clk_div #(
      .div_n_RegWith(64)
  ) _SN74HC595_div_500_8_ (
      .clk    (data_clk),
      .div_n  ({0, 8 - 1}),
      .rst_n  (rst_n),
      .clk_out(SN74HC595_refresh_clk)
  );
  reg [8-1:0] i_buf_r;

  reg data_clk_r = 0, SN74HC595_refresh_clk_r = 0;
  wire data_clk_pulse, SN74HC595_refresh_clk_pulse;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      i_buf_r                 <= 0;
      data_clk_r              <= 0;
      SN74HC595_refresh_clk_r <= 0;
    end else begin
      i_buf_r                 <= i_buf;
      data_clk_r              <= data_clk;
      SN74HC595_refresh_clk_r <= SN74HC595_refresh_clk;
    end
  end

  assign data_clk_pulse              = data_clk_r & ~data_clk;
  assign SN74HC595_refresh_clk_pulse = ~SN74HC595_refresh_clk_r & SN74HC595_refresh_clk;

  reg o_sdata = 0;
  assign data = o_sdata;
  reg [10:0] cnt = 0;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      o_sdata <= 0;
      cnt     <= 0;
    end else begin
      if (data_clk_pulse) begin

        if (cnt <= 7) begin
          o_sdata <= i_buf_r[cnt];
          cnt     <= (cnt == 7) ? (0) : (cnt + 1);
        end else begin
          o_sdata <= 0;
          cnt     <= 0;
        end
      end else begin
        o_sdata <= o_sdata;
        cnt     <= cnt;
      end

    end
  end
  assign SN74HC595_data     = data;
  assign SN74HC595_data_clk = data_clk;
endmodule  //SN74HC595
