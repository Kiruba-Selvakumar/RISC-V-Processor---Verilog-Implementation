module data_mem (ReadData, Address, WriteData, MemWrite, MemRead,clk);
    input[63:0] Address; 
    input clk;
    input [63:0] WriteData;
    input MemRead,MemWrite;
    output reg [63:0] ReadData;
    integer i;
    reg [7:0] M [0:1023];     //8 bit address implemented
    always@(clk)
    begin
        if ((MemWrite==1 || MemRead==1) && Address>1023) begin 
            $display("ERROR:Data Memory Address (%h) out of bounds at time %0t", Address,$time);
            $stop;
        end
        else begin
         if(MemRead) begin
            ReadData <={M[Address],M[Address+1],M[Address+2],M[Address+3],M[Address+4],M[Address+5],M[Address+6],M[Address+7]};
         end
        end
    end
    always @(negedge clk ) begin
        if(MemWrite) begin
            M[Address]<=WriteData[63:56];
            M[Address+1]<=WriteData[55:48];
            M[Address+2]<=WriteData[47:40];
            M[Address+3]<=WriteData[39:32];
            M[Address+4]<=WriteData[31:24];
            M[Address+5]<=WriteData[23:16];
            M[Address+6]<=WriteData[15:8]; 
            M[Address+7] <=WriteData[7:0];    
        end
        #1;
        $display("\nTime = %0t", $time);
        for (i = 0; i < 41; i = i + 1) begin
            $display("M[%0d]: %0d", i, M[i]);
        end
    end
    initial begin
    $readmemb ("preload_data_final.txt",M);
    end
endmodule

