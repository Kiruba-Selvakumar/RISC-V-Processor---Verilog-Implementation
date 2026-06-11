`include"processor.v"
module processor_tb();
    reg clk;
    
    // Instantiate the processor
    processor uut (.clk(clk));

    // Clock generation
    initial begin
        clk = 0;
        forever #3 clk = ~clk; 
    end

    // Initializing memory and registers
    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0, processor_tb);
        #100;
    
        
        $finish;
    end

endmodule
