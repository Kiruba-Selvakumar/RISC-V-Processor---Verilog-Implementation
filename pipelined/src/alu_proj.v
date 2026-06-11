`include "mux.v"
// **********ADDER BEGIN*******************
module mpfa (a,b,c,p,g,s);
    input a,b,c;
    output p,g,s;
    xor x1(p,a,b);
    xor x2(s,p,c);
    nand n1(g,a,b);
endmodule
module cla_4bit (A_in,B_in,c_0,S_out,c_out,overflow);
input [3:0] A_in,B_in;
input c_0;
output [3:0] S_out;
output c_out,overflow;
wire [3:0] A,B,S;
wire p0,g0,s0,p1,g1,s1,p2,g2,s2,p3,g3,s3,c1,c4,c2,g0_bar,g1_bar,g2_bar,g3_bar;
// MPFA
mpfa m0(A_in[0],B_in[0],c_0,p0,g0_bar,S_out[0]);
mpfa m1(A_in[1],B_in[1],c1,p1,g1_bar,S_out[1]);
mpfa m2(A_in[2],B_in[2],c2,p2,g2_bar,S_out[2]);
mpfa m3(A_in[3],B_in[3],overflow,p3,g3_bar,S_out[3]);

not n0(g0,g0_bar),
    n1(g1,g1_bar),
    n2(g2,g2_bar);

//Generating C1
nand c1_n1 (c1_temp1, p0,c_0),
     c1_n2 (c1, g0_bar,c1_temp1);   

//Generating C2
nand c2_n1 (c2_temp1, p1,g0),
     c2_n2 (c2_temp2, p1,p0,c_0),
     c2_n3 (c2, g1_bar,c2_temp1,c2_temp2);

//Generating C3
nand c3_n1 (c3_temp1, p2,g1),
     c3_n2 (c3_temp2, p2,p1,g0),
     c3_n3 (c3_temp3, p2,p1,p0,c_0),
     c3_n4 (overflow, g2_bar,c3_temp1,c3_temp2,c3_temp3);

//Generating C4
and  c4_a1 (P,p3,p2,p1,p0);
nand c4_n1 (c4_temp1, p3,g2),
     c4_n2 (c4_temp2, p3,p2,g1),
     c4_n3 (c4_temp3, p3,p2,p1,g0);
and c4_a2 (G_bar,g3_bar,c4_temp1,c4_temp2,c4_temp3);

nand c4_n4 (c4_temp4, P,c_0),
     c4_n5 (c_out, G_bar,c4_temp4);
endmodule
module cla_16bit (A,B,c_in,S,c_out,overflow);
input [15:0] A,B;
input c_in;
output [15:0] S;
output c_out,overflow;
wire temp_carry1,temp_carry2,temp_carry3,ov1,ov2,ov3;
cla_4bit adder0(.A_in(A[3:0]),.B_in(B[3:0]),.c_0(c_in),.S_out(S[3:0]),.c_out(temp_carry1),.overflow(ov1));
cla_4bit adder1(.A_in(A[7:4]),.B_in(B[7:4]),.c_0(temp_carry1),.S_out(S[7:4]),.c_out(temp_carry2),.overflow(ov2));
cla_4bit adder2(.A_in(A[11:8]),.B_in(B[11:8]),.c_0(temp_carry2),.S_out(S[11:8]),.c_out(temp_carry3),.overflow(ov3));
cla_4bit adder3(.A_in(A[15:12]),.B_in(B[15:12]),.c_0(temp_carry3),.S_out(S[15:12]),.c_out(c_out),.overflow(overflow));
endmodule
module adder (S,c_out,overflow,A,B,c_in);
input [63:0] A,B;
input c_in;
output [63:0] S;
output c_out,overflow;
wire temp_carry1,temp_carry2,temp_carry3,ov1,ov2,ov3,ov4;
cla_16bit adder0(.A(A[15:0]),.B(B[15:0]),.c_in(c_in),.S(S[15:0]),.c_out(temp_carry1),.overflow(ov1));
cla_16bit adder1(.A(A[31:16]),.B(B[31:16]),.c_in(temp_carry1),.S(S[31:16]),.c_out(temp_carry2),.overflow(ov2));
cla_16bit adder2(.A(A[47:32]),.B(B[47:32]),.c_in(temp_carry2),.S(S[47:32]),.c_out(temp_carry3),.overflow(ov3));
cla_16bit adder3(.A(A[63:48]),.B(B[63:48]),.c_in(temp_carry3),.S(S[63:48]),.c_out(c_out),.overflow(ov4));
xor x1(overflow,c_out,ov4);
endmodule
// ***************ADDER END*************************
module and_function(rd,rs1,rs2);
    input [63:0] rs1,rs2;
    output [63:0] rd;
    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin:and_gen
        and (rd[i],rs1[i],rs2[i]);
        end
    endgenerate
endmodule

module or_function (rd,rs1,rs2);
    input [63:0] rs1,rs2;
    output [63:0] rd;
    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin:or_gen
        or (rd[i],rs1[i],rs2[i]);
        end
    endgenerate
endmodule

//********************************SUB START******************************** 
module compliment2(out,in);
    input[63:0] in;
    output[63:0] out;
    genvar i;
    wire[63:0] int_not;
    wire[63:0] int_one;
    assign int_one = 64'b1;
    generate
        for(i=0;i<64;i=i+1) begin:not_gen
        not (int_not[i],in[i]);
        end
    endgenerate
    wire temp1,temp2;
    adder one_adder(out,temp1,temp2,int_not,int_one,1'b0);
endmodule

module subtractor(rd,overflow,zero_check_not,rs1,rs2);
    input[63:0] rs1,rs2;
    output[63:0] rd;
    output overflow,zero_check_not;
    wire overflow_temp;
    wire[63:0] rs2_comp;
    wire c_out,rs2_msb_not,zero_check;
    not (rs2_msb_not,rs2[63]);
    zero_det_64bit z0 (zero_check,{rs2_msb_not,rs2[62:0]}); //Zero check is 1 if value is not zero
    compliment2 comp(.out(rs2_comp),.in(rs2));
    not (zero_check_not,zero_check);
    adder sub_adder(rd,c_out,overflow_temp,rs1,rs2_comp,1'b0);
    or (overflow,overflow_temp,zero_check_not);
endmodule
// ********************************SUB END********************************

// *********************************Zero Check Start*************************
module zero_det_4bit(out, in);
    input [3:0] in;
    output out;
    or o1(out,in[0],in[1],in[2],in[3]);
endmodule
module zero_det_16bit (out,in);
    input [15:0] in;
    output out;
    wire[3:0] temp;
    zero_det_4bit z1(temp[0],in[3:0]);
    zero_det_4bit z2(temp[1],in[7:4]);
    zero_det_4bit z3(temp[2],in[11:8]);
    zero_det_4bit z4(temp[3],in[15:12]);
    or o1(out,temp[0],temp[1],temp[2],temp[3]);
endmodule

module zero_det_64bit (out,in);
    input[63:0] in;
    output out;
    wire[3:0] temp;
    zero_det_16bit z1(temp[0],in[15:0]);
    zero_det_16bit z2(temp[1],in[31:16]);
    zero_det_16bit z3(temp[2],in[47:32]);
    zero_det_16bit z4(temp[3],in[63:48]);
    or o1(out,temp[0],temp[1],temp[2],temp[3]);
endmodule
// *********************************Zero Check END*************************
module alu (alu_out,overflow,zero,alu_src1,alu_src2,alu_op);
    input [63:0] alu_src1,alu_src2;
    input [1:0] alu_op;
    output [63:0] alu_out;
    output overflow,overflow_add,overflow_sub,zero,temp; //Temp is a temporary wire to store zero out of subtractor
    wire [63:0] add_00,sub_01,or_10,and_11;
    wire temp_unused;
    adder ad1(add_00,temp_unused,overflow_add,alu_src1,alu_src2,1'b0);
    subtractor s1(sub_01,overflow_sub,temp,alu_src1,alu_src2);
    or_function o1(or_10,alu_src1,alu_src2);
    and_function a1(and_11,alu_src1,alu_src2);
    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin:gen_mux1
        mux4x1 mux1(alu_out[i],alu_op[0],alu_op[1],add_00[i],sub_01[i],or_10[i],and_11[i]);
        end
    endgenerate
    mux2x1 mux1(overflow,alu_op[0],overflow_add,overflow_sub);
    zero_det_64bit z0 (zero_not,alu_out); //Zero_not is 1 if the value of alu_out is not zero
    not n1(zero,zero_not);
endmodule