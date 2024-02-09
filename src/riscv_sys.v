`timescale 1ns / 1ps
module riscv_sys (
        input clk, 
        input reset,
        output reg [31:0] WriteData,
        output reg [31:0] iDataAddr,
        output reg [31:0] dDataAddr,
        output reg MemWrite

);
    reg [31:0] iMemReadData, dMemReadData;

    riscvsingle rvcpu(
        .clk(clk),
        .reset(reset),
        .MemWrite(MemWrite),
        .iAddr(iDataAddr),
        .dAddr(dDataAddr),
        .WriteData(WriteData),
        .iMemData(iMemReadData),
        .dMemData(dMemReadData)
    );

    imem imem (
        .clk(clk),
        .a(iDataAddr),
        .rd(iMemReadData)
    );

    dmem dmem (
        .clk(clk),
        .we(MemWrite),
        .a(dDataAddr),
        .wd(WriteData),
        .rd(dMemReadData),
        .rde(1'b1)

    );

endmodule