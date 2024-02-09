`timescale 1ns / 1ps
module mux_2_1 (
    sel, in1, in2, dout

);

    input sel;
    input [31:0] in1, in2;
    output [31:0] dout;


    assign dout = sel ? in2 : in1;


endmodule

module mux_3_1 (
    sel, in1, in2, in3, dout

);

    input [1:0] sel;
    input [31:0] in1, in2, in3;
    output reg [31:0] dout;


    always @ (*)
        case (sel)
            2'b00: dout = in1; 
            2'b01: dout = in2;
            2'b10: dout = in3;
            2'b11: dout = 2'b00;
        endcase

endmodule