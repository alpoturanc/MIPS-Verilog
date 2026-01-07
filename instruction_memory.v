module instruction_memory (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem[0:255];

    initial begin
        $display("Trying to load imem.txt...");
        $readmemh("imem.txt", mem);
        $display("IMEM[0] = %h", mem[0]);
        $display("IMEM[1] = %h", mem[1]);
        $display("IMEM[2] = %h", mem[2]);
        $display("IMEM[3] = %h", mem[3]);
    end

    assign instr = mem[addr[9:2]];
endmodule
