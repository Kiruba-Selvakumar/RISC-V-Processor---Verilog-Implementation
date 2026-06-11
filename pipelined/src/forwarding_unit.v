//Maybe a slight change is needed for hazard detection for load-store. Don't know how branch will react to this.
module forwarding_unit (
    input RegWrite_ExMem,
    input RegWrite_MemWb,
    input [4:0] rd_address_ExMem,
    input [4:0] rd_address_MemWb,
    input [4:0] rs1_address,
    input [4:0] rs2_address,
    input MemtoReg,
    output reg[1:0] select_alusrc1,
    output reg[1:0] select_alusrc2
);
    //Both select_alusrc1 and select_alusrc2 should be 00 for no forwarding case
    //Forwarding from EX/MEM should be 10
    //Forwarding from MEM/WB should be 11
    //10 has higher priority
    always @(*) begin
    if (RegWrite_ExMem || RegWrite_MemWb) begin
        //First handling for select_alusrc1
        if (RegWrite_ExMem && rd_address_ExMem == rs1_address && rd_address_ExMem) begin
            assign select_alusrc1 = 2'b10;
        end
        else if (RegWrite_MemWb && rd_address_MemWb == rs1_address && rd_address_MemWb) begin
            assign select_alusrc1 = 2'b11;
        end
        else begin
            assign select_alusrc1 = 2'b00;
        end
        //Now handling for select_alusrc2
        if (RegWrite_ExMem && rd_address_ExMem == rs2_address && rd_address_ExMem) begin 
            assign select_alusrc2 = 2'b10;
        end
        else if (RegWrite_MemWb && rd_address_MemWb == rs2_address && rd_address_MemWb) begin
            assign select_alusrc2 = 2'b11;
        end
        else begin
            assign select_alusrc2 = 2'b00;
        end
    end
    else begin
        assign select_alusrc1 = 2'b00;
        assign select_alusrc2 = 2'b00;
    end
    end
endmodule