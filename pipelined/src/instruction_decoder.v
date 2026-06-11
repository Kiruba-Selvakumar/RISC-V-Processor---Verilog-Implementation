module inst_decoder (MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite,Branch,MemRead,instruction);
input wire[31:0] instruction;
output wire MemtoReg,MemWrite,ALUSrc,RegWrite,Branch,MemRead;
output wire[1:0] ALUOp;
wire in6_not,in5_not,in4_not;
not in6 (in6_not,instruction[6]),
    in5 (in5_not,instruction[5]),
    in4 (in4_not,instruction[4]);

wire temp1_RegWrite;
and r1 (temp1_RegWrite,in6_not,instruction[5],instruction[4]),
    r2 (ALUOp[1],in6_not,instruction[5],instruction[4]);

wire temp1_ALUSrc, temp2_RegWrite;
and l1 (temp1_ALUSrc,in6_not,in5_not,in4_not),
    l2 (temp2_RegWrite,in6_not,in5_not,in4_not,instruction[0]),
    l3 (MemtoReg,in6_not,in5_not,in4_not,instruction[0]),
    l4 (MemRead,in6_not,in5_not,in4_not,instruction[0]);

wire temp2_ALUSrc;
and s1 (temp2_ALUSrc,in6_not,instruction[5],in4_not),
    s2 (MemWrite,in6_not,instruction[5],in4_not);

and b1 (Branch,instruction[6],instruction[5],in4_not),
    b2 (ALUOp[0],instruction[6],instruction[5],in4_not);

or o1 (RegWrite,temp1_RegWrite,temp2_RegWrite),
    o2 (ALUSrc,temp1_ALUSrc,temp2_ALUSrc);
endmodule