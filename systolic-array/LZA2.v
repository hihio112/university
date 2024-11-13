`timescale 1ns/1ns
module LZA2(
    input [1:0] in,
    output valid, 
    output position
);
    assign valid = in[1]|in[0];
    assign position = ~in[1];


endmodule
