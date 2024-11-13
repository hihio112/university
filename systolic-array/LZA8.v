`timescale 1ns/1ns
module LZA8(
    input [7:0] in,
    output valid,
    output [2:0] position
);
    wire u_valid;
    wire l_valid;
    wire[1:0] u_position;
    wire[1:0] l_position;

    LZA4 u1(in[7:4], u_valid, u_position);
    LZA4 u2(in[3:0], l_valid, l_position);
    
    assign valid = u_valid | l_valid;
    assign position[2] = ~u_valid;
    assign position[1:0] = u_valid ? u_position : l_position;

endmodule