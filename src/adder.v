`timescale 1ns / 1ps
module adder #(
    WIDTH = 32
) (
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output [WIDTH-1:0] Q
);

assign Q = A + B;
    
endmodule