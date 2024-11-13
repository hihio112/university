`timescale 1ns / 1ps
module dct_1D
#(
    parameter integer N=8
)
(
input clk,
input rst_n,
input signed[N-1:0] x0, 
input signed[N-1:0] x1, 
input signed[N-1:0] x2,
input signed[N-1:0] x3,
input signed[N-1:0] x4,
input signed[N-1:0] x5,
input signed[N-1:0] x6,
input signed[N-1:0] x7,
output reg signed[N+5:0] X0,//1-sign, n+1int, 16-fixed point
output reg signed[N+5:0] X1,
output reg signed[N+5:0] X2,
output reg signed[N+5:0] X3,
output reg signed[N+5:0] X4,
output reg signed[N+5:0] X5,
output reg signed[N+5:0] X6,
output reg signed[N+5:0] X7
);
parameter signed cos_1_rev = $signed({1'd0,8'd92});  //1/(2**(3/2)*cos(pi/16)
parameter signed cos_2_rev = $signed({1'd0,8'd98});  
parameter signed cos_3_rev = $signed({1'd0,8'd109});  
parameter signed cos_4_rev = $signed({1'd0,8'd128});  
parameter signed cos_5_rev = $signed({1'd0,8'd163});  
parameter signed cos_6_rev = $signed({1'd0,8'd237});  
parameter signed cos_7_rev = $signed({1'd0,9'd464});  

parameter signed rt_2_rev =  $signed({1'd0,8'd181});

parameter signed cos_1 = $signed({1'd0,8'd236});
parameter signed cos_3 = $signed({1'd0,8'd98});    

reg signed[N:0] a0,a1,a2,a3,a4,a5,a6,a7;  //sign 1 int N
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin    
        a0 <= 0;
        a1 <= 0;
        a2 <= 0;
        a3 <= 0;
        a4 <= 0;
        a5 <= 0;
        a6 <= 0;
        a7 <= 0;
    end
    else begin
        a0 <= x0 + x7;
        a1 <= x1 + x6;
        a2 <= x2 + x5;
        a3 <= x3 + x4;
        a4 <= x3 - x4;
        a5 <= x2 - x5;
        a6 <= x1 - x6;
        a7 <= x0 - x7;
    end
end

reg signed[N+1:0] b0,b1,b2,b3,b4,b5,b6,b7; //sign 1 int N+1
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        b0 <= 0;
        b3 <= 0;
        b1 <= 0;
        b2 <= 0;
        b4 <= 0;
        b5 <= 0;
        b6 <= 0;
        b7 <= 0;
    end
    else begin
        b0 <= a0 + a3;
        b3 <= a0 - a3;
        b1 <= a1 + a2;
        b2 <= a1 - a2;
        b4 <= a4 + a5;
        b5 <= a5 + a6;
        b6 <= a6 + a7;
        b7 <= a7;
    end
end

reg signed[N+11:0] c0,c1,c2,c3,c4,c5,c6,c7; //sign 1, int N+3, fixed point 8
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        c0 <= 0;
        c1 <= 0;
        c2 <= 0;
        c3 <= 0;
        c4 <= 0;
        c6 <= 0;
        c5 <= 0;
        c7 <= 0;
    end
    else begin
        c0 <= b0*256;
        c1 <= b1*256;
        c2 <= (b2 + b3)*rt_2_rev;
        c3 <= b3*256;
        c4 <= (b4-b6)*cos_3 + b4*(cos_1-cos_3);
        c6 <= (b4-b6)*cos_3 + b6*(cos_1+cos_3);
        c5 <= b7*256 + b5*rt_2_rev;
        c7 <= b7*256 - b5*rt_2_rev;
    end
end

reg signed[N+12:0] d0,d1,d2,d3,d4,d5,d6,d7; //sign 1, int N+4, fixed point 8
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        d0 <= 0;
        d4 <= 0;
        d2 <= 0;
        d6 <= 0;
        d5 <= 0;
        d3 <= 0;
        d1 <= 0;
        d7 <= 0;
    end
    else begin
        d0 <= c0 + c1;
        d4 <= c0 - c1;
        d2 <= c3 + c2;
        d6 <= c3 - c2;
        d5 <= c7 + c4;
        d3 <= c7 - c4;
        d1 <= c5 + c6;
        d7 <= c5 - c6;
    end
end

//total bit N + 6, sign 1, int N + 5, fixed point 0
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        X0 <= 0;
        X1 <= 0;
        X2 <= 0;
        X3 <= 0;
        X4 <= 0;
        X5 <= 0;
        X6 <= 0;
        X7 <= 0;
    end
    else begin
        X0 <= (d0*rt_2_rev)/65536;
        X1 <= (d1*cos_1_rev)/65536;
        X2 <= (d2*cos_2_rev)/65536;
        X3 <= (d3*cos_3_rev)/65536;
        X4 <= (d4*cos_4_rev)/65536;
        X5 <= (d5*cos_5_rev)/65536;
        X6 <= (d6*cos_6_rev)/65536;
        X7 <= (d7*cos_7_rev)/65536;
    end
end


endmodule