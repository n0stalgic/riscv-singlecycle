#ifndef __TESTBENCH_H__ 
#define __TESTBENCH_H__

#include "verilated_vcd_c.h"
#include "verilated.h"
#include "obj_dir/Vriscv_sys___024root.h"
#include "verilatedos.h"
#include <cassert>

#define HANG_RS1 0x0
#define HANG_RS2 0x0
#define BOOT_ROM_SIZE 0x4
#define PC_MAIN_EXIT  0x58
#define RV32I_ASM_TEST   0

template<class MODULE> class TESTBENCH
{
    public: 

        vluint64_t m_tickcount;
        MODULE* m_core;
        VerilatedVcdC* m_trace;
        Vriscv_sys__Syms* syms;
        Vriscv_sys___024root* vriscv;
        bool sim_complete;

        vluint32_t instr, opcode, rd, imm;

        TESTBENCH(VerilatedContext* contextp)
        {
            m_core = new MODULE;
            vriscv = m_core->rootp;
            
            Verilated::traceEverOn(true);
            m_tickcount= 0UL;
            sim_complete = false;
        }

        virtual ~TESTBENCH(void)
        {
            delete m_core;
            m_core = NULL;
        }

        virtual void reset(void)
        {
            m_core->reset = 1;
            this->tick();
            m_core->reset = 0;
        }

        virtual void opentrace(const char* vcdname)
        {
            if (!m_trace)
            {
                m_trace = new VerilatedVcdC;
                m_core->trace(m_trace, 99);
                m_trace->open(vcdname);
            }
        }

        virtual void closetrace(void)
        {
            if (m_trace)
            {
                m_trace->close();
                m_trace = NULL;
            }
        }

        virtual void tick(void)
        {
            vluint32_t ALU_actual;
            vluint32_t ALU_expected;
            vluint32_t A; 
            vluint32_t B;
            vluint32_t Old_PC, PC;
            vluint32_t PC_Write;
            vluint32_t Reg_Write;
            vluint32_t ALU_Control;
            vluint32_t ALU_Src_B;
            
            m_tickcount++;
            m_core->clk = 0;
            m_core->eval();
            if (m_trace)
            {
                m_trace->dump(m_tickcount);
                
            }

            // toggle clock
            m_core->clk = 1;
            m_core->eval();
            decode();
            if (m_trace)
            {
                m_trace->dump(10*m_tickcount);
                
            }

            ALU_Control = vriscv->riscv_sys__DOT__rvcpu__DOT__ALUControl;
            A = vriscv->riscv_sys__DOT__rvcpu__DOT__ALU__DOT__A;
            B = vriscv->riscv_sys__DOT__rvcpu__DOT__ALU__DOT__B;
            PC = vriscv->riscv_sys__DOT__rvcpu__DOT__iAddr;
            PC_Write = vriscv->riscv_sys__DOT__rvcpu__DOT__PCWrite;
            Reg_Write = vriscv->riscv_sys__DOT__rvcpu__DOT__regfile__DOT__WE3;
            ALU_actual = vriscv->riscv_sys__DOT__rvcpu__DOT__ALU__DOT__Q;
            ALU_Src_B  = vriscv->riscv_sys__DOT__rvcpu__DOT__SrcB; 
            
            
            switch (ALU_Control) {
                case 0x00:
                    if (opcode == 0x33)
                        printf("add ");
                    else
                        printf("addi ");
                    ALU_expected = A + B;
                    assert(ALU_actual == ALU_expected);
                    printf("OK - PC: %x\n", PC);
                    
                    break;

                case 0x01:
                    if (opcode == 0x33)
                        printf("sub ");
                    else
                        printf("subi ");
                    ALU_expected = A - B;
                    assert(ALU_actual == ALU_expected);
                    printf("OK - PC: %x\n", PC);
                    break;

                case 0x2:
                    if (opcode == 0x33)
                        printf("and ");
                    else
                        printf("andi ");
                    ALU_expected = A & B;
                    assert(ALU_actual == ALU_expected);
                    printf("OK - PC: %x\n", PC);
                    break;

                case 0x3:
                    if (opcode == 0x33)
                        printf("or ");
                    else
                        printf("ori ");
                    ALU_expected = A | B;
                    assert(ALU_actual == ALU_expected);
                    printf("OK - PC: %x\n", PC);
                    break;

                case 0x5:
                    if (opcode == 0x33)
                        printf("slt ");
                    else
                        printf("slti(u) ");
                    ALU_expected = A < B;
                    assert(ALU_actual == ALU_expected);
                    printf("OK - PC: %x\n", PC);
                    break;

                case 0x06:
                    if (opcode == 0x33)
                        printf("xor ");
                    else
                        printf("xori ");
                    ALU_expected = A ^ B;
                    assert(ALU_actual == ALU_expected);
                    printf("OK - PC: %x\n", PC);
                    break;

                case 0x07:
                    if (opcode == 0x33)
                        printf("sll ");
                    else
                        printf("slli ");
                    ALU_expected = A << B;
                    assert(ALU_actual == ALU_expected);
                    printf("OK - PC: %x\n", PC);
                    break;

                case 0x08:
                    if (opcode == 0x33)
                        printf("srl ");
                    else
                        printf("srli ");
                    ALU_expected = A >> B;
                    assert(ALU_actual == ALU_expected);
                    printf("OK - PC: %x\n", PC);
                    break;
                case 0x09:
                    if (opcode == 0x33)
                    {
                        printf("sra ");
                        ALU_expected = A >> B;
                    }
                        
                    else
                    {
                        printf("srai ");
                        ALU_expected = (signed) A >> (signed) B;
                    }

                    assert(ALU_actual == ALU_expected);
                    printf ("OK - PC %x\n", PC);
                    break;          
            }

            // trigger falling edge
            m_core->clk = 0;
            m_core->eval();
            if (m_trace)
            {
                m_trace->dump(10*m_tickcount+5);
                m_trace->flush();
            }
            
        }

        virtual void decode(void)
        {
            /* decode infinite loop instruction */
            instr  = vriscv->riscv_sys__DOT__rvcpu__DOT__iMemData;
            opcode = (instr & 0x7F);
            rd     = (instr & 0xF80);
            imm    = (instr & (1 << 20) | (instr & 0xFF000) | (instr & (1 << 11)) | (instr & 0x7FE)) >> 12;
        
        }

        virtual bool done(void)
        {
            
            vluint32_t PC = vriscv->riscv_sys__DOT__rvcpu__DOT__iAddr;
            // printf("PC: 0x%x, opcode: 0x%x, imm: 0x%x, rd: 0x%x\n", PC, opcode, imm, rd);
            return (opcode == 0x6F && imm == 0x0 && rd == 0x0);     // catch a jal to the current PC -- means we are in an infinite loop
        }

};
#endif /*__TESTBENCH_H__*/