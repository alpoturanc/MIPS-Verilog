module registers (
    input         clk,
    input         reg_write,
    input  [4:0]  read_reg1,
    input  [4:0]  read_reg2,
    input  [4:0]  write_reg,
    input  [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);

    // 32 general-purpose registers
    reg [31:0] regfile[31:0];

    integer i;

    // Initialize all registers to 0 for simulation
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regfile[i] = 32'b0;
    end

    // Register write logic (cannot write to $zero)
    always @(posedge clk) begin
        regfile[0] <= 32'b0;   // $zero must always stay 0

        if (reg_write && write_reg != 5'd0)
            regfile[write_reg] <= write_data;
    end

    // Read ports
    assign read_data1 = regfile[read_reg1];
    assign read_data2 = regfile[read_reg2];

endmodule
