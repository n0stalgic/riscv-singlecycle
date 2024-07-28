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

    // wishbone signals
    input wire cyc_i,
    input wire stb_i,
    input wire we_i,
    input wire [31:0] addr_i,
    input wire [31:0] data_i,
    output logic ack_o,
    output logic stall_o,
    output logic err_o,
    output logic [31:0] data_o,

    // CPU interface
    input clk_i,
    input reset_i
    
);


localparam BUS_ADDR = 32'h0000400;
localparam MEM_UPPER_BOUND = 32'h7FC;

reg [7:0] RAM [MEM_SIZE*4-1:0];


// mem read
always_latch 
begin 
  if ((!we_i) && (stb_i) && (!stall_o) && (!err_o)) begin
    data_o[7:0]   = RAM[addr_i];
    data_o[15:8]  = RAM[addr_i + 1];
    data_o[23:16] = RAM[addr_i + 2];
    data_o[31:24] = RAM[addr_i + 3];
  end
  
end

// mem write
always @(posedge clk_i) 
begin
    if ((stb_i) && (we_i) && (!stall_o) && !(err_o)) begin
        RAM[addr_i]     <= data_i[7:0];
        RAM[addr_i + 1] <= data_i[15:8];
        RAM[addr_i + 2] <= data_i[23:16];
        RAM[addr_i + 3] <= data_i[31:24];
    end

end

// throw bus error if:
// 1) outside address range of 0x0 to 0x400
// 2) address not 4-byte aligned
always @ (posedge clk_i) 
begin
  if ((addr_i > MEM_UPPER_BOUND || 
  (addr_i[0] || addr_i[1])) &&
  (stb_i))
    err_o <= 1'b1;  
end

always @ (posedge clk_i)
begin
  if (reset_i)
    ack_o <= 1'b0;
  else
    ack_o <= ((stb_i) && (!stall_o));
end

endmodule

