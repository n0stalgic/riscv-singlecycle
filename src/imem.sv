///////////////////////////////////////////////////////////////
// mem
//
// Single-ported RAM with read and write ports
// Initialized with machine language program
///////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module imem # (  
    MEM_SIZE = 1024

) ( 
    input clk,
    input logic [31:0] a,
    output logic [31:0] rd
);

reg [7:0] RAM [MEM_SIZE*4-1:0];

// temporary storage before endian conversion and memory transformation
reg [31:0] temp [MEM_SIZE-1:0];
integer i=4, j=0;
integer asm_ID;


initial begin

 /* Very primitive boot ROM. Sets the stack pointer to address 
    to 0x200 before we load in the program. "Load" in user code at address 0x4  */

    RAM[0] = 8'h20;
    RAM[1] = 8'h00;
    RAM[2] = 8'h01;
    RAM[3] = 8'h13;

    asm_ID = $fopen("rv_test.bin", "rb");
    $fread(temp, asm_ID);

    /* endian conversion to little endian and transform to 4-byte alignment */
    /* verilator lint_off SELRANGE */
    repeat(MEM_SIZE - 4) begin
      RAM[i]     = temp[j][7:0];
      RAM[i + 1] = temp[j][15:8];
      RAM[i + 2] = temp[j][23:16];
      RAM[i + 3] = temp[j][31:24];
      i += 4;
      j += 1;
    end
  end
/* verilator lint_on SELRANGE */
always @ (*) begin
  rd[7:0]   = RAM[a + 3];
  rd[15:8]  = RAM[a + 2];
  rd[23:16] = RAM[a + 1];
  rd[31:24] = RAM[a];
  
end

endmodule

