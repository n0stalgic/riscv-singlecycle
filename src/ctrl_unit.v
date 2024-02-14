`timescale 1ns / 1ps
/*verilator public_flat_rd_on*/
module ctrl_unit (
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire funct7_5,
    input wire Zero,
    input wire Negative,
    output reg [1:0] ResultSrc,
    output reg MemWrite,
    output reg ALUSrc,
    output reg ImmSel,
    output reg [2:0] ImmSrc,
    output reg RegWrite,
    output reg [1:0] PCSrc,
    output reg LSE,
    output reg [2:0] LST,
    output reg [3:0] ALUControl

);

wire [1:0] ALUOp;
wire op_5;

/*verilator public_off*/
assign op_5 = op[5];

instr_decode idecoder(
    .op(op),
    .funct3(funct3),
    .Zero(Zero),
    .Negative(Negative),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .ImmSel(ImmSel),
    .RegWrite(RegWrite),
    .ALUOp(ALUOp),
    .PCSrc(PCSrc)

);

aludecoder aludec(
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .op_5(op_5),
    .ALUControl(ALUControl)
);
    
endmodule