//`define SIM
`define DEBUG
module top (
    input  wire         clk,
    //input  wire         rst_n,
    output wire [  1:0] SIM,
    output wire [7-1:0] seg71_d,
    output wire [4-1:0] seg71_sel,

    output wire [7-1:0] seg72_d,
    output wire [4-1:0] seg72_sel,

    //R Y G
    output wire o_R1,
    output wire o_Y1,
    output wire o_G1,
    output wire o_R2,
    output wire o_Y2,
    output wire o_G2,

    output wire o_R1_L,
    output wire o_Y1_L,
    output wire o_G1_L,
    output wire o_R2_L,
    output wire o_Y2_L,
    output wire o_G2_L,

    input wire [2-1:0] Key_state,
    input wire         Key_plus,
    input wire         Key_sub,

    output wire SN74HC595_data,
    output wire SN74HC595_data_clk,
    output wire SN74HC595_refresh_clk
);
//LED
    wire R1;
    wire Y1;
    wire G1;
    wire R2;
    wire Y2;
    wire G2;

    wire R1_L;
    wire Y1_L;
    wire G1_L;
    wire R2_L;
    wire Y2_L;
    wire G2_L;

assign {    o_R1,o_Y1,o_G1,o_R2,o_Y2,o_G2}={    R1,Y1,G1,R2,Y2,G2};
assign {    o_R1_L,o_Y1_L,o_G1_L,o_R2_L,o_Y2_L,o_G2_L}={    R1_L,Y1_L,G1_L,R2_L,Y2_L,G2_L};



  wire rst_n = 1;
  parameter CNT_WIDTH = 10 + 1;

  parameter setRGCnt_default = 11'd8;
  parameter setYCnt_default = 11'd6;

  wire isNight, isRun, isSetRGCnt, isSetYCnt;
  assign isRun      = (Key_state == 2'b00) ? (1'd1) : (1'd0);
  assign isNight    = (Key_state == 2'b01) ? (1'd1) : (1'd0);
  assign isSetRGCnt = (Key_state == 2'b10) ? (1'd1) : (1'd0);
  assign isSetYCnt  = (Key_state == 2'b11) ? (1'd1) : (1'd0);

//state
  reg [6:0] RYG_state = 7'd0;
  parameter RYG_state_Night               = 7'd0, 
              RYG_state_group1            = 7'd1,
              RYG_state_group1to1L        = 7'd2,  
              RYG_state_group1L           = 7'd3,
              RYG_state_group1Lto2        = 7'd4, 
              RYG_state_group2            = 7'd5, 
              RYG_state_group2to2L        = 7'd6,
              RYG_state_group2L           = 7'd7,
              RYG_state_group2Lto1        = 7'd8,
              RYG_state_group1_interrupt  = 7'd9,
              RYG_state_group2_interrupt  = 7'd10;

  wire clk_10k;
  wire clk_500;
  wire clk_1s;
  clk_div #(
      .div_n_RegWith(64)
  ) c1 (
      .clk(clk),
      //  .div_n  (12_000_000  - 1),

`ifdef SIM
      .div_n  ({0, 12_000_000 / 12_000_00 - 1}),
`else
      .div_n  ({0, 12_000_000 / 1 - 1}),
`endif
      .rst_n  (1),
      .clk_out(clk_1s)
  );
  clk_div #(
      .div_n_RegWith(64)
  ) c2 (
      .clk    (clk),
      .div_n  ({0, 12_000_000 / 500 - 1}),
      .rst_n  (1),
      .clk_out(clk_500)
  );

