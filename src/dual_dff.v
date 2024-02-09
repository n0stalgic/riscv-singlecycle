module DUAL_DFF (
    CLK, RST, D1, D2, CE, Q1, Q2

);

input CLK;
input RST;
input [31:0] D1;
input [31:0] D2;
input CE;
output reg [31:0] Q1;
output reg [31:0] Q2;

always @ (posedge CLK or posedge RST)
    if (RST)
        {Q1, Q2} <= {32'b0, 32'b0};
    else
        if (CE)
            {Q1, Q2} <= {D1, D2};

endmodule
