`include "alu.vh"
`include "assembly.vh"

localparam L0_ = 16'h0C;

initial begin
    default_interrupt_vectors();

label(L0_);
    asm_srp('h10);
    asm_ld_r_IM(0, 9);
    asm_ld_r_IM(1, 1);

    asm_alu2_r_r(ALU2_ADD, 0, 1);
    asm_alu1(ALU1_DA, 8'hE0);
    asm_alu2_r_r(ALU2_SUB, 0, 1);
    asm_alu1(ALU1_DA, 8'hE0);


    asm_ld_r_IM(1, 9);

    asm_alu2_r_r(ALU2_ADD, 0, 1);
    asm_alu1(ALU1_DA, 8'h10);
    asm_alu2_r_r(ALU2_SUB, 0, 1);
    asm_alu1(ALU1_DA, 8'h10);


    asm_ld_r_IM(0, 'h15);
    asm_ld_r_IM(1, 'h87);

    asm_alu2_r_r(ALU2_ADD, 0, 1);
    asm_alu1(ALU1_DA, 8'h10);
    asm_alu2_r_r(ALU2_SUB, 0, 1);
    asm_alu1(ALU1_DA, 8'h10);


    asm_ld_r_IM(0, 'h00);
    asm_ld_r_IM(1, 'h01);

    asm_alu2_r_r(ALU2_SUB, 0, 1);
    asm_alu1(ALU1_DA, 8'h10);
    asm_alu2_r_r(ALU2_ADD, 0, 1);
    asm_alu1(ALU1_DA, 8'h10);

    asm_jp(JC_ALWAYS, L0_);
end
