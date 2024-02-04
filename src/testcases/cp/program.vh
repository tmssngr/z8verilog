localparam BOOT = 16'h000C;

initial begin
    default_interrupt_vectors();

label(BOOT);
    asm_srp('h20);
    asm_ld_r_IM(0, 9);
    asm_ld_r_IM(1, 1);
    asm_ld_r_IM(2, 'h20);
    asm_alu2_r_Ir(ALU2_CP, 0, 2);

    asm_ld_r_IM(2, 'h21);
    asm_alu2_r_Ir(ALU2_CP, 0, 2);

    asm_jp(JC_ALWAYS, BOOT);
end
