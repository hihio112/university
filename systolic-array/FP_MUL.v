`timescale 1ns/1ns
module FP_MUL(
    input [15:0] opA_i,
    input [15:0] opB_i,
    output [15:0] MUL_o
);

wire [4:0] a_exp = opA_i[14:10];
wire [9:0] a_mantissa = opA_i[9:0];

wire [4:0] b_exp = opB_i[14:10];
wire [9:0] b_mantissa = opB_i[9:0];

//must subtract bias -15
wire [5:0] r_exp = a_exp + b_exp;        


reg [21:0] r_mantissa;

//amount of denorm absolute value     
wire [4:0] a_denorm_value;                    
wire [9:0] a_denorm_mantissa;

wire [4:0] b_denorm_value;        
wire [9:0] b_denorm_mantissa;


reg [4:0] o_exp;
reg [9:0] o_mantissa;

//sign
wire o_sign = opA_i[15] ^ opB_i[15];

wire a_valid;
wire[3:0] a_position;

wire b_valid;
wire[3:0] b_position;

always@(*) begin
//case of overflow input, output overflow
    if((a_exp == 5'b11111) || (b_exp == 5'b11111)) begin
        o_exp = 5'b11111;
        o_mantissa = 10'd0;
    end
//case of denorm x denorm or denorm x 0, output zero
    else if((a_exp == 5'd0) && (b_exp == 5'd0)) begin
        o_exp = 5'd0;
        o_mantissa = 10'd0;
    end
    else if((a_exp == 5'd0)) begin
        //case of a= 0
        if(a_mantissa == 10'd0) begin
            o_exp = 5'd0;
            o_mantissa = 10'd0;
        end
        else begin
//case of a = denorm, b = norm
//normallize the denormalize number and remember the exponent that you use in normalize         
            r_mantissa = {1'b1, a_denorm_mantissa} * {1'b1, b_mantissa};    
//output -> not (denorm or zero) 
            if((b_exp + r_mantissa[21] == a_denorm_value + 15) && r_mantissa[21]) begin
                o_exp = 1;    
                r_mantissa = r_mantissa >> 1;
            end
// output -> not (denorm or zero)
            else if(b_exp + r_mantissa[21] > a_denorm_value + 15) begin
                o_exp = b_exp + r_mantissa[21] - a_denorm_value - 14;    
                if(r_mantissa[21]) begin        
                    r_mantissa = r_mantissa >> 1;   
                end
                else                                                                         
                    r_mantissa = r_mantissa;
            end
//output -> denorm or zero
            else begin
                o_exp = 5'd0;
                r_mantissa = (r_mantissa >> a_denorm_value - (b_exp) + 15);
            end   
            o_mantissa = r_mantissa[19:10];
        end
    end
    else if((b_exp == 5'd0)) begin
//case of b= 0
        if(b_mantissa == 10'd0) begin
            o_exp = 5'd0;
            o_mantissa = 10'd0;
        end
        else begin
//case of b = denorm, a = norm
//normallize the denormalize number and remember the exponent that you use in normalize          
            r_mantissa = {1'b1, b_denorm_mantissa} * {1'b1, a_mantissa};   
//output -> not (denorm or zero)  
            if((a_exp + r_mantissa[21] == b_denorm_value + 15) && r_mantissa[21]) begin
                o_exp = 1;    
                r_mantissa = r_mantissa >> 1;
            end
//output -> not (denorm or zero) 
            else if(a_exp + r_mantissa[21] > b_denorm_value + 15) begin
                o_exp = a_exp + r_mantissa[21] - b_denorm_value - 14;    
                if(r_mantissa[21]) begin       
                    r_mantissa = r_mantissa >> 1;   
                end
                else                                                                         
                    r_mantissa = r_mantissa;
            end
            else begin
//output -> denorm or zero
                o_exp = 5'd0;
                r_mantissa = (r_mantissa >> b_denorm_value - (a_exp) + 15); 
            end   
            o_mantissa = r_mantissa[19:10];
        end
    end
    else begin
//input normal case
//consider overflow && denormalize output
        r_mantissa = {1'b1, a_mantissa} * {1'b1, b_mantissa};
// denormal case exp = 0
        if(r_exp < 15) begin
            if(r_exp == 14 && r_mantissa[21]) begin
                o_exp = 5'd0;
                r_mantissa = r_mantissa >> 2;
            end
            else begin
                o_exp = 5'd0;
                r_mantissa = r_mantissa >> (16-r_exp);    
                o_mantissa = r_mantissa[19:10];
            end
        end
        else if(r_exp == 15) begin
//normal case of exp=1
            if(r_mantissa[21]) begin  
                o_exp = 5'd1;
                r_mantissa = r_mantissa >> 1;
                o_mantissa = r_mantissa[19:10];
            end
//denormal case of exp=0
            else begin
                o_exp = 5'd0;
                o_mantissa = r_mantissa[19:10];
            end
        end
//overflow case when r_exp + r_mantissa - 15(bias) >= 31
        else if((r_exp + r_mantissa[21] >= 46) ) begin 
            o_exp = 5'b11111;
            o_mantissa = 10'd0;
        end
        else begin
//output normal case
            o_exp = a_exp + b_exp - 15;
            r_mantissa = {1'b1, a_mantissa} * {1'b1, b_mantissa};
            if(r_mantissa[21]) begin
                r_mantissa = r_mantissa >> 1;
                o_exp = o_exp + 1;
            end
            else 
                r_mantissa = r_mantissa;
            o_mantissa = r_mantissa[19:10];    
        end
    end
end
LZA16 u1(.in({a_mantissa,6'd0}), .valid(a_valid), .position(a_position));
LZA16 u2(.in({b_mantissa,6'd0}), .valid(b_valid), .position(b_position));


assign a_denorm_value = a_valid ? a_position + 1 : 0;
assign a_denorm_mantissa = a_valid ? (a_mantissa << (a_position + 1)) : a_mantissa;

assign b_denorm_value = b_valid ? b_position + 1 : 0;
assign b_denorm_mantissa = b_valid ? (b_mantissa << (b_position + 1)) : b_mantissa;


assign MUL_o = {o_sign,o_exp,o_mantissa};
endmodule
