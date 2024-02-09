`timescale 1ns / 1ps
module extender (
    
    // inputs
    Instr, ImmSrc,

    //outputs
    ImmExt
);

input [31:7] Instr;
input [2:0]  ImmSrc;
output reg [31:0] ImmExt;

always @ (*)
    case(ImmSrc) 
               // I-type (IMMEDIATES)
      3'b000:   ImmExt = {{20{Instr[31]}}, Instr[31:20]};  
               // S-type (stores)
      3'b001:   ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]}; 
               // B-type (branches)
      3'b010:   ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}; 
               // J-type (jal)
      3'b011:   ImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
               // U-type (lui/auipc)
      3'b100:   ImmExt = {{Instr[31:12]}, {12{1'b0}}};
      default: ImmExt = 32'bx; // undefined
    endcase             
endmodule