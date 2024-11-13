`timescale 1ns / 1ps
module dct_1d_full
#(
    parameter integer N=8
)
(
input clk,
input rst_n,
//zero row
input signed[N-1:0] x00, 
input signed[N-1:0] x01, 
input signed[N-1:0] x02,
input signed[N-1:0] x03,
input signed[N-1:0] x04,
input signed[N-1:0] x05,
input signed[N-1:0] x06,
input signed[N-1:0] x07,
//first row
input signed[N-1:0] x10, 
input signed[N-1:0] x11, 
input signed[N-1:0] x12,
input signed[N-1:0] x13,
input signed[N-1:0] x14,
input signed[N-1:0] x15,
input signed[N-1:0] x16,
input signed[N-1:0] x17,
//second row
input signed[N-1:0] x20, 
input signed[N-1:0] x21, 
input signed[N-1:0] x22,
input signed[N-1:0] x23,
input signed[N-1:0] x24,
input signed[N-1:0] x25,
input signed[N-1:0] x26,
input signed[N-1:0] x27,
//thrid row
input signed[N-1:0] x30, 
input signed[N-1:0] x31, 
input signed[N-1:0] x32,
input signed[N-1:0] x33,
input signed[N-1:0] x34,
input signed[N-1:0] x35,
input signed[N-1:0] x36,
input signed[N-1:0] x37,
//fourth row
input signed[N-1:0] x40, 
input signed[N-1:0] x41, 
input signed[N-1:0] x42,
input signed[N-1:0] x43,
input signed[N-1:0] x44,
input signed[N-1:0] x45,
input signed[N-1:0] x46,
input signed[N-1:0] x47,
//fifth row
input signed[N-1:0] x50, 
input signed[N-1:0] x51, 
input signed[N-1:0] x52,
input signed[N-1:0] x53,
input signed[N-1:0] x54,
input signed[N-1:0] x55,
input signed[N-1:0] x56,
input signed[N-1:0] x57,
//sixth row
input signed[N-1:0] x60, 
input signed[N-1:0] x61, 
input signed[N-1:0] x62,
input signed[N-1:0] x63,
input signed[N-1:0] x64,
input signed[N-1:0] x65,
input signed[N-1:0] x66,
input signed[N-1:0] x67,
//seventh row
input signed[N-1:0] x70, 
input signed[N-1:0] x71, 
input signed[N-1:0] x72,
input signed[N-1:0] x73,
input signed[N-1:0] x74,
input signed[N-1:0] x75,
input signed[N-1:0] x76,
input signed[N-1:0] x77,

//zero row
output signed[N+11:0] Y00,//1-sign, n+1int, 16-fixed point
output signed[N+11:0] Y01,
output signed[N+11:0] Y02,
output signed[N+11:0] Y03,
output signed[N+11:0] Y04,
output signed[N+11:0] Y05,
output signed[N+11:0] Y06,
output signed[N+11:0] Y07,
//first row
output signed[N+11:0] Y10,
output signed[N+11:0] Y11,
output signed[N+11:0] Y12,
output signed[N+11:0] Y13,
output signed[N+11:0] Y14,
output signed[N+11:0] Y15,
output signed[N+11:0] Y16,
output signed[N+11:0] Y17,
//second row
output signed[N+11:0] Y20,
output signed[N+11:0] Y21,
output signed[N+11:0] Y22,
output signed[N+11:0] Y23,
output signed[N+11:0] Y24,
output signed[N+11:0] Y25,
output signed[N+11:0] Y26,
output signed[N+11:0] Y27,
//thrid row
output signed[N+11:0] Y30,
output signed[N+11:0] Y31,
output signed[N+11:0] Y32,
output signed[N+11:0] Y33,
output signed[N+11:0] Y34,
output signed[N+11:0] Y35,
output signed[N+11:0] Y36,
output signed[N+11:0] Y37,
//fourth row
output signed[N+11:0] Y40,
output signed[N+11:0] Y41,
output signed[N+11:0] Y42,
output signed[N+11:0] Y43,
output signed[N+11:0] Y44,
output signed[N+11:0] Y45,
output signed[N+11:0] Y46,
output signed[N+11:0] Y47,
//fifth row
output signed[N+11:0] Y50,
output signed[N+11:0] Y51,
output signed[N+11:0] Y52,
output signed[N+11:0] Y53,
output signed[N+11:0] Y54,
output signed[N+11:0] Y55,
output signed[N+11:0] Y56,
output signed[N+11:0] Y57,
//sixth row
output signed[N+11:0] Y60,
output signed[N+11:0] Y61,
output signed[N+11:0] Y62,
output signed[N+11:0] Y63,
output signed[N+11:0] Y64,
output signed[N+11:0] Y65,
output signed[N+11:0] Y66,
output signed[N+11:0] Y67,
//seventh row
output signed[N+11:0] Y70,
output signed[N+11:0] Y71,
output signed[N+11:0] Y72,
output signed[N+11:0] Y73,
output signed[N+11:0] Y74,
output signed[N+11:0] Y75,
output signed[N+11:0] Y76,
output signed[N+11:0] Y77,

output r_valid
    );
 
 //zero row
wire signed[N+5:0] y00; //1-sign, n+1int, 16-fixed point
wire signed[N+5:0] y01;
wire signed[N+5:0] y02;
wire signed[N+5:0] y03;
wire signed[N+5:0] y04;
wire signed[N+5:0] y05;
wire signed[N+5:0] y06;
wire signed[N+5:0] y07;
//first row
wire signed[N+5:0] y10;
wire signed[N+5:0] y11;
wire signed[N+5:0] y12;
wire signed[N+5:0] y13;
wire signed[N+5:0] y14;
wire signed[N+5:0] y15;
wire signed[N+5:0] y16;
wire signed[N+5:0] y17;
//second row
wire signed[N+5:0] y20;
wire signed[N+5:0] y21;
wire signed[N+5:0] y22;
wire signed[N+5:0] y23;
wire signed[N+5:0] y24;
wire signed[N+5:0] y25;
wire signed[N+5:0] y26;
wire signed[N+5:0] y27;
//thrid row
wire signed[N+5:0] y30;
wire signed[N+5:0] y31;
wire signed[N+5:0] y32;
wire signed[N+5:0] y33;
wire signed[N+5:0] y34;
wire signed[N+5:0] y35;
wire signed[N+5:0] y36;
wire signed[N+5:0] y37;
//fourth row
wire signed[N+5:0] y40;
wire signed[N+5:0] y41;
wire signed[N+5:0] y42;
wire signed[N+5:0] y43;
wire signed[N+5:0] y44;
wire signed[N+5:0] y45;
wire signed[N+5:0] y46;
wire signed[N+5:0] y47;
//fifth row
wire signed[N+5:0] y50;
wire signed[N+5:0] y51;
wire signed[N+5:0] y52;
wire signed[N+5:0] y53;
wire signed[N+5:0] y54;
wire signed[N+5:0] y55;
wire signed[N+5:0] y56;
wire signed[N+5:0] y57;
//sixth row
wire signed[N+5:0] y60;
wire signed[N+5:0] y61;
wire signed[N+5:0] y62;
wire signed[N+5:0] y63;
wire signed[N+5:0] y64;
wire signed[N+5:0] y65;
wire signed[N+5:0] y66;
wire signed[N+5:0] y67;
//seventh row
wire signed[N+5:0] y70;
wire signed[N+5:0] y71;
wire signed[N+5:0] y72;
wire signed[N+5:0] y73;
wire signed[N+5:0] y74;
wire signed[N+5:0] y75;
wire signed[N+5:0] y76;
wire signed[N+5:0] y77;
    
 dct_1D 
 #(.N(N)) row0_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(x00),.x1(x01),.x2(x02),.x3(x03),.x4(x04),.x5(x05),.x6(x06),.x7(x07),.X0(y00),.X1(y01),.X2(y02),.X3(y03),.X4(y04),.X5(y05),.X6(y06),.X7(y07));
 
 dct_1D 
 #(.N(N)) row1_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(x10),.x1(x11),.x2(x12),.x3(x13),.x4(x14),.x5(x15),.x6(x16),.x7(x17),.X0(y10),.X1(y11),.X2(y12),.X3(y13),.X4(y14),.X5(y15),.X6(y16),.X7(y17));
 
 dct_1D 
 #(.N(N)) row2_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(x20),.x1(x21),.x2(x22),.x3(x23),.x4(x24),.x5(x25),.x6(x26),.x7(x27),.X0(y20),.X1(y21),.X2(y22),.X3(y23),.X4(y24),.X5(y25),.X6(y26),.X7(y27));
 
 dct_1D 
 #(.N(N)) row3_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(x30),.x1(x31),.x2(x32),.x3(x33),.x4(x34),.x5(x35),.x6(x36),.x7(x37),.X0(y30),.X1(y31),.X2(y32),.X3(y33),.X4(y34),.X5(y35),.X6(y36),.X7(y37));
 
 dct_1D 
 #(.N(N)) row4_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(x40),.x1(x41),.x2(x42),.x3(x43),.x4(x44),.x5(x45),.x6(x46),.x7(x47),.X0(y40),.X1(y41),.X2(y42),.X3(y43),.X4(y44),.X5(y45),.X6(y46),.X7(y47));
 
 dct_1D 
 #(.N(N)) row5_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(x50),.x1(x51),.x2(x52),.x3(x53),.x4(x54),.x5(x55),.x6(x56),.x7(x57),.X0(y50),.X1(y51),.X2(y52),.X3(y53),.X4(y54),.X5(y55),.X6(y56),.X7(y57));
 
dct_1D 
 #(.N(N)) row6_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(x60),.x1(x61),.x2(x62),.x3(x63),.x4(x64),.x5(x65),.x6(x66),.x7(x67),.X0(y60),.X1(y61),.X2(y62),.X3(y63),.X4(y64),.X5(y65),.X6(y66),.X7(y67));
 
 dct_1D 
 #(.N(N)) row7_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(x70),.x1(x71),.x2(x72),.x3(x73),.x4(x74),.x5(x75),.x6(x76),.x7(x77),.X0(y70),.X1(y71),.X2(y72),.X3(y73),.X4(y74),.X5(y75),.X6(y76),.X7(y77));
 
 //column
 dct_1D 
 #(.N(N+6)) colum0_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(y00),.x1(y10),.x2(y20),.x3(y30),.x4(y40),.x5(y50),.x6(y60),.x7(y70),.X0(Y00),.X1(Y01),.X2(Y02),.X3(Y03),.X4(Y04),.X5(Y05),.X6(Y06),.X7(Y07));
 
  dct_1D 
 #(.N(N+6)) colum1_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(y01),.x1(y11),.x2(y21),.x3(y31),.x4(y41),.x5(y51),.x6(y61),.x7(y71),.X0(Y10),.X1(Y11),.X2(Y12),.X3(Y13),.X4(Y14),.X5(Y15),.X6(Y16),.X7(Y17));
 
  dct_1D 
 #(.N(N+6)) colum2_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(y02),.x1(y12),.x2(y22),.x3(y32),.x4(y42),.x5(y52),.x6(y62),.x7(y72),.X0(Y20),.X1(Y21),.X2(Y22),.X3(Y23),.X4(Y24),.X5(Y25),.X6(Y26),.X7(Y27));
 
  dct_1D 
 #(.N(N+6)) colum3_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(y03),.x1(y13),.x2(y23),.x3(y33),.x4(y43),.x5(y53),.x6(y63),.x7(y73),.X0(Y30),.X1(Y31),.X2(Y32),.X3(Y33),.X4(Y34),.X5(Y35),.X6(Y36),.X7(Y37));
 
  dct_1D 
 #(.N(N+6)) colum4_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(y04),.x1(y14),.x2(y24),.x3(y34),.x4(y44),.x5(y54),.x6(y64),.x7(y74),.X0(Y40),.X1(Y41),.X2(Y42),.X3(Y43),.X4(Y44),.X5(Y45),.X6(Y46),.X7(Y47));
 
  dct_1D 
 #(.N(N+6)) colum5_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(y05),.x1(y15),.x2(y25),.x3(y35),.x4(y45),.x5(y55),.x6(y65),.x7(y75),.X0(Y50),.X1(Y51),.X2(Y52),.X3(Y53),.X4(Y54),.X5(Y55),.X6(Y56),.X7(Y57));
 
  dct_1D 
 #(.N(N+6)) colum6_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(y06),.x1(y16),.x2(y26),.x3(y36),.x4(y46),.x5(y56),.x6(y66),.x7(y76),.X0(Y60),.X1(Y61),.X2(Y62),.X3(Y63),.X4(Y64),.X5(Y65),.X6(Y66),.X7(Y67));
 
  dct_1D 
 #(.N(N+6)) colum7_dct_1D
 (.clk(clk),.rst_n(rst_n),.x0(y07),.x1(y17),.x2(y27),.x3(y37),.x4(y47),.x5(y57),.x6(y67),.x7(y77),.X0(Y70),.X1(Y71),.X2(Y72),.X3(Y73),.X4(Y74),.X5(Y75),.X6(Y76),.X7(Y77));

endmodule