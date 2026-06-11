    `include "data_memory.v"
    `include"immgen.v"
    `include "instruction_decoder.v"
    `include "instruction_memory.v"
    `include "register.v"
    `include "alu_proj.v"
    `include "shift_left_logical.v"

    // PC is a 64-bit register because one of it's possible inputs is from immediate + PC. This can be changed.
    module register_64bit(out,in,clk);
        input wire [63:0] in;
        output reg [63:0] out;
        input clk;
        always @(posedge clk)
        begin
            out <= in;
        end
        initial begin
            out<=0;
        end
    endmodule


    module alu_control(ALUControl,ALUOp,funct7,funct3);
        input [1:0] ALUOp;
        input [6:0] funct7;
        input [2:0] funct3;
        output [1:0] ALUControl;
        wire r_ins_sel0,r_ins_sel1,mux1_out;
        or a1(r_ins_sel0,funct7[5],funct3[0]); //r_ins_sel0 = 1 when sub, and is selected
        assign r_ins_sel1 = funct3[2];
        mux4x1 m1(ALUControl[0],ALUOp[0],ALUOp[1],1'b0,1'b1,r_ins_sel0,r_ins_sel0);
        mux4x1 m2(ALUControl[1],ALUOp[0],ALUOp[1],1'b0,1'b0,r_ins_sel1,r_ins_sel1);
    endmodule

    // PROCESSOR MAIN MODULE --------------------------------------

    module processor (clk);
    input clk;
    wire [31:0] instruction;
    genvar i;
    //Control Logic Instantiation
    wire MemtoReg,MemWrite,ALUSrc,RegWrite,Branch,MemRead;
    wire [1:0] ALUOp;
    inst_decoder ID (.MemtoReg(MemtoReg),
                    .ALUOp(ALUOp),
                    .MemWrite(MemWrite),
                    .ALUSrc(ALUSrc),
                    .RegWrite(RegWrite),
                    .Branch(Branch),
                    .MemRead(MemRead),
                    .instruction(instruction)
                    );

    //TO DO: Make the input logic of PC - DONE (Hopefully)
    wire[63:0] pc_in,pc_out;
    register_64bit PC (pc_out,pc_in,clk);


    //ALU Instantiation 
    //IMPORTANT: TEST PROPER FUNCTIONING OF ALU
    wire [1:0] ALUControl;
    alu_control AC (.ALUControl(ALUControl),.ALUOp(ALUOp),.funct7(instruction[31:25]),.funct3(instruction[14:12]));
    wire[63:0] alu_out,alu_src1,alu_src2;
    wire zero,overflow;
    alu ALU (.alu_out(alu_out),.overflow(overflow),.zero(zero),.alu_src1(alu_src1),.alu_src2(alu_src2),.alu_op(ALUControl));

    //ImmGen Instantiation
    wire [63:0] immediate;
    immgen IMMGEN (.instr(instruction),.imm(immediate));


    //ALU SRC2 MUX
    wire[63:0] read_data2;
    generate
        for (i=0;i<64;i=i+1) begin:gen_mux2
            mux2x1 MUX2 (.out(alu_src2[i]),.select(ALUSrc),.in0(read_data2[i]),.in1(immediate[i]));
        end
    endgenerate
    //Instruction Memory Instantiate
    instruction_mem IM (.ReadData(instruction),.Address(pc_out));

    //Register Bank Instantiation
    wire[63:0] write_reg;
    main_reg Reg_Bank (.op1(alu_src1),.op2(read_data2),.rs1(instruction[19:15]),.rs2(instruction[24:20]),.rd(instruction[11:7]),.rd_val(write_reg),.reg_write(RegWrite),.clk(clk));

    //Data Memory Instantiation
    wire[63:0] data_mem_read_data;
    data_mem DM (.Address(alu_out),.WriteData(read_data2),.ReadData(data_mem_read_data),.MemWrite(MemWrite),.MemRead(MemRead),.clk(clk));

    //Write Register Mux
    generate
        for (i=0;i<64;i=i+1) begin:gen_Write_Reg_Mux
        mux2x1 Write_Reg_Mux (.out(write_reg[i]),.select(MemtoReg),.in0(alu_out[i]),.in1(data_mem_read_data[i]));
        end
    endgenerate

    //adder for PC Increment
    wire [63:0] pc_mux0;
    wire temp1_unused, temp2_unused;
    adder PC_Adder (.S(pc_mux0), .c_out(temp1_unused), .overflow(temp2_unused), .A(pc_out), .B(64'd4), .c_in(1'b0));


    //Left Shifter
    wire [63:0] left_shift_immediate,pc_mux1;
    shift_left_logical sll (.rd(left_shift_immediate),.rs1(immediate),.rs2(64'b1));
    wire temp3,temp4;
    adder PC_Adder2 (.S(pc_mux1),.c_out(temp3),.overflow(temp4),.A(pc_out),.B(immediate),.c_in(1'b0));

    //PC Mux
    wire pc_mux_select0;
    reg pc_mux_select1;
    and (pc_mux_select0,Branch,zero);
    initial begin
        pc_mux_select1=1'b1;
    end
    always @(posedge clk) begin
        if (pc_mux_select1) begin
            pc_mux_select1=1'b0;
        end
    end
    generate
        for (i=0;i<64;i=i+1) begin:gen_PC_Mux
        mux4x1 PC_Mux (.out(pc_in[i]),.sel0(pc_mux_select0),.sel1(pc_mux_select1),.in0(pc_mux0[i]),.in1(pc_mux1[i]),.in2(1'b0),.in3(1'b0));
        end
    endgenerate

    //Handling ALU Overflow
    always @(overflow) begin
        if (overflow) begin
            $display("ALU Overflow at time %0t.", $time);
            $finish;
        end
    end
    //HALTING and Error handling in case of invalid instruction and Invalid register address 
    always @(instruction) begin
        if (instruction[6:0]==7'b0110011) begin //R TYPE
            if (instruction[31:25]==7'h20 && instruction[14:12]!=3'b000) begin
                $display("ERROR: Invalid Instruction (Wrong funct3 or funct7) at time %t", $time);
                $stop;
            end
            else if (instruction[31:25]==7'b0 && (instruction[14:12]!=3'b000 && instruction[14:12]!=3'h4 && instruction[14:12]!=3'h6 && instruction[14:12]!=3'h7)) begin
                $display("ERROR: Invalid Instruction (Wrong funct3 or funct7) at time %t", $time);
                $stop;
            end
            else if (instruction[24:20]>31 || instruction[19:15]>31 || instruction[11:7]>31) begin
                $display("ERROR: Register Address (RS1 or RS2 or RD) out of bounds at time %t", $time);
                $stop;
            end
        end
         else if (instruction[6:0]==7'b0000011) begin //I TYPE (Load)
            if (instruction[19:15]>31 || instruction[11:7]>31) begin
                $display("ERROR: Register Address (RS1 or RD) of load instruction out of bounds at time %t", $time);
                $stop;
            end
         end
         else if (instruction[6:0]==7'b0100011) begin // S TYPE (Store)
            if (instruction[24:20]>31 || instruction[19:15]>31) begin
                $display("ERROR: Register Address (RS1 or RS2) of store instruction out of bounds at time %t", $time);
                $stop;
            end
         end
         else if (instruction[6:0]==7'b1100011) begin // SB TYPE (Branch)
            if (instruction[24:20]>31 || instruction[19:15]>31) begin
                $display("ERROR: Register Address (RS1 or RS2) of branch instruction out of bounds at time %t", $time);
                $stop;
            end
         end
         else if (^instruction[6:0]===1'bx) begin
            $display("HALT: End of all instructions at time %0t. Halting the processor.", $time);
            $finish;
         end
        else begin
            $display("ERROR: Invalid Instruction (Wrong Opcode = %0b) at time %0t",instruction[6:0], $time);
            $stop; 
        end
    end

endmodule
