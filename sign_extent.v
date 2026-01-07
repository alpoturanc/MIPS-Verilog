module sign_extend (
    input  [15:0] imm,
    output [31:0] imm_ext
);
    // Sign extend 16-bit immediate to 32-bit
    assign imm_ext = {{16{imm[15]}}, imm};
endmodule
