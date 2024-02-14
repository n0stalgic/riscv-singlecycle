`timescale 1ns / 1ps
module ALU (
    
    // inputs
    A, B, ALUControl,
    
    // outputs
    Q, Z, N, V
);

/*verilator public_flat_rd_on*/
input [3:0] ALUControl;
input [31:0] A;
input [31:0] B;
output reg [31:0] Q;
output reg Z;
output reg N;
output reg V;

reg [31:0] sll, srl, sra;
reg [31:0] CondInvB, sum;
reg neq, blt, ltu;
reg isAddSub;
/*verilator public_off*/

assign Z  = (Q == 32'b0);
assign N  = (sum[31] == 1'b1 || (ltu && ALUControl == 4'b1010));
assign V = ~(ALUControl[0] ^ A[31] ^ B[31]) & (A[31] ^ sum[31]) & isAddSub;

assign sll =  A <<  B[4:0];
assign srl =  A >>  B[4:0];
assign sra =  A >>> B[4:0];

assign ltu = (A < B);

// if we're performing subtraction (ALUControl[0] == 1), invert B
assign CondInvB = ALUControl[0] ? ~B : B;
assign sum = A + CondInvB + ALUControl[0]; // ALUControl[0] will be 0 if adding, 1 if subbing

assign isAddSub = ~ALUControl[2] & ~ALUControl[1] | ~ALUControl[1] & ALUControl[0];


always @ (*) 
begin
    case (ALUControl)
        4'b0000: Q = sum;                       // ADD 
        4'b0001: Q = sum;                       // SUB
        4'b0010: Q = A & B;                     // AND
        4'b0011: Q = A | B;                     // OR
        4'b0101: Q = sum[31] ^ V;               // SLT: do A - B, if result is neg (sum[31] == 1)
        4'b0110: Q = A ^ B;                     // XOR
        4'b0111: Q = sll;                       // SLL
        4'b1000: Q = srl;                       // SRL
        4'b1001: Q = sra;                       // SRA
        4'b1010: Q = ltu;                       // SLT(I)U
        default: Q = 32'bx;    
    endcase
end
    
endmodule