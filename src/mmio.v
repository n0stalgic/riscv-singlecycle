`timescale 1ns / 1ps
module mmio  
    #(
        parameter ADDR_WIDTH          = 32,
        parameter DATA_WIDTH          = 32,
        parameter ENABLE_LINE_WIDTH   = 4
    
    ) (
    
    // CPU interface
    input wire Clk, Reset,
    input wire [ADDR_WIDTH-1:0] Address,
    input wire MemWrite, Stb,
    input wire [DATA_WIDTH-1:0] WriteData,
    output reg Valid, Busy,
    output reg [33:0] RespData,

    // wishbone inputs
    input wire wb_stall_i, wb_ack_i, wb_err_i,
    input wire [31:0] wb_data_i,

    // wishbone outputs
    output reg wb_cyc_o, wb_stb_o, wb_we_o,
    output reg [ADDR_WIDTH-1:0] wb_addr_o,
    output reg [DATA_WIDTH-1:0] wb_data_o
);

`define RESP_RESET     2'b00
`define RESP_WRITE_ACK 2'b01
`define RESP_READ_ACK  2'b10
`define RESP_BUS_ERROR 2'b11


localparam BUS_IDLE = 0;
localparam BUS_REQ  = 1;
localparam BUS_WAIT = 2;
localparam BUS_ERR  = 3;
localparam BUS_RST  = 4;

reg [2:0] state, next_state;

always @ (posedge Clk) 
begin
    if (Reset || wb_err_i)
        state <= BUS_RST;
    else
        state <= next_state;    
end

// state transition logic
always @ (*) 
begin
    next_state = state;
    case (state)
        BUS_RST:
            next_state = BUS_IDLE;
        BUS_IDLE:
            if ((wb_cyc_o) && (wb_stb_o))
                next_state = BUS_REQ;
        BUS_REQ:
            if ((wb_stb_o) && !(wb_stall_i))
                next_state = BUS_WAIT;
        BUS_WAIT:
            if ((wb_ack_i))
                next_state = BUS_IDLE;
        BUS_ERR:
            if ((!wb_err_i))
                next_state = BUS_IDLE;
    endcase

end

// output vectors
always @ (*)
begin

    wb_cyc_o = 1'b0;
    wb_stb_o = 1'b0;
    Busy     = 1'b0;
    Valid    = 1'b0;
    wb_we_o  = 1'b0;
    
    case (state)
        BUS_RST:
        begin
            Valid = 1'b1;
            RespData = { `RESP_RESET, 32'b0 };
        end
        BUS_IDLE:
        begin
            wb_cyc_o = 1'b0;
            wb_stb_o = 1'b0;
            Busy     = 1'b0;

            if (Reset)
                RespData = `RESP_RESET;
                
             // if CPU triggers a bus operation, raise stb, cyc, and set busy flag
            if (Stb && !(wb_err_i))       
            begin
                wb_cyc_o = 1'b1;
                wb_stb_o = 1'b1;
                Busy     = 1'b1;
                wb_addr_o = Address;
                wb_we_o  = MemWrite;
            end
        end
        BUS_REQ:
        begin
            if (!wb_stall_i)
            begin
                // bus request accepted by peripheral
                wb_stb_o  = 1'b0;
                wb_data_o = WriteData;

                if (wb_ack_i)
                begin
                    wb_cyc_o  = 1'b0;
                    wb_stb_o  = 1'b0;
                    Valid     = 1'b1;
                    if (MemWrite)
                        RespData = `RESP_WRITE_ACK;
                    else
                        RespData = {`RESP_READ_ACK, wb_data_i};
                end
            end
        end
        BUS_WAIT:
            if (wb_ack_i)
                wb_cyc_o = 1'b0;
        
        BUS_ERR:
        begin
            if (wb_err_i)
            begin
                Valid = 1'b0;
                wb_cyc_o = 1'b0;
                wb_stb_o = 1'b0;
                RespData = { `RESP_BUS_ERROR, 32'h0 };                
            end            
        end
                
    endcase
end

endmodule