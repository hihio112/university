`timescale 1ns/1ns
module FP_MAC(
    input clk,
    input reset_n,
    input val_MAC,
    input enA,          //high -> store input, low ->store existing value
    input enB,          //high -> store input, low ->store existing value
    input [15:0] opA,   
    input [15:0] opB,
    input enADD,
    input [15:0] opADD,
    output [15:0] out_o
);

    reg[15:0] r_a, r_b;
    reg[15:0] r_add;
    reg[15:0] r_mul;
    wire[15:0] w_mul;
    reg [1:0] r_valid;

//registering opA, opB, opADD
    always@(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            r_a <= 16'b0;
        end
        else if(enA)
            r_a <= opA;
        else
            r_a <= r_a;
    end

    always@(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            r_b <= 16'b0;
        end
        else if(enB)
            r_b <= opB;
        else
            r_b <= r_b;
    end

    always@(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            r_add <= 16'b0;
        end
        else if(enADD)
            r_add <= opADD;
        else
            r_add <= 16'b0;         //add zero
    end

    always@(posedge clk, negedge reset_n) begin
        if(!reset_n) begin
            r_mul <= 16'b0;
        end
        else
            r_mul <= w_mul;
    end

    always@(posedge clk, negedge reset_n) begin
        if(!reset_n)
            r_valid <= 2'b0;
        else begin
            r_valid <= {r_valid[0],val_MAC};
        end

    end

    FP_MUL u1(
        .opA_i(r_a),
        .opB_i(r_b),
        .MUL_o(w_mul)
    );

    FP_ADD u2(
        .opA_i(r_mul),
        .opB_i(r_add),
        .ADD_o(out_o)
    );


endmodule