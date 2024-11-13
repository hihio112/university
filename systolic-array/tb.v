`timescale 1ns/1ns
module tb();
   reg clk;
   reg reset_n;
   reg enX;
   reg[3:0] enW;
   reg[15:0] X_i;
   reg[15:0] W_i;
   wire valid_o;
   wire[15:0] Y_o;

   macrow4 macrow4_u1(
      .clk(clk),
      .reset_n(reset_n),
      .enX(enX),
      .enW(enW),
      .X_i(X_i),
      .W_i(W_i),
      .valid_o(valid_o),
      .Y_o(Y_o)
   );

   initial begin
      clk = 0;
      reset_n =0;
      enX = 0;
      X_i = 0;
      #8; 
      reset_n = 1;
      
      #8;
      enW = 4'b1000;
      W_i = 16'h34cc;   //0.3
      
      #8;
      enW = 4'b0100;
      W_i = 16'hb800;   //-0.5
      
      #8;
      enW = 4'b0010;
      W_i = 16'h3ecc;   //1.7
      
      #8;
      enW = 4'b0001;
      W_i = 16'h4366;   //3.7
      
      #8;
      enW = 4'b0000;
      X_i = 16'hD468;   //-70.5
      enX = 1;
      
      #8;
      X_i = 16'h200;    //0.00003052
      #8;
      X_i = 16'h008F;   //0.00000853
      #8;
      X_i = 16'h4248;   //3.141
      #8;
      X_i = 16'h4047;   //2.14
      #8;
      X_i = 16'h2A66;   //0.05
      #8;
      X_i = 16'h3C00;   //1
      #8;
      X_i = 16'h779F;   //31216
      #8;
      X_i = 16'h7B9F;    //62432
      #8;
      X_i = 16'h7BFF;   //65504
      #8;
      X_i = 16'h4248;   //3.141
      #8;
      enX = 0;

      
   end


   initial begin
      $dumpfile("mactest.dmp");
      $dumpvars;
      #190;
      $finish();
   end

   always #4 clk = ~clk;
   
endmodule