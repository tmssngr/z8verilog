localparam L0_ = 16'h000C;

initial begin
    default_interrupt_vectors();

label(L0_);
    asm_srp('h20);
    asm_ld_r_IM(0, 9);
    asm_ld_r_IM(1, 1);
    asm_alu2_r_r(ALU2_ADD, 0, 1);

    asm_ld_r_IM(1, 6);
    asm_alu2_r_r(ALU2_ADD, 0, 1);

    asm_ld_r_IM(1, 'h80);
    asm_alu2_r_r(ALU2_ADD, 0, 1);

    asm_ld_r_IM(1, 'h70);
    asm_alu2_R_R(ALU2_ADD, 'hE0, 'hE1);

    asm_ld_r_IM(0, -1);
    asm_ld_r_IM(1, -1);
    asm_alu2_r_r(ALU2_ADD, 1, 0);

    asm_ld_r_IM(0, 45);
    asm_ld_r_IM(1, 56);
    asm_ld_r_IM(2, 8'h20);
    asm_alu2_R_IR(ALU2_SUB, 8'hE1, 8'hE2);

    asm_jp(JC_ALWAYS, L0_);
end
