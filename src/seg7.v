module seg7 (
    input             clk,
    input             reset_n,
    input      [15:0] q_a,
    output reg [ 7:0] data,
    output reg [ 3:0] sel
);
  reg [29:0] cnt;
  reg [ 1:0] scn_cnt;
  reg        clk0;
  always @(posedge clk or negedge reset_n)
    if (~reset_n) cnt <= 0;
    else begin
      cnt <= cnt + 1;
      if (cnt == 10000 - 1) clk0 <= 1;
      else if (cnt == 100000 - 1) begin
        clk0 <= 0;
        cnt  <= 0;
      end
    end
  always @(posedge clk0 or negedge reset_n)
    if (~reset_n) scn_cnt <= 2'b00;
    else begin
      if (scn_cnt == 2'b11) scn_cnt <= 2'b00;
      else scn_cnt <= scn_cnt + 1'b1;
    end
  always @(posedge clk0 or negedge reset_n)
    if (~reset_n) sel <= 4'b1111;
    else
      case (scn_cnt)
        2'b00:   sel <= 4'b1110;
        2'b01:   sel <= 4'b1101;
        2'b10:   sel <= 4'b1011;
        2'b11:   sel <= 4'b0111;
        default: sel <= 4'b1111;
      endcase
  always @(posedge clk0 or negedge reset_n)
    if (~reset_n) data = 8'b11111111;
    else begin
      if (sel == 4'b0111) begin
        case (q_a[15:12])
          4'h0: data = 8'b00000011;
          4'h1: data = 8'b10011111;
          4'h2: data = 8'b00100101;
          4'h3: data = 8'b00001101;
          4'h4: data = 8'b10011001;
          4'h5: data = 8'b01001001;
          4'h6: data = 8'b01000001;
          4'h7: data = 8'b00011111;
          4'h8: data = 8'b00000001;
          4'h9: data = 8'b00001001;
          4'ha: data = 8'b00010001;
          4'hb: data = 8'b11000001;
          4'hc: data = 8'b01100011;
          4'hd: data = 8'b10000101;
          4'he: data = 8'b01100001;
          4'hf: data = 8'b01110001;
          default: data = 8'b11111111;
        endcase
      end else if (sel == 4'b1011) begin
        case (q_a[11:8])
          4'h0: data = 8'b00000011;
          4'h1: data = 8'b10011111;
          4'h2: data = 8'b00100101;
          4'h3: data = 8'b00001101;
          4'h4: data = 8'b10011001;
          4'h5: data = 8'b01001001;
          4'h6: data = 8'b01000001;
          4'h7: data = 8'b00011111;
          4'h8: data = 8'b00000001;
          4'h9: data = 8'b00001001;
          4'ha: data = 8'b00010001;
          4'hb: data = 8'b11000001;
          4'hc: data = 8'b01100011;
          4'hd: data = 8'b10000101;
          4'he: data = 8'b01100001;
          4'hf: data = 8'b01110001;
          default: data = 8'b11111111;
        endcase
      end else if (sel == 4'b1101) begin
        case (q_a[7:4])
          4'h0: data = 8'b00000011;
          4'h1: data = 8'b10011111;
          4'h2: data = 8'b00100101;
          4'h3: data = 8'b00001101;
          4'h4: data = 8'b10011001;
          4'h5: data = 8'b01001001;
          4'h6: data = 8'b01000001;
          4'h7: data = 8'b00011111;
          4'h8: data = 8'b00000001;
          4'h9: data = 8'b00001001;
          4'ha: data = 8'b00010001;
          4'hb: data = 8'b11000001;
          4'hc: data = 8'b01100011;
          4'hd: data = 8'b10000101;
          4'he: data = 8'b01100001;
          4'hf: data = 8'b01110001;
          default: data = 8'b11111111;
        endcase
      end else begin
        case (q_a[3:0])
          4'h0: data = 8'b00000011;
          4'h1: data = 8'b10011111;
          4'h2: data = 8'b00100101;
          4'h3: data = 8'b00001101;
          4'h4: data = 8'b10011001;
          4'h5: data = 8'b01001001;
          4'h6: data = 8'b01000001;
          4'h7: data = 8'b00011111;
          4'h8: data = 8'b00000001;
          4'h9: data = 8'b00001001;
          4'ha: data = 8'b00010001;
          4'hb: data = 8'b11000001;
          4'hc: data = 8'b01100011;
          4'hd: data = 8'b10000101;
          4'he: data = 8'b01100001;
          4'hf: data = 8'b01110001;
          default: data = 8'b11111111;
        endcase
      end
    end
endmodule
