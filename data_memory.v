module data_memory (
    input         clk,
    input         mem_write,
    input         mem_read,
    input  [31:0] addr,
    input  [31:0] write_data,
    output [31:0] read_data
);

    reg [31:0] mem [0:255];

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;
    end

    wire [7:0] word_index = addr[9:2];

    always @(posedge clk) begin
        if (mem_write) begin
            $display("STORE: time=%0t  addr=%0d  idx=%0d  data=%0d",
                     $time, addr, word_index, write_data);

            mem[word_index] <= write_data;
        end
    end

    assign read_data = mem_read ? mem[word_index] : 32'b0;

endmodule