wire [7:0] SN74HC595_buf;
 SN74HC595 u_SN74HC595(
    .clk(clk),
    .rst_n(rst_n),
    .i_buf(SN74HC595_buf),
    .SN74HC595_data(SN74HC595_data),
    .SN74HC595_data_clk(SN74HC595_data_clk),
    .SN74HC595_refresh_clk(SN74HC595_refresh_clk)
);

  wire [  32:0] none;
  

  //seg71
  wire [14-1:0] seg71_disp_bin;
  wire [16-1:0] seg71_disp_bcd;
  wire [ 2-1:0] seg71_none;
  bin2bcd #(
      .W(14)
  )  // input width
      b2b1 (
      .bin(seg71_disp_bin),                              // binary
      .bcd({seg71_none[2-1:0], seg71_disp_bcd[16-1:0]})
  );

  numlight seg71 (
      .clk_500(clk_500),

      .fir(seg71_disp_bcd[16-1:13-1]),
      .sec(seg71_disp_bcd[12-1:9-1]),
      .thi(seg71_disp_bcd[8-1:5-1]),
      .fou(seg71_disp_bcd[4-1:1-1]),


      .bitchose(seg71_sel),
      .num     (seg71_d)
  );

  //seg72
  wire [14-1:0] seg72_disp_bin;
  wire [16-1:0] seg72_disp_bcd;
  wire [ 2-1:0] seg72_none;
  bin2bcd #(
      .W(14)
  )  // input width
      b2b2 (
      .bin(seg72_disp_bin),                              // binary
      .bcd({seg72_none[2-1:0], seg72_disp_bcd[16-1:0]})
  );

  numlight seg72 (
      .clk_500(clk_500),

`ifdef DEBUG
      .fir(RYG_state),
`else
      .fir(seg72_disp_bcd[16-1:13-1]),
`endif

      .sec(seg72_disp_bcd[12-1:9-1]),
      .thi(seg72_disp_bcd[8-1:5-1]),
      .fou(seg72_disp_bcd[4-1:1-1]),


      .bitchose(seg72_sel),
      .num     (seg72_d)
  );
  //+=======================
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

//key press -> pulse
//Plus+Sub
  reg Key_plus_r = 0, Key_plus_rr = 0, Key_sub_r = 0, Key_sub_rr = 0;
  wire Key_plus_pulse, Key_sub_pulse;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      Key_plus_r  <= 0;
      Key_plus_rr <= 0;
      Key_sub_r   <= 0;
      Key_sub_rr  <= 0;
    end else begin
      Key_plus_r  <= Key_plus;
      Key_plus_rr <= Key_plus_r;
      Key_sub_r   <= Key_sub;
      Key_sub_rr  <= Key_sub_r;
    end
  end
  assign Key_plus_pulse = ~Key_plus_r & Key_plus_rr;
  assign Key_sub_pulse  = ~Key_sub_r & Key_sub_rr;

//Key_groupx_
wire Key_group1_interrupt_pulse,Key_group2_interrupt_pulse;
assign {Key_group1_interrupt_pulse,Key_group2_interrupt_pulse}={Key_sub_pulse,Key_plus_pulse};


  //RYG fsm

  /**
*   g1 -> g1to2 
    ^       |
    |       v
  g2to1 <-  g2
*/
  //api:
  wire [CNT_WIDTH-1:0] RYG_cnt_set, RG_cnt_set, Y_cnt_set;
  assign RYG_cnt_set = ((RYG_state == RYG_state_group1) 
                        || (RYG_state == RYG_state_group2)
                        || (RYG_state == RYG_state_group1L)
                        || (RYG_state == RYG_state_group2L)) ? (RG_cnt_set) 
                                                            : (((RYG_state == RYG_state_group1_interrupt)
                                                                  ||(RYG_state == RYG_state_group2_interrupt))?(10'd5)
                                                                                                            :(Y_cnt_set));
 // assign RYG_cnt_set = ((RYG_state == RYG_state_group1) || (RYG_state == RYG_state_group2)) ? (RG_cnt_set) : (Y_cnt_set);


  reg [CNT_WIDTH-1:0] RYG_cnt = 0;
  reg                 SinglePeriod_start_pulse = 0;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      RYG_state <= RYG_state_Night;

    end
    else begin
      if (isNight == 1) begin
        RYG_state <= RYG_state_Night;
      end 
      else begin
           
        if (RYG_cnt == 0 && SinglePeriod_start_pulse == 0) begin
          SinglePeriod_start_pulse <= 1;
          if (isRun) begin
            RYG_state<=(RYG_state==RYG_state_Night)?(RYG_state_group1)
                    :((RYG_state==RYG_state_group1)?(RYG_state_group1to1L)
                    :((RYG_state==RYG_state_group1to1L)?(RYG_state_group1L)
                    :((RYG_state==RYG_state_group1L)?(RYG_state_group1Lto2)
                    :((RYG_state==RYG_state_group1Lto2)?(RYG_state_group2)
                    :((RYG_state==RYG_state_group2)?(RYG_state_group2to2L)
                    :((RYG_state==RYG_state_group2to2L)?(RYG_state_group2L)
                    :((RYG_state==RYG_state_group2L)?(RYG_state_group2Lto1)
                    :((RYG_state==RYG_state_group2Lto1)?(RYG_state_group1)
                    :((RYG_state==RYG_state_group1_interrupt)?(RYG_state_group1)
                    :((RYG_state==RYG_state_group2_interrupt)?(RYG_state_group2)
                    :(RYG_state_Night))))))))))); //when it occurs , error happens
          end else begin
            if(Key_group1_interrupt_pulse||Key_group2_interrupt_pulse) begin
          RYG_state <=(Key_group1_interrupt_pulse)?(RYG_state_group1_interrupt):(RYG_state_group2_interrupt);
            end else begin
              RYG_state <= RYG_state;
            end
              
          end

        end else begin
          SinglePeriod_start_pulse <= 0;
          RYG_state                <= RYG_state;
        end
      
      end

    end
  end

  //SinglePeriod

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      RYG_cnt <= 0;
    end else begin
      if (RYG_state == RYG_state_Night) begin
        RYG_cnt <= 0;  //do when Night state
      end else begin
        if (SinglePeriod_start_pulse) begin
          RYG_cnt <= RYG_cnt_set;
        end else begin
          if (clk_1s_pulse && RYG_cnt > 0 && isRun) begin
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

  reg R1_L_r=0;
  reg Y1_L_r=0;
  reg G1_L_r=0;
  reg R2_L_r=0;
  reg Y2_L_r=0;
  reg G2_L_r=0;

  assign {R1, Y1, G1, R1_L, Y1_L, G1_L,  R2, Y2, G2, R2_L, Y2_L, G2_L} = {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r};
  always @(*) begin

    case (RYG_state)

//                                                                                                                                g1               g1_1L             g2              g2_L
      RYG_state_Night            :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b0,1'b1,1'b0, 1'b0,1'b1,1'b0,  1'b0,1'b1,1'b0, 1'b0,1'b1,1'b0};
      RYG_state_group1           :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b0,1'b0,1'b1, 1'b1,1'b0,1'b0,  1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0};
      RYG_state_group1to1L       :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b0,1'b1,1'b0, 1'b1,1'b0,1'b0,  1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0};
      RYG_state_group1L          :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b1,1'b0,1'b0, 1'b0,1'b0,1'b1,  1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0};
      RYG_state_group1Lto2       :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b1,1'b0,1'b0, 1'b0,1'b1,1'b0,  1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0};
      RYG_state_group2           :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0,  1'b0,1'b0,1'b1, 1'b1,1'b0,1'b0};
      RYG_state_group2to2L       :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0,  1'b0,1'b1,1'b0, 1'b1,1'b0,1'b0};
      RYG_state_group2L          :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0,  1'b1,1'b0,1'b0, 1'b0,1'b0,1'b1};
      RYG_state_group2Lto1       :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0,  1'b1,1'b0,1'b0, 1'b0,1'b1,1'b0};

      RYG_state_group1_interrupt :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b0,1'b1,1'b0, 1'b1,1'b0,1'b0,  1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0};
      RYG_state_group2_interrupt :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= {1'b1,1'b0,1'b0, 1'b1,1'b0,1'b0,  1'b0,1'b1,1'b0, 1'b1,1'b0,1'b0};
      default               :   {R1_r, Y1_r, G1_r,R1_L_r, Y1_L_r, G1_L_r,   R2_r, Y2_r, G2_r, R2_L_r, Y2_L_r, G2_L_r} <= 12'b0;
    endcase

  end

  //isSetRGCnt
  reg [CNT_WIDTH-1:0] setRGCnt_r = setRGCnt_default;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      setRGCnt_r <= setRGCnt_default;
    end else begin
      if (isSetRGCnt == 1) begin
        setRGCnt_r <= (Key_plus_pulse) ? (setRGCnt_r + 1) : ((Key_sub_pulse) ? (setRGCnt_r - 1) : (setRGCnt_r));
      end else begin
        setRGCnt_r <= setRGCnt_r;
      end
    end
  end

  //isSetYCnt
  reg [CNT_WIDTH-1:0] setYCnt_r = setYCnt_default;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      setYCnt_r <= setYCnt_default;
    end else begin
      if (isSetYCnt == 1) begin
        setYCnt_r <= (Key_plus_pulse) ? (setYCnt_r + 1) : ((Key_sub_pulse) ? (setYCnt_r - 1) : (setYCnt_r));
      end else begin
        setYCnt_r <= setYCnt_r;
      end
    end
  end
  assign {RG_cnt_set, Y_cnt_set} = {setRGCnt_r, setYCnt_r};

  //seg1
  wire [CNT_WIDTH-1:0] RYGcnt_Display;
  assign RYGcnt_Display = {0, (RYG_state == RYG_state_group2) ? (RYG_cnt + Y_cnt_set) : (RYG_cnt)};
  assign seg71_disp_bin = {0,(isSetRGCnt) ? (setRGCnt_r) : ((isSetYCnt) ? (setYCnt_r) : (RYGcnt_Display))};


  //seg2
  reg [16-1:0] seg72_disp_bin_r;
  assign seg72_disp_bin = {0, (RYG_state == RYG_state_group1) ? (RYG_cnt + Y_cnt_set) : (RYG_cnt)};
  //assign seg72_disp_bin = {0, (RYG_cnt)};
  // always @(*) begin
  //   case(RYG_state)
  //     RYG_state_group1:seg72_disp_bin_r=RYG_cnt;
  //   endcase
  // end
  // wire [16-1:0] seg72_disp_bin;
  //
 assign SN74HC595_buf={G2_L,Y2_L,Y1,R1,G1,G1_L,Y1_L,R1_L};//{1'b1,1'b1,1'b1,1'b1,1'b1,1'b1,1'b1};//
// assign SN74HC595_buf={1'd0,1'd0,Y1,R1,G1,G2,Y2,R2};
  assign SIM          = {clk, SinglePeriod_start_pulse};
endmodule  //top
