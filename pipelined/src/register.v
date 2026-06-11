module main_reg (op1,op2,rs1,rs2,rd,rd_val, reg_write,clk);
    input[4:0] rs1,rs2,rd; 
    input [63:0]rd_val;
    input reg_write,clk;
    // output reg [4:0] rd; 
    output reg  [63:0] op1,op2;
    integer i;
    reg [63:0] m_reg [0:31]; 
    always@(*)
    begin
        //The commented out part needs to be implemented in processor module as rs1, rs2, rd need to be checked only if they are being used as register addresses
        // if (rs1>31 || rs2>31 || rd>31) begin 
        //     $display("ERROR:Register Address out of bounds at time %t", $time);
        //     $stop;
        // end
        // else begin
        op1<=m_reg[rs1];
        op2<=m_reg[rs2];
    end
    always @(negedge clk ) begin
        if(reg_write && rd!=0)
            m_reg[rd]=rd_val;


        $display("\nTime = %0t", $time);
        for (i = 0; i < 32; i = i + 1) begin
            $display("Reg[%0d]: %0d", i, m_reg[i]);
        end
    end
    initial begin
        m_reg [0]=0;
    end
endmodule

