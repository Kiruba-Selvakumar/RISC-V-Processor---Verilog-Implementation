`include "forwarding_unit.v"

module forwarding_unit_tb;
    reg RegWrite_ExMem;
    reg RegWrite_MemWb;
    reg [4:0] rd_address_ExMem;
    reg [4:0] rd_address_MemWb;
    reg [4:0] rs1_address;
    reg [4:0] rs2_address;
    reg MemtoReg;
    wire [1:0] select_alusrc1;
    wire [1:0] select_alusrc2;
    
    // Instantiate the forwarding unit
    forwarding_unit uut (
        .RegWrite_ExMem(RegWrite_ExMem),
        .RegWrite_MemWb(RegWrite_MemWb),
        .rd_address_ExMem(rd_address_ExMem),
        .rd_address_MemWb(rd_address_MemWb),
        .rs1_address(rs1_address),
        .rs2_address(rs2_address),
        .MemtoReg(MemtoReg),
        .select_alusrc1(select_alusrc1),
        .select_alusrc2(select_alusrc2)
    );
    
    initial begin
        // Test case 1: No forwarding
        RegWrite_ExMem = 0; RegWrite_MemWb = 0;
        rd_address_ExMem = 5'd0; rd_address_MemWb = 5'd0;
        rs1_address = 5'd1; rs2_address = 5'd2;
        MemtoReg = 0;
        #10;
        
        // Test case 2: Forwarding from EX/MEM to rs1
        RegWrite_ExMem = 1; rd_address_ExMem = 5'd1;
        RegWrite_MemWb = 0; rd_address_MemWb = 5'd0;
        rs1_address = 5'd1; rs2_address = 5'd2;
        #10;
        
        // Test case 3: Forwarding from MEM/WB to rs1
        RegWrite_ExMem = 0; rd_address_ExMem = 5'd0;
        RegWrite_MemWb = 1; rd_address_MemWb = 5'd1;
        rs1_address = 5'd1; rs2_address = 5'd2;
        #10;
        
        // Test case 4: Forwarding from EX/MEM to rs2
        RegWrite_ExMem = 1; rd_address_ExMem = 5'd2;
        RegWrite_MemWb = 0; rd_address_MemWb = 5'd0;
        rs1_address = 5'd1; rs2_address = 5'd2;
        #10;
        
        // Test case 5: Forwarding from MEM/WB to rs2
        RegWrite_ExMem = 1; rd_address_ExMem = 5'd0;
        RegWrite_MemWb = 1; rd_address_MemWb = 5'd2;
        rs1_address = 5'd2; rs2_address = 5'd0;
        #10;
        
        // Test case 6: Both EX/MEM and MEM/WB match rs1 (EX/MEM should have priority)
        RegWrite_ExMem = 1; rd_address_ExMem = 5'd1;
        RegWrite_MemWb = 1; rd_address_MemWb = 5'd1;
        rs1_address = 5'd1; rs2_address = 5'd2;
        #10;
        
        // Test case 7: Both EX/MEM and MEM/WB match rs2 (EX/MEM should have priority)
        RegWrite_ExMem = 1; rd_address_ExMem = 5'd2;
        RegWrite_MemWb = 1; rd_address_MemWb = 5'd2;
        rs1_address = 5'd1; rs2_address = 5'd2;
        #10;
        
        // End simulation
        $finish;
    end
    
    initial begin
        $monitor("Time=%0t | EX/MEM_Write=%b, MEM/WB_Write=%b, rd_EX/MEM=%d, rd_MEM/WB=%d, rs1=%d, rs2=%d | src1=%b, src2=%b", 
                 $time, RegWrite_ExMem, RegWrite_MemWb, rd_address_ExMem, rd_address_MemWb, rs1_address, rs2_address, select_alusrc1, select_alusrc2);
    end
    
endmodule