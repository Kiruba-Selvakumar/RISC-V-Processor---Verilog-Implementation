module hazard_detection_unit (
    input MemRead_Id_Ex,
    input [4:0]rd_address_IdEx,
    input [6:0]opcode_IfId,
    input [4:0]rs1_address_IfId,
    input [4:0]rs2_address_IfId,
    output reg pc_write,
    output reg If_ID_write,
    output reg control_mux_select
);
always @(*) begin
    if (MemRead_Id_Ex) begin
            if (rs1_address_IfId == rd_address_IdEx || rs2_address_IfId == rd_address_IdEx) begin
                pc_write = 0;
                If_ID_write = 0;
                control_mux_select = 0;
            end
            else begin
                pc_write = 1;
                If_ID_write = 1;
                control_mux_select = 1;
            end
        // else begin
        //     if (rs1_address_IfId == rd_address_IdEx) begin
        //         pc_write = 0;
        //         If_ID_write = 0;
        //         control_mux_select = 0;
        //     end
        //     else begin
        //         pc_write = 1;
        //         If_ID_write = 1;
        //         control_mux_select = 1;
        //     end
        // end
    end
    // else if (branch) begin
    //     If_ID_write<=0;
    //     flush<=1;
    // end
    else begin
        pc_write = 1;
        If_ID_write = 1;
        control_mux_select = 1;
    end
end
endmodule