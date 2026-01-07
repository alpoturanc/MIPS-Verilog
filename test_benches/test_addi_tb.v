`timescale 1ns/1ps

module test_addi_tb;

    reg clk;
    reg reset;

    // Instantiate CPU
    single_cycle CPU (
        .clk(clk),
        .reset(reset)
    );

    // Clock with 10ns period
    always #5 clk = ~clk;

    integer cycle;

    initial begin
        clk = 0;
        reset = 1;
        cycle = 0;

        // Release reset
        #20 reset = 0;

        // Run 20 cycles
        repeat (20) begin
            @(posedge clk);
            cycle = cycle + 1;

            $display("Cycle %0d | t0=%d  t1=%d  t2=%d",
                cycle,
                CPU.RF.regfile[8],   // $t0
                CPU.RF.regfile[9],   // $t1
                CPU.RF.regfile[10]   // $t2
            );
        end

        $finish;
    end

endmodule
