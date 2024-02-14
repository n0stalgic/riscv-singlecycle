`timescale 1ns / 1ps
module instr_decode (
    input [6:0] op,
    input Zero,
    input Negative,
    input [2:0] funct3,
    output reg [1:0] ResultSrc,
    output reg MemWrite,
    output reg ALUSrc,
    output reg [2:0] ImmSrc,
    output reg ImmSel,
    output reg RegWrite,
    output reg [1:0] ALUOp,
    output reg [1:0] PCSrc

);

wire PC_BEQ_BNE;
wire PC_BLT_BGE;
reg Jump;
reg JumpLink;
reg Branch;

assign PC_BEQ_BNE = ((Zero ^ funct3[0] & ~funct3[1] & ~funct3[2]) & Branch);
assign PC_BLT_BGE = ((Negative ^ funct3[0] & funct3[2]) & Branch);

always @ (*)
begin
    if (JumpLink)
        PCSrc = 2'b10;
    else if ((((PC_BEQ_BNE && funct3 <= 1) && Branch) || 
                (PC_BLT_BGE && funct3 >= 4 && funct3 < 6) && Branch) ||
                    Jump)
        PCSrc = 2'b01;
    else 
        PCSrc = 2'b00;
end

always @ (*) begin
    ResultSrc = 2'b00;
    MemWrite = 1'b0;
    ALUSrc = 1'b0;
    ImmSrc = 3'b00;
    RegWrite = 1'b0;
    ALUOp = 2'b00;
    Branch = 1'b0;
    Jump   = 1'b0;
    ImmSel = 1'b0;
    JumpLink = 1'b0;

    casez (op)
        7'b0110011: begin         // R-type
            RegWrite = 1'b1;
            ImmSrc   = 3'bxxx;
            ALUSrc   = 1'b0;
            ALUOp    = 2'b10;
        end
        7'b0000011: begin         // mem load
            RegWrite  = 1'b1;
            ResultSrc = 2'b01;
            ImmSrc    = 3'b000;
            ALUOp     = 2'b00;
            ALUSrc    = 1'b1;
        end
 
        7'b0100011: begin        // mem store
            RegWrite = 1'b0;
            ImmSrc   = 3'b001;
            ALUOp    = 2'b00;
            ALUSrc   = 1'b1;
            MemWrite = 1'b1;
            ResultSrc = 2'b01;
        end

        7'b0010011: begin         // I-Type
            RegWrite = 1'b1;
            ImmSrc   = 3'b000;
            ALUSrc   = 1'b1;
            ALUOp    = 2'b10;
        end

        7'b1100011: begin         // beq/bne/blt(u)/bge(u)
            Branch = 1'b1;
            ImmSrc = 3'b010;
            ALUOp  = 2'b01;

        end
        7'b1101111: begin         // jal
            Branch = 1'b0;
            ImmSrc = 3'b011;
            Jump   = 1'b1;
            RegWrite = 1'b1;
            ResultSrc = 2'b10;
        end
        7'b1100111: begin         // jalr
            Branch = 1'b0;
            ImmSrc = 3'b000;
            ALUSrc = 1'b1;
            ALUOp  = 2'b00;
            JumpLink   = 1'b1;
            ResultSrc  = 2'b00;
        end
        7'b0110111: begin         // lui
            ImmSrc   = 3'b100;
            ImmSel   = 1'b1;
            RegWrite = 1'b1;
            ResultSrc = 2'b11;

        end
        7'b0010111: begin        // auipc
            ImmSrc = 3'b100;
            RegWrite = 1'b1;
            ImmSel   = 1'b0;
            ResultSrc = 2'b11;
        end

endcase
end

    
endmodule