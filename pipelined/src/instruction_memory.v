module instruction_mem (ReadData,Address);
    input[63:0] Address;
    output reg [31:0] ReadData;
    reg [7:0]IMem [0:255];
    always@(*)
    begin
        if (Address>255) begin 
            $display("ERROR: Instruction Memory Address out of bounds at time %0t value of address = %0d",$time, Address);
            $stop;
        end
        else begin
        ReadData={IMem[Address],IMem[Address+1],IMem[Address+2],IMem[Address+3]};
        end
    end
    initial begin
    $readmemb ("instructions_final_test.txt",IMem);
    end
endmodule

