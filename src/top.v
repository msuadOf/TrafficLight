module top (
    input  wire         clk,
    input  wire         rst_n,
    output wire [  1:0] debug,
    output wire [7-1:0] seg71_d,
    output wire [4-1:0] seg71_sel,

    //R Y G
    output wire R1,
    output wire Y1,
    output wire G1,

    output wire R2,
    output wire Y2,
    output wire G2,

    input wire K_Night
);


  wire clk_10k;
  wire clk_500;
  wire clk_1s;
  clk_div #(
      .div_n_RegWith(64)
  ) c1 (
      .clk    (clk),
    //   .div_n  (12_000_000  - 1),
    .div_n  (12_000_000/12_000_00  - 1),
      .rst_n  (1),
      .clk_out(clk_1s)
  );
  clk_div #(
      .div_n_RegWith(64)
  ) c2 (
      .clk    (clk),
      .div_n  (12_000_000 / 500 - 1),
      .rst_n  (1),
      .clk_out(clk_500)
  );


  wire [ 32:0] none;
  // seg7 seg1(
  //     .clk(clk_500),
  //     .reset_n(1),
  //     .q_a({4'd1,4'd2,4'd3,4'd4}),
  //     .data({seg71_d,none[0]}),
  //     .sel(seg71_sel)
  //);

  //disp api
  wire [7-1:0] seg71_disp_bin[2-1:0];
  wire [8-1:0] seg71_disp_bcd[2-1:0];
  bin2bcd b2b1_0 (
      .bin(seg71_disp_bin[0]),  // binary
      .bcd(seg71_disp_bcd[0])
  );
  bin2bcd b2b1_1 (
      .bin(seg71_disp_bin[1]),  // binary
      .bcd(seg71_disp_bcd[1])
  );
  numlight seg1 (
      .clk_500(clk_500),

      .fir(seg71_disp_bcd[1][8-1:5-1]),
      .sec(seg71_disp_bcd[1][4-1:1-1]),
      .thi(seg71_disp_bcd[0][8-1:5-1]),
      .fou(seg71_disp_bcd[0][4-1:1-1]),

      .bitchose(seg71_sel),
      .num     (seg71_d)
  );
  assign debug = {clk, SinglePeriod_start_pulse};

  // clk_1s --> clk_1s_pulse
  wire clk_1s_pulse;
  reg clk_1s_r = 0, clk_1s_rr = 0;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clk_1s_r  <= 0;
      clk_1s_rr <= 0;
    end else begin
      clk_1s_r  <= clk_1s;
      clk_1s_rr <= clk_1s_r;
    end
  end

  assign clk_1s_pulse = !clk_1s_r & clk_1s_rr;

  //RYG fsm
  reg [6:0] RYG_state = 0;
  parameter RYG_state_Night = 0, RYG_state_group1 = 1, RYG_state_group1to2 = 2, RYG_state_group2 = 3, RYG_state_group2to1 = 4;
  /**
*   g1 -> g1to2 
    ^       |
    |       v
  g2to1 <-  g2
*/
  //api:
  wire [10:0] RYG_cnt_set, RG_cnt_set, Y_cnt_set;
  assign RYG_cnt_set = ((RYG_state == RYG_state_group1) || (RYG_state == RYG_state_group2)) ? (RG_cnt_set) : (Y_cnt_set);

  reg [10:0] RYG_cnt = 0;
  reg        SinglePeriod_start_pulse = 0;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      RYG_state                <= RYG_state_Night;

    end else begin
      if (K_Night == 1) begin
        RYG_state <= RYG_state_Night;
      end else begin
        if (RYG_cnt == 0) begin
              SinglePeriod_start_pulse <= 1;
          RYG_state<=(RYG_state==RYG_state_Night)?(RYG_state_group1)
                    :((RYG_state==RYG_state_group1)?(RYG_state_group1to2)
                    :((RYG_state==RYG_state_group1to2)?(RYG_state_group2)
                    :((RYG_state==RYG_state_group2)?(RYG_state_group2to1)
                    :((RYG_state==RYG_state_group2to1)?(RYG_state_group1)
                    :(RYG_state_Night)))));//when it occurs , error happens

        
        end else begin
            SinglePeriod_start_pulse<=0;
          RYG_state <= RYG_state;
        end
      end

    end
  end

  //SinglePeriod

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      RYG_cnt <= 0;
    end else begin
      if ((RYG_state != RYG_state_group1) && (RYG_state != RYG_state_group1to2) && (RYG_state != RYG_state_group2) && (RYG_state != RYG_state_group2to1)) begin
        RYG_cnt <= 0;//do when Night state
      end else begin
        if (SinglePeriod_start_pulse) begin
          RYG_cnt <= RYG_cnt_set;
        end else begin
          if (clk_1s_pulse && RYG_cnt > 0) begin
            RYG_cnt <= RYG_cnt - 1;
          end else begin
            RYG_cnt <= RYG_cnt;
          end
        end
      end
    end
  end

  reg R1_r = 0;
  reg Y1_r = 0;
  reg G1_r = 0;
  reg R2_r = 0;
  reg Y2_r = 0;
  reg G2_r = 0;
  assign {R1, Y1, G1, R2, Y2, G2} = {R1_r, Y1_r, G1_r, R2_r, Y2_r, G2_r};
always @(*) begin

      case (RYG_state)
        RYG_state_Night:{R1_r, Y1_r, G1_r, R2_r, Y2_r, G2_r}<={0,1,0,0,1,0};
        RYG_state_group1 :{R1_r, Y1_r, G1_r, R2_r, Y2_r, G2_r}<={0,0,1,1,0,0};
        RYG_state_group1to2 :{R1_r, Y1_r, G1_r, R2_r, Y2_r, G2_r}<={1,0,0,0,1,0};
        RYG_state_group2 :{R1_r, Y1_r, G1_r, R2_r, Y2_r, G2_r}<={1,0,0,0,0,1};
        RYG_state_group2to1 :{R1_r, Y1_r, G1_r, R2_r, Y2_r, G2_r}<={0,1,0,1,0,0};
      endcase

end

  //
  assign seg71_disp_bin[0]       = 96;
  assign seg71_disp_bin[1]       = 75;

  //
  assign {RG_cnt_set, Y_cnt_set} = {10'd6, 10'd4};
endmodule  //top
