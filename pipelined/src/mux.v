module mux2x1 (out,select,in0,in1);
    output out;
    input select,in0,in1;
    wire select_bar;
    not n1(select_bar,select);
    wire temp1,temp2;
    and (temp1,select_bar,in0);
    and (temp2,select,in1);
    or (out,temp1,temp2);
endmodule

module mux4x1(out,sel0,sel1,in0,in1,in2,in3);
    output out;
    input sel0,sel1,in0,in1,in2,in3;
    wire t1,t2;
    mux2x1 M1(t1,sel0,in0,in1);
    mux2x1 M2(t2,sel0,in2,in3);
    mux2x1 M3(out,sel1,t1,t2);
endmodule

module mux8x1(out,sel0,sel1,sel2,i0,i1,i2,i3,i4,i5,i6,i7);
    output out;
    input sel0,sel1,sel2,i0,i1,i2,i3,i4,i5,i6,i7;
    wire t1,t2;
    mux4x1 M1(t1,sel0,sel1,i0,i1,i2,i3),
          M2 (t2,sel0,sel1,i4,i5,i6,i7);
    mux2x1 M3 (out,sel2,t1,t2);
endmodule