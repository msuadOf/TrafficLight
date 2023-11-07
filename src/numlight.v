`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/12 10:18:21
// Design Name: 
// Module Name: numlight
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module numlight(
    input clk_500,
    
    input [3:0] fir,
    input [3:0] sec,
    input [3:0] thi,
    input [3:0] fou,
    
    
    output reg [3:0] bitchose,
    output reg [6:0] num
    );
    
    parameter errcod = 7'b1111110;
    parameter zero = 7'b0000001;
    parameter one = 7'b1001111;
    parameter two = 7'b0010010;
    parameter three = 7'b0000110;
    parameter four = 7'b1001100;
    parameter five = 7'b0100100;
    parameter six = 7'b0100000;
    parameter seven = 7'b0001111;
    parameter eight = 7'b0000000;
    parameter nine = 7'b0000100;
    parameter db = 7'b1100000;
        
    //    parameter za = db;
    //    parameter zb = two;
    //    parameter zc = one;
    //    parameter zd = one;
    //    parameter ze = two;
    //    parameter zf = zero;
    //    parameter zg = three;
    //    parameter zh = one;
    //    parameter zi = two;
    
    reg [6:0] numreg=errcod;
    reg [3:0] bitreg=4'b1111;
    
    reg [6:0] firreg=errcod;
    reg [6:0] secreg=errcod;
    reg [6:0] thireg=errcod;
    reg [6:0] foureg=errcod;
    
    reg [1:0] bitnum=2'b0;
    
    always @(negedge clk_500)begin
        case(fir)
            4'd0:firreg<=zero;
            4'd1:firreg<=one;
            4'd2:firreg<=two;
            4'd3:firreg<=three;
            4'd4:firreg<=four;
            4'd5:firreg<=five;
            4'd6:firreg<=six;
            4'd7:firreg<=seven;
            4'd8:firreg<=eight;
            4'd9:firreg<=nine;
          default:firreg<=errcod;
        endcase
        case(sec)
            4'd0:secreg<=zero;
            4'd1:secreg<=one;
            4'd2:secreg<=two;
            4'd3:secreg<=three;
            4'd4:secreg<=four;
            4'd5:secreg<=five;
            4'd6:secreg<=six;
            4'd7:secreg<=seven;
            4'd8:secreg<=eight;
            4'd9:secreg<=nine;
          default:secreg<=errcod;
        endcase
        case(thi)
            4'd0:thireg<=zero;
            4'd1:thireg<=one;
            4'd2:thireg<=two;
            4'd3:thireg<=three;
            4'd4:thireg<=four;
            4'd5:thireg<=five;
            4'd6:thireg<=six;
            4'd7:thireg<=seven;
            4'd8:thireg<=eight;
            4'd9:thireg<=nine;
          default:thireg<=errcod;
        endcase    
        case(fou)
            4'd0:foureg<=zero;
            4'd1:foureg<=one;
            4'd2:foureg<=two;
            4'd3:foureg<=three;
            4'd4:foureg<=four;
            4'd5:foureg<=five;
            4'd6:foureg<=six;
            4'd7:foureg<=seven;
            4'd8:foureg<=eight;
            4'd9:foureg<=nine;
           default:foureg<=errcod;
        endcase        
    end
        
    always @(negedge clk_500)begin
        if(bitnum<2'b11)begin
            bitnum<=bitnum+1'b1;
        end
        else begin
            bitnum<=2'd0;
        end    
    end
       
    always @(bitnum)begin
        case(bitnum)
            2'b0:numreg<=firreg;
            2'd1:numreg<=secreg;
            2'd2:numreg<=thireg;
            2'd3:numreg<=foureg;
            default:numreg<=errcod;
           endcase
        case(bitnum)
             2'b0:bitreg<=4'b1110;
             2'd1:bitreg<=4'b1101;
             2'd2:bitreg<=4'b1011;
             2'd3:bitreg<=4'b0111;
            default:bitreg<=4'b1111;
        endcase
    end
    
    always @(posedge clk_500)begin
        bitchose<=~bitreg;
        num<=~numreg;
    end
        
endmodule
