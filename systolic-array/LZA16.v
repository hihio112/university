`timescale 1ns/1ns
module LZA16(
    input [15:0] in,
    output valid,
    output [3:0] position
);
    wire u_valid;
    wire l_valid;
    wire[2:0] u_position;
    wire[2:0] l_position;

    LZA8 u1(in[15:8], u_valid, u_position);
    LZA8 u2(in[7:0], l_valid, l_position);
    
    assign valid = u_valid | l_valid;
    assign position[3] = ~u_valid;
    assign position[2:0] = u_valid ? u_position : l_position;

endmodule