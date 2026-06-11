module IF_ID(
    input clk,
    input ins_flush,
    input write_enable,
    input wire [31:0] instruction,
    input wire [63:0] pc,
    output reg [31:0] instruction_out,
    output reg [63:0] pc_out
);
    initial begin
        instruction_out <= 0;
        pc_out <= 0;
    end

   always @(posedge clk, posedge ins_flush) begin
        if (ins_flush) begin
            instruction_out <= 0;
            pc_out <= 0;
        end
        else if (write_enable) begin
            instruction_out <= instruction;
            pc_out <= pc;
        end
    end
endmodule

module ID_EX(
    input clk,
    input [4:0] rs1_address_in,
    input [4:0] rs2_address_in,
    input [4:0] rd_address_in,
    input [63:0] rs1_data_in,
    input [63:0] rs2_data_in,
    input [7:0] control_signal_in,
    input [63:0]immediate_in,
    input [63:0]pc_in,
    output reg[4:0] rs1_address_out,
    output reg[4:0] rs2_address_out,
    output reg[4:0] rd_address_out,
    output reg[63:0] rs1_data_out,
    output reg[63:0] rs2_data_out,
    output reg[7:0] control_signal_out,
    output reg[63:0] immediate_out,
    output reg[63:0] pc_out,
    input con_flush
);
    initial begin
        rs1_address_out <= 5'd0;
        rs2_address_out <= 5'd0;
        rd_address_out <= 5'd0;
        rs1_data_out <= 64'd0;
        rs2_data_out <= 64'd0;
        control_signal_out <= 8'd0;
        immediate_out <= 64'd0;
        pc_out <= 64'd0;
    end
    always @(posedge clk, posedge con_flush) begin
        rs1_address_out <= rs1_address_in;
        //This is done to avoid wrong forwarding case in the case of immediate being present instead of rs2
        rs2_address_out <= rs2_address_in;
        rd_address_out <= rd_address_in;
        rs1_data_out <= rs1_data_in;
        rs2_data_out <= rs2_data_in;
        if (con_flush) begin
            control_signal_out <= 8'd0;
        end
        else begin
        control_signal_out <= control_signal_in;
        end
        immediate_out <= immediate_in;
        pc_out <= pc_in;
    end
endmodule

module EX_MEM (
    input clk,
    input [63:0]alu_src2_in,
    input [4:0]rd_address_in,
    input [63:0]alu_result_in,
    input [5:0]control_signal_in,
    input [63:0] immediate_in,
    output reg[63:0]alu_src2_out,
    output reg[4:0]rd_address_out,
    output reg[63:0]alu_result_out,
    output reg[5:0]control_signal_out,
    output reg[63:0] immediate_out,
    input [63:0] pc_in,
    output reg [63:0] pc_out
);
initial begin
    alu_src2_out <= 64'd0;
    rd_address_out <= 5'd0;
    alu_result_out <= 64'd0;
    control_signal_out <= 4'd0;
end
    always @(posedge clk) begin
        alu_src2_out <= alu_src2_in;
        rd_address_out <= rd_address_in;
        alu_result_out <= alu_result_in;
        control_signal_out <= control_signal_in;
        immediate_out <= immediate_in;
        pc_out <= pc_in;
    end
endmodule

module MEM_WB (
    input clk,
    input[4:0] rd_address_in,
    input[63:0] alu_result_in,
    input[63:0] mem_data_in,
    input[1:0] control_signal_in,
    output reg[4:0] rd_address_out,
    output reg[63:0]alu_result_out,
    output reg[63:0]mem_data_out,
    output reg[1:0]control_signal_out    
);
initial begin
    rd_address_out <= 5'd0;
    alu_result_out <= 64'd0;
    mem_data_out <= 64'd0;
    control_signal_out <= 2'd0;
end
    always @(posedge clk) begin
        rd_address_out <= rd_address_in;
        alu_result_out <= alu_result_in;
        mem_data_out <= mem_data_in;
        control_signal_out <= control_signal_in;
    end
endmodule