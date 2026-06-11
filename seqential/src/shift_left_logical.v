//Shift Left Logic
module shift_left_logical(rd,rs1,rs2);
input[63:0] rs1,rs2;
output [63:0] rd;
wire[63:0] mux_out1;
wire[63:0] mux_out2;
wire[63:0] mux_out3;
wire[63:0] mux_out4;
wire[63:0] mux_out5;
genvar i;
generate
    for (i=1;i<64;i=i+1) begin: gen_mux_1
    mux2x1 m1(mux_out1[i],rs2[0],rs1[i],rs1[i-1]);
    end
endgenerate
mux2x1 t1(mux_out1[0],rs2[0],rs1[0],1'b0);

//second mux array
generate
    for (i=2;i<64;i=i+1) begin: gen_mux_2
    mux2x1 m2(mux_out2[i],rs2[1],mux_out1[i],mux_out1[i-2]);
    end
endgenerate

generate
    for (i=0;i<2;i=i+1) begin: gen_mux_2_b
    mux2x1 t2(mux_out2[i],rs2[1],mux_out1[i],1'b0);
    end
endgenerate

//third mux array
generate
    for (i=4;i<64;i=i+1) begin: gen_mux_3
    mux2x1 m3(mux_out3[i],rs2[2],mux_out2[i],mux_out2[i-4]);
    end
endgenerate

generate
    for (i=0;i<4;i=i+1) begin: gen_mux_3_b
    mux2x1 t3(mux_out3[i],rs2[2],mux_out2[i],1'b0);
    end
endgenerate

//fourth mux array
generate
    for (i=8;i<64;i=i+1) begin: gen_mux_4
    mux2x1 m4(mux_out4[i],rs2[3],mux_out3[i],mux_out3[i-8]);
    end
endgenerate

generate
    for(i=0;i<8;i=i+1) begin: gen_mux_4_b
    mux2x1 t4(mux_out4[i],rs2[3],mux_out3[i],1'b0);
    end
endgenerate

//fifth mux array
generate
    for(i=16;i<64;i=i+1) begin: gen_mux_5
    mux2x1 m5(mux_out5[i],rs2[4],mux_out4[i],mux_out4[i-16]);
    end
endgenerate

generate
    for(i=0;i<16;i=i+1) begin: gen_mux_5_b
    mux2x1 t5(mux_out5[i],rs2[4],mux_out4[i],1'b0);
    end
endgenerate

//sixth mux array
generate
    for (i=32;i<64;i=i+1) begin: gen_mux_6
    mux2x1 m6(rd[i],rs2[5],mux_out5[i],mux_out5[i-32]);
    end
endgenerate

generate
    for (i=0;i<32;i=i+1) begin: gen_mux_6_b
    mux2x1 t6(rd[i],rs2[5],mux_out5[i],1'b0);
    end
endgenerate

endmodule