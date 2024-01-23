localparam L0_ = 16'h0C;
localparam L1_ = 16'h11;
initial begin
      default_interrupt_vectors();

    label(L0_);
      asm_jp(JC_NEVER, 16'hFFFE); // 0D FF FE

      asm_ld_r_IM(0, 3);

    label(L1_);
      asm_add_R_IM(0, 8'hFF);
      asm_jp(JC_NZ, L1_);

      asm_jp(JC_ALWAYS, L0_);
end
