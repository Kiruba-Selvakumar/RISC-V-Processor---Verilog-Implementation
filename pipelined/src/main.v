`include "alu_proj.v"
`include "pipeline_register.v"
`include "instruction_memory.v"
`include "register.v"
`include "hazard_detection.v"
`include "data_memory.v"
`include "instruction_decoder.v"
`include "immgen.v"
`include "forwarding_unit.v"

//ISSUE READ_DATA2 not being selected. IMMEDIATE MAY BE BEING SELECTED INSTEAD OF READ_DATA2
module register_64bit(out,in,write,clk);
        input wire [63:0] in;
        input write;
        output reg [63:0] out;
        input clk;
        always @(posedge clk)
        begin
            if(write)
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

module pipelined_processor (clk);
    input clk;
    wire [63:0] pc_in,pc_out;
    wire pc_write;
    register_64bit PC (pc_out,pc_in,pc_write,clk);
    always @(control_MemWb[0]||control_MemWb[1])begin
        if(^control_MemWb[1:0]===1'bX)begin
            $display ("Instructions finished. Exiting simulation");
            $finish;
        end
    end

     //adder for PC Increment::: TO BE DONE: pc_mux1 value has to be assigned after execute stage
    wire [63:0] pc_mux0,pc_mux1;
    wire temp1_unused, temp2_unused;
    adder PC_Adder (.S(pc_mux0), .c_out(temp1_unused), .overflow(temp2_unused), .A(pc_out), .B(64'd4), .c_in(1'b0));

    //Instruction Memory Instantiation
    wire [31:0] instruction;
    wire ins_flush,IF_ID_write;
    instruction_mem IM (.ReadData(instruction),.Address(pc_out));

    //IF_ID Register Instantiation
    wire [63:0] pc_IfId;
    wire[31:0] instruction_IfId;
    // mux2x1 new_mux(
    //     .out(IF_ID_write_new),
    //     .select(pc_mux_select0),
    //     .in0(IF_ID_write),
    //     .in1(1'b0)
    // );
    wire IF_ID_write_new;
    and (IF_ID_write_new,IF_ID_write,pc_mux_selectnot);
    IF_ID IF_ID_reg (.clk(clk),.ins_flush(pc_mux_select0),.write_enable(IF_ID_write_new),.instruction(instruction),.pc(pc_out),.instruction_out(instruction_IfId),.pc_out(pc_IfId));

    //Register File Instantiation
    wire[63:0] write_reg,read_data1,read_data2;
    wire [4:0] rd_address_MemWb;
    wire RegWrite_MemWb;
    main_reg Reg_Bank (.op1(read_data1),.op2(read_data2),.rs1(instruction_IfId[19:15]),.rs2(instruction_IfId[24:20]),.rd(rd_address_MemWb),.rd_val(write_reg),.reg_write(control_MemWb[0]),.clk(clk));
    
    //Control Logic Instantiation
    wire MemtoReg,MemWrite,ALUSrc,RegWrite,Branch,MemRead;
    wire [1:0] ALUOp,ALUControl;
    inst_decoder ID (.MemtoReg(MemtoReg),
                    .ALUOp(ALUOp),
                    .MemWrite(MemWrite),
                    .ALUSrc(ALUSrc),
                    .RegWrite(RegWrite),
                    .Branch(Branch),
                    .MemRead(MemRead),
                    .instruction(instruction_IfId)
                    );
    alu_control AC (
        .ALUControl(ALUControl),
        .ALUOp(ALUOp),
        .funct7(instruction_IfId[31:25]),
        .funct3(instruction_IfId[14:12])
    );
    //Control[7] ALUSrc, Control[6:5] ALUOp, Control[4] Branch, Control[3] MemWrite, Control[2] MemRead, Control[1] MemtoReg, Control[0] RegWrite 
    //Control mux select 0 = 0
    wire control_mux_select;
    wire [7:0] control_IfId;
    mux2x1 control_mux1 (.out(control_IfId[7]),.select(control_mux_select),.in0(1'b0),.in1(ALUSrc)),
           control_mux2 (.out(control_IfId[6]),.select(control_mux_select),.in0(1'b0),.in1(ALUControl[1])),
           control_mux3 (.out(control_IfId[5]),.select(control_mux_select),.in0(1'b0),.in1(ALUControl[0])),
           control_mux4 (.out(control_IfId[4]),.select(control_mux_select),.in0(1'b0),.in1(Branch)),
           control_mux5 (.out(control_IfId[3]),.select(control_mux_select),.in0(1'b0),.in1(MemWrite)),
           control_mux6 (.out(control_IfId[2]),.select(control_mux_select),.in0(1'b0),.in1(MemRead)),
           control_mux7 (.out(control_IfId[1]),.select(control_mux_select),.in0(1'b0),.in1(MemtoReg)),
           control_mux8 (.out(control_IfId[0]),.select(control_mux_select),.in0(1'b0),.in1(RegWrite));
    
    //Immediate Generator Instantiation
    wire [63:0] immediate;
    immgen IMMGEN (.instr(instruction_IfId),.imm(immediate));

    //Hazard Detection Unit
    wire MemRead_Id_Ex;
    wire [4:0] rd_address_IdEx;
    wire [7:0] control_IdEx;
    hazard_detection_unit hazard_detection (
        .MemRead_Id_Ex(control_IdEx[2]),
        .rd_address_IdEx(rd_address_IdEx),
        .opcode_IfId(instruction_IfId[6:0]),
        .rs1_address_IfId(instruction_IfId[19:15]),
        .rs2_address_IfId(instruction_IfId[24:20]),
        .pc_write(pc_write),
        .If_ID_write(IF_ID_write),
        .control_mux_select(control_mux_select)
    );

    //ID_EX Register
    wire [4:0] rs1_address_IdEx,rs2_address_IdEx;
    wire [63:0] rs1_data_IdEx,rs2_data_IdEx;
    wire [63:0] immediate_IdEx,pc_IdEx;
    ID_EX ID_EX_reg(
        .clk(clk),
        .rs1_address_in(instruction_IfId[19:15]),
        .rs2_address_in(instruction_IfId[24:20]),
        .rd_address_in(instruction_IfId[11:7]),
        .rs1_data_in(read_data1),
        .rs2_data_in(read_data2),
        .control_signal_in(control_IfId),
        .immediate_in(immediate),
        .rs1_address_out(rs1_address_IdEx),
        .rs2_address_out(rs2_address_IdEx),
        .rd_address_out(rd_address_IdEx),
        .rs1_data_out(rs1_data_IdEx),
        .rs2_data_out(rs2_data_IdEx),
        .control_signal_out(control_IdEx),
        .immediate_out(immediate_IdEx),
        .pc_in(pc_IfId),
        .pc_out(pc_IdEx),
        .con_flush(pc_mux_select0)
    );

    //Instantiate forwarding unit
    wire [4:0] rd_address_ExMem;
    wire [1:0] select_alusrc1,select_alusrc2;
    wire [5:0] control_ExMem;
    wire [1:0] control_MemWb;
    forwarding_unit forward(
        .RegWrite_ExMem(control_ExMem[0]),
        .RegWrite_MemWb(control_MemWb[0]),
        .rd_address_ExMem(rd_address_ExMem),
        .rd_address_MemWb(rd_address_MemWb),
        .rs1_address(rs1_address_IdEx),
        .rs2_address(rs2_address_IdEx),
        .MemtoReg(MemtoReg),
        .select_alusrc1(select_alusrc1),
        .select_alusrc2(select_alusrc2)
    );
    //Pre_ALU_SRC Mux
    wire [63:0] alu_src1,alu_src2,read_data2_forwarded;
    genvar i;
    
    //ALUSRC_Mux 1 and 2
    generate
        for (i=0;i<64;i=i+1) begin:gen_alu_src1_mux
            mux4x1 alu_src1_mux (
                .out(alu_src1[i]),
                .sel0(select_alusrc1[0]),
                .sel1(select_alusrc1[1]),
                .in0(rs1_data_IdEx[i]),
                .in1(1'b1),
                .in2(alu_out_ExMem[i]),
                .in3(write_reg[i])
            );
        end
    endgenerate

    generate
        for (i=0;i<64;i=i+1) begin:gen_alu_src2_mux
            mux4x1 alu_src2_mux (
                .out(read_data2_forwarded[i]),
                .sel0(select_alusrc2[0]),
                .sel1(select_alusrc2[1]),
                .in0(rs2_data_IdEx[i]),
                .in1(1'b1),
                .in2(alu_out_ExMem[i]),
                .in3(write_reg[i])
            );
        end
    endgenerate

    generate
        for (i=0;i<64;i=i+1) begin:gen_mux_alu_src2
            mux2x1 MUX2 (.out(alu_src2[i]),.select(control_IdEx[7]),.in0(read_data2_forwarded[i]),.in1(immediate_IdEx[i]));
        end
    endgenerate

    wire [63:0] alu_result;
    wire zero,overflow;
    alu ALU (
        .alu_out(alu_result),
        .overflow(overflow),
        .zero(zero),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .alu_op(control_IdEx[6:5])
    );

    //PC Updation logic for branch
    wire [63:0] pc_ExMem,immediate_ExMem;
    wire temp3_unused, temp4_unused;
    adder PC_Adder2 (
        .S(pc_mux1),
        .c_out(temp3_unused),
        .overflow(temp4_unused),
        .A(pc_ExMem),
        .B(immediate_ExMem),
        .c_in(1'b0)
    );
    wire pc_mux_select0,pc_mux_selectnot;
    not (pc_mux_selectnot,pc_mux_select0);
    and (pc_mux_select0,control_ExMem[5],control_ExMem[4]);

    //PC INPUT SELECTION MUX
    generate
        for (i=0;i<64;i=i+1) begin:gen_pc_mux
            mux2x1 pc_mux (.out(pc_in[i]),.select(pc_mux_select0),.in0(pc_mux0[i]),.in1(pc_mux1[i]));
        end
    endgenerate

    //EX_MEM Register
    //Control_IdEx[5] is zero, 4 is branch
    wire[63:0] write_data_mem_ExMem,alu_out_ExMem;
     EX_MEM Ex_Mem_Reg (
        .clk(clk),
        .alu_src2_in(read_data2_forwarded),
        .rd_address_in(rd_address_IdEx),
        .alu_result_in(alu_result),
        .control_signal_in({zero,control_IdEx[4],control_IdEx[3:0]}),
        .alu_src2_out(write_data_mem_ExMem),
        .rd_address_out(rd_address_ExMem),
        .alu_result_out(alu_out_ExMem),
        .control_signal_out(control_ExMem),
        .immediate_in(immediate_IdEx),
        .immediate_out(immediate_ExMem),
        .pc_out(pc_ExMem),
        .pc_in(pc_IdEx)
    );

    //Data Memory Instantiation
    wire [63:0] data_mem;
    data_mem data_memory (
        .ReadData(data_mem),
        .Address(alu_out_ExMem),
        .WriteData(write_data_mem_ExMem),
        .MemWrite(control_ExMem[3]),
        .MemRead(control_ExMem[2]),
        .clk(clk)
    );

    //MemWb Register
    wire [63:0] alu_result_MemWb,mem_data_MemWb;
    MEM_WB MEM_WB_Reg (
        .clk(clk),
        .rd_address_in(rd_address_ExMem),
        .alu_result_in(alu_out_ExMem),
        .mem_data_in(data_mem),
        .control_signal_in(control_ExMem[1:0]),
        .rd_address_out(rd_address_MemWb),
        .alu_result_out(alu_result_MemWb),
        .mem_data_out(mem_data_MemWb),
        .control_signal_out(control_MemWb)
    );
    generate
        for (i=0;i<64;i=i+1) begin :gen_reg_write_mux
    mux2x1 reg_write_mux (
        .out(write_reg[i]),
        .select(control_MemWb[1]),
        .in0(alu_result_MemWb[i]),
        .in1(mem_data_MemWb[i])
    );
        end
    endgenerate

endmodule