`timescale 1ns / 1ps
module riscv_sys (
        input clk_i, 
        input reset_i,
        output reg [31:0] WriteData,
        output reg [31:0] BusAddress,
        output reg MemWrite

);
    wire Stb;
    wire Busy;
    wire Valid;
    wire [31:0] iDataAddr;
    wire [31:0] iMemReadData;

    // wishbone 
    wire wb_stall;
    wire wb_ack;
    wire wb_err;
    wire [31:0] wb_data_o;
    wire [31:0] wb_data_i;

    wire wb_cyc;
    wire wb_stb;
    wire wb_we;
    wire [31:0] wb_addr;
    wire [31:0] wb_data;

    wire [31:0] BusAddr;
    wire [33:0] BusData;

    riscvsingle rvcpu(
        .clk(clk_i),
        .reset(reset_i),
        .MemWrite(MemWrite),
        .InstrAddr(iDataAddr),
        .BusAddr(BusAddress),
        .Stb(Stb),
        .Ack(Valid),
        .WriteData(WriteData),
        .iMemData(iMemReadData),
        .dMemData(BusData[31:0])
    );

    mmio socbus (

        // CPU interface
        // {{{
        .Clk(clk_i),
        .Reset(reset_i),
        .Address(BusAddress),
        .MemWrite(MemWrite),
        .Stb(Stb),
        .Busy(Busy),
        .WriteData(WriteData),
        .Valid(Valid),
        .RespData(BusData[31:0]),
        // }}}

        // wishbone interface 
        // {{{
        .wb_stall_i(wb_stall),
        .wb_ack_i(wb_ack),
        .wb_err_i(wb_err),
        .wb_data_i(wb_data_i),
        .wb_cyc_o(wb_cyc),
        .wb_stb_o(wb_stb),
        .wb_we_o(wb_we),
        .wb_addr_o(wb_addr),
        .wb_data_o(wb_data_o)
        // }}}
    );

    imem imem (
        .clk(clk_i),
        .a(iDataAddr),
        .rd(iMemReadData)
    );

    dmem dmem (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .cyc_i(wb_cyc),
        .stb_i(wb_stb),
        .we_i(wb_we),
        .addr_i(wb_addr),
        .data_i(wb_data_o),
        .ack_o(wb_ack),
        .stall_o(wb_stall),
        .err_o(wb_err),
        .data_o(wb_data_i)
    );

endmodule