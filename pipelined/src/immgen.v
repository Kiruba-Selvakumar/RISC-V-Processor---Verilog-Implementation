module immgen(
    input [31:0] instr,
    output [63:0] imm
);

// logic for instruction detection using opcode
    // I 0000011
    // S 0100011
    // SB 1100011

    mux4x1 m1 (
        .out(imm[0]),
        .sel0(instr[5]), 
        .sel1(instr[6]),
        .in0(instr[20]),
        .in1(instr[7]),
        .in2(1'b1), // don't care
        .in3(1'b0)
    );

    genvar i;
    generate
        for (i = 1; i <= 4; i=i+1) begin : loop_1
            mux2x1 module2(
                .out(imm[i]),
                .select(instr[5]),
                .in0(instr[20+i]),
                .in1(instr[7+i])
            );
        end
    endgenerate

    assign imm[10:5] = instr[30:25];

    mux2x1 module3(
        .out(imm[11]),
        .select(instr[6]),
        .in0(instr[31]),
        .in1(instr[7])
    );

    assign imm[12] = instr[31];

    generate
        for (i = 13; i <= 63; i=i+1) begin : loop_2
            assign imm[i] = imm[12];
        end
    endgenerate

endmodule