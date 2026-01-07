module alu_control (
    input  [1:0] alu_op,
    input  [5:0] funct,
    output reg [3:0] alu_ctl
);
    // alu_op encoding:
    // 00: ADD  (LW, SW, ADDI)
    // 01: SUB  (BEQ, BNE)
    // 10: R-type (use funct field)

    always @(*) begin
        case (alu_op)
            2'b00: alu_ctl = 4'b0010;  // ADD
            2'b01: alu_ctl = 4'b0110;  // SUB
            2'b10: begin               // R-type: use funct
                case (funct)
                    6'b100000: alu_ctl = 4'b0010; // ADD
                    6'b100010: alu_ctl = 4'b0110; // SUB
                    6'b100100: alu_ctl = 4'b0000; // AND
                    6'b100101: alu_ctl = 4'b0001; // OR
                    6'b101010: alu_ctl = 4'b0111; // SLT
                    6'b000000: alu_ctl = 4'b1000; // SLL
                    6'b000010: alu_ctl = 4'b1001; // SRL
                    6'b001000: alu_ctl = 4'b0010; // JR 
                    default:   alu_ctl = 4'b0000;
                endcase
            end
            default: alu_ctl = 4'b0000;
        endcase
    end
endmodule
