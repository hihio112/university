`timescale 1ns/1ns
module LZA4(
    input [3:0] in,
    output valid,
    output [1:0] position
);
    wire u_valid;
    wire l_valid;
    wire u_position;
    wire l_position;
    
    LZA2 u1(in[3:2], u_valid, u_position);
    LZA2 u2(in[1:0], l_valid, l_position);

    assign valid = u_valid | l_valid;
    assign position[1] = ~u_valid;
    assign position[0] = u_valid ? u_position : l_position;

endmodule