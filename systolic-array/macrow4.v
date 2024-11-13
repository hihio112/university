`timescale 1ns/1ns
module macrow4(
    input clk,
    input reset_n,
    input enX,
    input[3:0] enW,
    input [15:0] X_i, 
    input [15:0] W_i,
    output valid_o,
    output [15:0] Y_o
);

reg [6:0] r_enX;
wire [15:0] w_out1, w_out2, w_out3;
reg [15:0] r_X_i;

//registering of enX -> finish & enable timing control
    always@(posedge clk, negedge reset_n) begin
        if(!reset_n)
            r_enX <= 0;
        else
            r_enX <= {r_enX[5:0], enX};
    end

    //input registering
    always@(posedge clk, negedge reset_n) begin
        if(!reset_n)
            r_X_i <= 0;
        else
            r_X_i <= X_i;
    end

    FP_MAC mac_u1(
        .clk(clk),
        .reset_n(reset_n),
        .val_MAC(r_enX[0]),
        .enA(r_enX[0]),          //high -> store input, low ->store existing value
        .enB(enW[0]),          //high -> store input, low ->store existing value
        .opA(r_X_i),   
        .opB(W_i),
        .enADD(r_enX[1]),
        .opADD(16'b0),
        .out_o(w_out1)
    );

    FP_MAC mac_u2(
        .clk(clk),
        .reset_n(reset_n),
        .val_MAC(r_enX[1]),
        .enA(r_enX[1]),          //high -> store input, low ->store existing value
        .enB(enW[1]),          //high -> store input, low ->store existing value
        .opA(r_X_i),   
        .opB(W_i),
        .enADD(r_enX[2]),
        .opADD(w_out1),
        .out_o(w_out2)
    );

    FP_MAC mac_u3(
        .clk(clk),
        .reset_n(reset_n),
        .val_MAC(r_enX[2]),
        .enA(r_enX[2]),          //high -> store input, low ->store existing value
        .enB(enW[2]),          //high -> store input, low ->store existing value
        .opA(r_X_i),   
        .opB(W_i),
        .enADD(r_enX[3]),
        .opADD(w_out2),
        .out_o(w_out3)
    );

    FP_MAC mac_u4(
        .clk(clk),
        .reset_n(reset_n),
        .val_MAC(r_enX[3]),
        .enA(r_enX[3]),          //high -> store input, low ->store existing value
        .enB(enW[3]),          //high -> store input, low ->store existing value
        .opA(r_X_i),   
        .opB(W_i),
        .enADD(r_enX[4]),
        .opADD(w_out3),
        .out_o(Y_o)
    );

assign valid_o = enX ? r_enX[5] : r_enX[2];
endmodule