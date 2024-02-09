`timescale 1ns / 1ps
module regfile (

    // inputs
    CLK, WE3, A1, A2, A3, WD3, LST, LSE, 
    
    // outputs
    RD1, RD2
);

    /*verilator public_flat_rd_on*/
    input  CLK;
    input  WE3;
    input  LSE;
    input  [4:0] A1;
    input  [4:0] A2;
    input  [4:0] A3;
    input  [31:0] WD3;
    input  [2:0] LST;
    output reg [31:0] RD1;
    output reg [31:0] RD2;

    // 32x 32-bit registers
    reg [31:0] registers [31:0];
    /*verilator public_off*/

    assign registers[0] = 32'b0;

    // RD1 for going to ALU A
    always @ (*)
    begin
        if (A1 != 0)
            RD1 = registers[A1];
        else 
            RD1 = 32'b0;
    end

    // stores
    always @ (*)
    begin
        if (A2 != 0)
            if (LSE)
                case(LST)
                    3'b000: RD2 = registers[A2][7:0];
                    3'b001: RD2 = registers[A2][15:0];
                    3'b010: RD2 = registers[A2][31:0];
                    default: RD2 = registers[A2][31:0];
                endcase
            else
                RD2 = registers[A2];
        else
            RD2 = 32'b0;
    end

    // loads
    always @ (posedge CLK) 
    begin
        if (WE3)
            if (LSE) 
                case(LST)
                    3'b000: registers[A3] <= {{24{WD3[7]}}, WD3[7:0]};   // lb sign extend
                    3'b001: registers[A3] <= {{16{WD3[15]}}, WD3[15:0]}; // lh sign extend
                    3'b010: registers[A3] <= WD3[31:0];
                    3'b100: registers[A3] <= {{24{1'b0}}, WD3[7:0]}; // lbu zero extend
                    3'b101: registers[A3] <= {{16{1'b0}}, WD3[15:0]}; // lhu zero extend
                    default: registers[A3] <= WD3[31:0];
                endcase
            else
                registers[A3] <= WD3[31:0];

    end 

endmodule
