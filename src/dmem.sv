///////////////////////////////////////////////////////////////
// mem
//
// Single-ported RAM with read and write ports
// Initialized with machine language program
///////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module dmem # (  
    MEM_SIZE = 4096

) (
    input logic clk, we,
    input logic [31:0] a,
    input logic [31:0] wd,
    input logic rde,
    output logic [31:0] rd
);

reg [7:0] RAM [MEM_SIZE*4-1:0];

always @ (*) begin
  if (rde) begin
    rd[7:0]   = RAM[a];
    rd[15:8]  = RAM[a + 1];
    rd[23:16] = RAM[a + 2];
    rd[31:24] = RAM[a + 3];
  end
  
end

always @(posedge clk) begin
    if (we) begin
        RAM[a]     <= wd[7:0];
        RAM[a + 1] <= wd[15:8];
        RAM[a + 2] <= wd[23:16];
        RAM[a + 3] <= wd[31:24];
    end

end

endmodule

