`timescale 1ns / 1ps
/*verilator public_flat_rd_on*/
module riscvsingle (
            input  logic        clk, reset,
            output logic        MemWrite,
            output logic [31:0] iAddr, dAddr, WriteData,
            input  logic [31:0] iMemData, dMemData
);

    wire RegWrite;
    wire LSE;
    wire Zero;
    wire Negative;
    wire ALUSrc;
    wire IRWrite;
    wire PCWrite;
    wire ImmSel;
    wire [1:0] PCSrc;
    wire [1:0] ResultSrc;
    wire [3:0] ALUControl;
    wire [2:0] ImmSrc;
    wire [2:0] LST;
    wire [31:0] PC;
    wire [31:0] PCImm;
    wire [31:0] PCPlus4;
    wire [31:0] PCTarget;
    wire [31:0] PCNext;
    wire [31:0] Result;
    wire [31:0] Rd1;
    wire [31:0] Rd2;
    wire [31:0] ImmExt;
    wire [31:0] SrcB;
    wire [31:0] SrcA;
    wire [31:0] ALUResult;
    /*verilator public_off*/

    assign dAddr = ALUResult;
    assign WriteData = Rd2;
    

    mux_3_1 pc_mux (
        .sel(PCSrc),
        .in1(PCPlus4),
        .in2(PCTarget),
        .in3(Result),
        .dout(PCNext)
    );

    DFF pc_reg (
        .CLK(clk),
        .RST(reset),
        .D(PCNext),
        .Q(iAddr)
    );

    adder pc_4_adder(
        .A(iAddr),
        .B(32'b100),
        .Q(PCPlus4)
    );

    ctrl_unit cntrl(
    .op(iMemData[6:0]),
    .funct3(iMemData[14:12]),
    .funct7_5(iMemData[30]),
    .Zero(Zero),
    .Negative(Negative),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .ImmSel(ImmSel),
    .ALUControl(ALUControl),
    .PCSrc(PCSrc),
    .LST(LST),
    .LSE(LSE),
    .RegWrite(RegWrite)
  );

    regfile regfile (
    .CLK(clk),
    .WE3(RegWrite),
    .A1(iMemData[19:15]),
    .A2(iMemData[24:20]),
    .A3(iMemData[11:7]),
    .LST(LST),
    .LSE(LSE),
    .WD3(Result),
    .RD1(SrcA),
    .RD2(Rd2)
    );

    extender extender (
    .Instr(iMemData[31:7]),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExt)
    );

    mux_2_1 pc_imm_sel (
        .in1(iAddr),
        .in2(1'b0),
        .sel(ImmSel),
        .dout(PCImm)
    );

    adder pc_imm_adder(
        .A(PCImm),
        .B(ImmExt),
        .Q(PCTarget)
    );

    mux_2_1 alu_b_mux (
        .sel(ALUSrc),
        .in1(Rd2),
        .in2(ImmExt),
        .dout(SrcB)
    );

    ALU ALU (
        .A(SrcA),
        .B(SrcB),
        .ALUControl(ALUControl),
        .Z(Zero),
        .N(Negative),
        .Q(ALUResult)
    );

    mux_4_1 result_mux (
        .sel(ResultSrc),
        .in1(ALUResult),
        .in2(dMemData),
        .in3(PCPlus4),
        .in4(PCTarget),
        .dout(Result)
    );
    
endmodule