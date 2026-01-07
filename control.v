module control (
    input  [5:0] opcode,
    output reg       reg_dst,
    output reg       alu_src,
    output reg       mem_to_reg,
    output reg       reg_write,
    output reg       mem_read,
    output reg       mem_write,
    output reg       branch,        // generic "branch" enable
    output reg       branch_ne,     // 0 = BEQ, 1 = BNE (if branch = 1)
    output reg       jump,          // J / JAL
    output reg       jal,           // JAL specific
    output reg [1:0] alu_op
);
    // opcode values (MIPS):
    // 000000: R-type
    // 100011: LW
    // 101011: SW
    // 000100: BEQ
    // 000101: BNE
    // 001000: ADDI
    // 000010: J
    // 000011: JAL

    always @(*) begin
        reg_dst    = 0;
        alu_src    = 0;
        mem_to_reg = 0;
        reg_write  = 0;
        mem_read   = 0;
        mem_write  = 0;
        branch     = 0;
        branch_ne  = 0;
        jump       = 0;
        jal        = 0;
        alu_op     = 2'b00;

        case (opcode)

            6'b000000: begin
                // R-type (ADD, SUB, AND, OR, SLT, SLL, SRL, JR)
                reg_dst    = 1;
                reg_write  = 1;
                alu_op     = 2'b10;
                // JR will be detected separately in the top-level and will override reg_write if needed.
            end

            6'b100011: begin
                // LW
                alu_src    = 1;
                mem_to_reg = 1;
                reg_write  = 1;
                mem_read   = 1;
                alu_op     = 2'b00;
            end

            6'b101011: begin
                // SW
                alu_src    = 1;
                mem_write  = 1;
                alu_op     = 2'b00;
            end

            6'b000100: begin
                // BEQ
                branch     = 1;
                branch_ne  = 0;    
                alu_op     = 2'b01;
            end

            6'b000101: begin
                // BNE
                branch     = 1;
                branch_ne  = 1;    
                alu_op     = 2'b01;
            end

            6'b001000: begin
                // ADDI
                alu_src    = 1;
                reg_write  = 1;
                alu_op     = 2'b00;
            end

            6'b000010: begin
                // J
                jump = 1;
            end

            6'b000011: begin
                // JAL
                jump      = 1;
                jal       = 1;
                reg_write = 1; // write to $ra (will be forced in top-level)
            end

        endcase
    end
endmodule
