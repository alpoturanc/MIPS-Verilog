module single_cycle (
    input clk,
    input reset
);
    // =============================================
    // PC AND INSTRUCTION FETCH
    // =============================================
    wire [31:0] pc, next_pc, instr;

    program_counter PC (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    instruction_memory IM (
        .addr(pc),
        .instr(instr)
    );

    // INSTRUCTION FIELDS
    wire [5:0] opcode = instr[31:26];
    wire [4:0] rs     = instr[25:21];
    wire [4:0] rt     = instr[20:16];
    wire [4:0] rd     = instr[15:11];
    wire [4:0] shamt  = instr[10:6];
    wire [5:0] funct  = instr[5:0];
    wire [15:0] imm   = instr[15:0];
    wire [25:0] jaddr = instr[25:0];

    // =============================================
    // MAIN CONTROL UNIT
    // =============================================
    wire reg_dst, alu_src, mem_to_reg, reg_write;
    wire mem_read, mem_write, branch, branch_ne, jump, jal;
    wire [1:0] alu_op;

    control CU (
        .opcode(opcode),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .branch_ne(branch_ne),
        .jump(jump),
        .jal(jal),
        .alu_op(alu_op)
    );

    // Detect JR in top-level for highest priority control
    wire jr = (opcode == 6'b000000 && funct == 6'b001000);

    // =============================================
    // REGISTER FILE
    // =============================================
    // First choose between rt/rd (RegDst),
    // then override with $ra (31) if JAL is used.
    wire [4:0] write_reg_pre = reg_dst ? rd : rt;
    wire [4:0] write_reg     = jal ? 5'd31 : write_reg_pre;

    wire [31:0] reg_data1, reg_data2;
    wire [31:0] write_data;

    // Disable register write when JR is executed (JR does not write a register).
    wire reg_write_final = reg_write & ~jr;

    registers RF (
        .clk(clk),
        .reg_write(reg_write_final),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    // =============================================
    // SIGN EXTEND
    // =============================================
    wire [31:0] imm_ext;

    sign_extend SE (
        .imm(imm),
        .imm_ext(imm_ext)
    );

    // =============================================
    // ALU CONTROL + ALU
    // =============================================
    wire [3:0] alu_ctl;
    wire [31:0] alu_in2, alu_result;
    wire zero;

    alu_control ALUCTL (
        .alu_op(alu_op),
        .funct(funct),
        .alu_ctl(alu_ctl)
    );

    // ALUSrc selects between register file and immediate.
    assign alu_in2 = alu_src ? imm_ext : reg_data2;

    alu ALU (
        .a(reg_data1),
        .b(alu_in2),
        .shamt(shamt),
        .alu_control(alu_ctl),
        .result(alu_result),
        .zero(zero)
    );

    // =============================================
    // DATA MEMORY
    // =============================================
    wire [31:0] read_data;

    data_memory DM (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .addr(alu_result),
        .write_data(reg_data2),
        .read_data(read_data)
    );

    // Write-back selection:
    //  - if MemToReg = 1 => from Data Memory
    //  - else            => from ALU
    //  - if JAL         => PC + 4 (return address)
    wire [31:0] alu_or_mem = mem_to_reg ? read_data : alu_result;

    // PC + 4 is the standard next sequential address.
    wire [31:0] pc_plus_4 = pc + 4;

    assign write_data = jal ? pc_plus_4 : alu_or_mem;

    // =============================================
    // BRANCH AND JUMP LOGIC
    // =============================================
    // Branch target = PC + 4 + (imm_ext << 2)
    wire [31:0] branch_target = pc_plus_4 + (imm_ext << 2);

    // For BEQ: branch if zero == 1
    // For BNE: branch if zero == 0
    wire take_branch = branch & (branch_ne ? ~zero : zero);

    wire [31:0] pc_after_branch = take_branch ? branch_target : pc_plus_4;

    // Jump target: {PC+4[31:28], jaddr, 2'b00}
    wire [31:0] pc_jump = { pc_plus_4[31:28], jaddr, 2'b00 };

    wire [31:0] pc_after_jump = jump ? pc_jump : pc_after_branch;

    // JR has highest priority: PC = value in rs (reg_data1).
    assign next_pc = jr ? reg_data1 : pc_after_jump;

endmodule
