`timescale 1ns/1ps

module test_sw_tb;

    reg clk;
    reg reset;
    integer i;

    // Instantiate CPU
    single_cycle CPU (
        .clk(clk),
        .reset(reset)
    );

    // 10 ns clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #20 reset = 0;

        // Run for 10 cycles
        repeat (10) @(posedge clk);

        // Print memory word indices 0..10
        $display("===== DATA MEMORY DUMP =====");
        for (i = 0; i < 10; i = i + 1) begin
            $display("mem[%0d] = %0d", i, CPU.DM.mem[i]);
        end

        $finish;
    end

endmodule
