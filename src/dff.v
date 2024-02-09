`timescale 1ns / 1ps
/*verilator public_flat_rd_on*/

module DFF (
    CLK, RST, D, Q
);

input CLK;
input RST;
input [31:0] D;
output reg [31:0] Q;

/*verilator public_off*/

always @ (posedge CLK or posedge RST)
    if (RST)
        Q <= 32'b0;
    else
        Q <= D;
        
endmodule
