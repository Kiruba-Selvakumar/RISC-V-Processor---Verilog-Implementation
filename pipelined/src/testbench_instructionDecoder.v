`include "instruction_decoder.v"
module inst_decoder_tb;
    reg [31:0] instruction;
    wire MemtoReg, MemWrite, ALUSrc, RegWrite, Branch, MemRead;
    wire [1:0] ALUOp;

    // Instantiate the instruction decoder
    inst_decoder uut (
        .instruction(instruction),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Branch(Branch),
        .MemRead(MemRead),
        .ALUOp(ALUOp)
    );

    initial begin
        // Monitor signals
        $monitor("Time=%0t | Instr=%b | MemtoReg=%b | MemWrite=%b | ALUSrc=%b | RegWrite=%b | Branch=%b | MemRead=%b | ALUOp=%b",
                 $time, instruction, MemtoReg, MemWrite, ALUSrc, RegWrite, Branch, MemRead, ALUOp);

        // Test R-type instruction (e.g., opcode 0110011 for R-type)
        instruction = 32'b0000000_00000_00000_000_00000_0000000; // R-type (add)
        #10;

        // Test Load instruction (e.g., opcode 0000011 for Load)
        instruction = 32'b0000000_00001_00010_010_00011_0000011; // Load (e.g., LW)
        #10;

        // Test Store instruction (e.g., opcode 0100011 for Store)
        instruction = 32'b0000000_00001_00010_010_00011_0100011; // Store (e.g., SW)
        #10;

        // Test Branch instruction (e.g., opcode 1100011 for Branch)
        instruction = 32'b0000000_00001_00010_000_00011_1100011; // Branch (e.g., BEQ)
        #10;

        // End simulation
        $finish;
    end
endmodule
