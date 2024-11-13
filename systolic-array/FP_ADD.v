`timescale 1ns/1ns
module FP_ADD(opA_i, opB_i, ADD_o);
   input [15:0] opA_i;
   input [15:0] opB_i;
   output [15:0] ADD_o;
   
   reg   sign_A, sign_B, sign_out;
   reg   [4:0] exp_A, exp_B, exp_reg, exp_out;
   reg [20:0] man_A, man_B; //[x.xxx..] 21bit
   reg [21:0] man_reg, man_reg_2;   //[xx.xxxx..] 22 bit
   reg [19:0] man_out; //x.[xxxx..] 20 bit
   
   wire V_16, V_4;
   wire [3:0] P_16;
   wire [1:0] P_4;
   wire [4:0] norm_shift_num;
   
   always @(*) begin
      sign_A = opA_i[15];
      sign_B = opB_i[15];
      exp_A = opA_i[14:10];
      exp_B = opB_i[14:10];
      
      
//case : A or B = overflow
      if ((exp_A==5'b11111) || (exp_B==5'b11111)) begin
         
         exp_out = 5'b11111;
         man_out = 0;
         
         if ((exp_A==5'b11111) && (exp_B==5'b11111)) begin
            if (sign_A == sign_B)
               sign_out = sign_A;
            else 
               sign_out = 0;
         end
         
         else if (exp_A ==5'b11111)
            sign_out = sign_A;
         
         else if (exp_B==5'b11111)
            sign_out = sign_B;
         
      end
      
//case : A=0, B=0
      else if ((exp_A==0 && opA_i[9:0]==0) && (exp_B==0 && opB_i[9:0]==0)) begin
         exp_out = 0;
         man_out = 0;
         sign_out = 0;
      end
      
//case : A=0, B=denormalize or normal
      else if ((exp_A==0 && opA_i[9:0]==0)) begin
         exp_out = exp_B;
         man_out = {opB_i[9:0],{10{1'b0}}};
         sign_out = sign_B;
      end
      
//case : A=denomalize or normal, B=0
      else if ((exp_B==0 && opB_i[9:0]==0)) begin
         exp_out = exp_A;
         man_out = {opA_i[9:0],{10{1'b0}}};
         sign_out = sign_A;
      end

         
         
//case : denorm +- denorm
      else if (exp_A == 0 && exp_B == 0) begin
         man_A = {1'b0, opA_i[9:0], {10{1'b0}}};  //0.xxxxx
         man_B = {1'b0, opB_i[9:0], {10{1'b0}}};    //0.xxxxx
         exp_reg = 0;
         
         if (sign_A == sign_B) begin
            man_reg = man_A + man_B;
            sign_out = sign_A;
         end
         
         else begin
            if (man_A > man_B) begin
               man_reg = man_A - man_B;
               sign_out = sign_A;
            end
            
            else if (man_A < man_B) begin
               man_reg = man_B - man_A;
               sign_out = sign_B;
            end
            
            else if (man_A == man_B) begin
               man_reg = 0;
               sign_out = sign_A;
            end
         end

//1 : denorm + denorm = denorm
//2 : denorm - denorm = denorm
         if (man_reg[20] == 1'b0) begin
            exp_out = 0;
            man_out = man_reg[19:0];
         end
         
//3 : denorm + denorm = norm
         else if (man_reg[20] == 1'b1) begin
            exp_out = 1;
            man_out = man_reg[19:0];
         end
      end
         
      
//case : denorm +- norm
      else if (exp_A == 0) begin
         man_A = {1'b0, opA_i[9:0], {10{1'b0}}};  //0.xxxxx
         man_B = {1'b1, opB_i[9:0], {10{1'b0}}};    //1.xxxxx
      
         man_A = man_A >> (exp_B - (exp_A + 1));

//7 : denorm + norm = (always) norm
         if (sign_A == sign_B) begin
            man_reg = man_A + man_B;
				sign_out = sign_A;
				exp_reg = exp_B;
//overflow
            if (man_reg[21] == 1) begin
               man_reg = man_reg >> 1;
               exp_reg = exp_reg + 1;
            end
            
            man_out = man_reg;
            exp_out = exp_reg;
            
         end
         
         else begin
            sign_out = sign_B;
            man_reg = man_B - man_A;
            
//8 : denorm - norm = norm
            if (man_reg[21:20] ==2'b01) begin
               exp_reg = exp_B;
               man_out = man_reg[19:0];
               exp_out = exp_reg;
            end
            
            else if (man_reg[21:20] ==2'b00) begin
               exp_reg = ((exp_B==5'b00001) ? 0 : exp_B);
//6 : denorm - norm = denorm
               if (exp_reg < norm_shift_num) begin
               man_reg_2 = man_reg << (exp_reg);
               man_out = man_reg_2[19:0];
               exp_out = 0;
               end
               
//8 : denorm - norm = norm
               else if (exp_reg > norm_shift_num) begin
                  man_reg_2 = man_reg << (norm_shift_num);
                  man_out = man_reg_2[19:0];
                  exp_out = exp_reg - (norm_shift_num);
               end
               
               else if (exp_reg == norm_shift_num) begin
                  man_reg_2 = man_reg << (norm_shift_num);
                  man_out = man_reg_2[19:0];
                  exp_out = 1;
               end
            end   
         end
      end
      
//case : norm +- denorm
      else if (exp_B == 0) begin
         man_A = {1'b1, opA_i[9:0], {10{1'b0}}};  //1.xxxxx
         man_B = {1'b0, opB_i[9:0], {10{1'b0}}};    //0.xxxxx
      
      
         man_B = man_B >> (exp_A - (exp_B + 1));

//7 : norm + denorm = (always) norm
         if (sign_A == sign_B) begin
            man_reg = man_A + man_B;
            sign_out = sign_A;
            exp_reg = exp_A;
//overflow
            if (man_reg[21] == 1) begin
               man_reg = man_reg >> 1;
               exp_reg = exp_reg + 1;
            end
            
            man_out = man_reg;
            exp_out = exp_reg;
         end
         
         else begin
            sign_out = sign_A;
            man_reg = man_A - man_B;
            
//8 : norm - denorm = norm
            if (man_reg[21:20] ==2'b01) begin
               exp_reg = exp_A;
               man_out = man_reg[19:0];
               exp_out = exp_reg;
            end
            
            else if (man_reg[21:20] ==2'b00) begin
               exp_reg = ((exp_A==5'b00001) ? 0 : exp_A);
//6 : norm - denorm = denorm
               if (exp_reg < norm_shift_num) begin
               man_reg_2 = man_reg << (exp_reg);
               man_out = man_reg_2[19:0];
               exp_out = 0;
               end
               
//8 : norm - denorm = norm
               else if (exp_reg > norm_shift_num) begin
                  man_reg_2 = man_reg << (norm_shift_num);
                  man_out = man_reg_2[19:0];
                  exp_out = exp_reg - (norm_shift_num);
               end
               
               else if (exp_reg == norm_shift_num) begin
                  man_reg_2 = man_reg << (norm_shift_num);
                  man_out = man_reg_2[19:0];
                  exp_out = 1;
               end
            end   
         end
      end
      
//case : norm +- norm
      else begin
         man_A = {1'b1, opA_i[9:0], {10{1'b0}}};  //1.xxxxx
         man_B = {1'b1, opB_i[9:0], {10{1'b0}}};    //1.xxxxx
         
    
         if (exp_A > exp_B) begin
            man_B = man_B >> (exp_A - exp_B);
            exp_reg = exp_A;
         end
         
         else if (exp_A < exp_B) begin
            man_A = man_A >> (exp_B - exp_A);
            exp_reg = exp_B;
         end
         
         else if (exp_A == exp_B) begin
            exp_reg = exp_A;
         end
      
         
         
//11 : norm + norm = norm
//13 : norm + norm = overflow
         if (sign_A == sign_B) begin
            man_reg = man_A + man_B;
            sign_out = sign_A;
            
// overflow
            if (man_reg[21] == 1) begin
               man_reg = man_reg >> 1;
               exp_reg = exp_reg + 1;
            end   
            
            man_out = man_reg[19:0];
            exp_out = exp_reg;
            
            if (exp_reg ==5'b11111) begin
               exp_out = 5'b11111;
               man_out = 0;
            end
         end
         
//norm - norm = norm or denorm
         else begin
            if (man_A > man_B) begin
               man_reg = man_A - man_B;
               sign_out = sign_A;
            end
            
            else if (man_A < man_B) begin
               man_reg = man_B - man_A;
               sign_out = sign_B;
            end
            
            else begin 
               man_reg = 0;
               sign_out = 0;
            end
            
//10 : norm - norm = denorm
//12 : norm - norm = norm

//12 : result is norm
            if (man_reg[20] == 1'b1) begin //01.XXXX
               man_out = man_reg[19:0];
               exp_out = exp_reg;
            end
            
//12 : result is norm (normalization)
            else if ((exp_reg-1) > norm_shift_num) begin
               man_reg_2 = man_reg << (norm_shift_num);
               man_out = man_reg_2[19:0];
               exp_out = exp_reg - (norm_shift_num);
            end
            
//12 : result is norm (normalization)
            else if ((exp_reg-1) == norm_shift_num) begin
               man_reg_2 = man_reg << (norm_shift_num);
               man_out = man_reg_2[19:0];
               exp_out = 1;
            end
            
//10 : result is denorm
            else if ((exp_reg-1) < norm_shift_num) begin
               man_reg_2 = man_reg << (exp_reg - 1);
               man_out = man_reg_2[19:0];
               exp_out = 0;
            end
         
         end
      end
         

   end
      

//denormalize : Leading Zero Counter
   LZA16 u16 (man_reg[19:4], V_16, P_16);
   LZA4 u4 (man_reg[3:0], V_4, P_4);
   
   assign norm_shift_num = (V_16 ? P_16 : (V_4 ? (P_4 + 4'b1111) : 0)) + 1'b1;
   
   
   assign ADD_o = {sign_out, exp_out, man_out[19:10]};

endmodule