`timescale 1ns/1ps

module fib_tb;

    reg clk;
    reg reset;

    // Instantiate CPU
    single_cycle CPU (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    integer cycle;

    initial begin
        clk = 0;
        reset = 1;
        cycle = 0;

        // Load program and release reset
        #20 reset = 0;

        // Run for 400 cycles
        repeat (100) begin
            @(posedge clk);
            cycle = cycle + 1;
            $display("Cycle %0d | t0=%d t1=%d t2=%d t3=%d",
                cycle,
                CPU.RF.regfile[8],   // $t0
                CPU.RF.regfile[9],   // $t1
                CPU.RF.regfile[10],  // $t2
                CPU.RF.regfile[11]   // $t3
            );
        end

        // Print results from data memory
        $display("\n===== Fibonacci Results in Data Memory =====");

        $display("mem[0] = %d",  CPU.DM.mem[0]);
        $display("mem[1] = %d",  CPU.DM.mem[1]);
        $display("mem[2] = %d",  CPU.DM.mem[2]);
        $display("mem[3] = %d",  CPU.DM.mem[3]);
        $display("mem[4] = %d",  CPU.DM.mem[4]);
        $display("mem[5] = %d",  CPU.DM.mem[5]);
        $display("mem[6] = %d",  CPU.DM.mem[6]);
        $display("mem[7] = %d",  CPU.DM.mem[7]);
        $display("mem[8] = %d",  CPU.DM.mem[8]);
        $display("mem[9] = %d",  CPU.DM.mem[9]);

        $finish;
    end

endmodule
