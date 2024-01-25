localparam L0_ = 16'h0C;
initial begin
      default_interrupt_vectors();

    label(L0_);
      asm_scf(); // DF
      asm_rcf(); // CF
      asm_ccf(); // EF
      asm_ccf(); // EF

      asm_jp(JC_ALWAYS, L0_);  // 8D 00 0C
end
