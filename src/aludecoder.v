`timescale 1ns / 1ps
module aludecoder(input  wire [1:0] ALUOp,
                  input  wire [2:0] funct3,
                  input  wire op_5, 
                  input  wire funct7_5,
                  output reg [3:0] ALUControl);

    always @ (*)
    begin
      casez ({ALUOp, funct3, op_5, funct7_5})
        7'b00?????:
          ALUControl = 4'b0000;  // add for PC increment
        7'b0100011:
          ALUControl = 4'b0001;  // subtract for beq/bne
        7'b0111010:
          ALUControl = 4'b1100;  // sltu for bltu/bgeu
        7'b0110010:
          ALUControl = 4'b0101;  // slt for blt/bge
        7'b100000?:
          ALUControl = 4'b0000;  // add 
        7'b1000011:
          ALUControl = 4'b0001;  // subtract
        7'b10010??:
          ALUControl = 4'b0101;  // slt(i)
        7'b10011??:
          ALUControl = 4'b1100;  // slt(i)u
        7'b10110??:
          ALUControl = 4'b0011;  // or(i) 
        7'b10111??:
          ALUControl = 4'b0010;  // and(i)
        7'b10100??:
          ALUControl = 4'b0110;  // xor(i)
        7'b10001??:              
          ALUControl = 4'b0111;  // sll(i)
        7'b10101?0:
          ALUControl = 4'b1000;  // srl(i)
        7'b1010111:
          ALUControl = 4'b1001;  // sra(i)

      endcase
    end
    
endmodule