module DFF_CE (
    CLK, RST, D, CE, Q
);

input CLK;
input RST;
input [31:0] D;
input CE;
output reg [31:0] Q;

always @ (posedge CLK or posedge RST)
    if (RST)
        Q <= 32'b0;
    else
        if (CE)
            Q <= D;
    
endmodule