localparam L0_ = 16'h0C;
initial begin
      default_interrupt_vectors();
    label(L0_);
      asm_ld_R_IM(8'h10, 1);
      asm_ld_R_IM(8'h11, 2);
      asm_incw(8'h10);
      asm_decw(8'h10);

      asm_ld_R_IM(8'h11, 8'h7F);
      asm_incw(8'h10);
      asm_decw(8'h10);

      asm_ld_R_IM(8'h11, 8'hFF);
      asm_incw(8'h10);
      asm_decw(8'h10);

      asm_ld_R_IM(8'h10, 8'hFF);
      asm_incw(8'h10);
      asm_incw(8'h10);
      asm_decw(8'h10);
      asm_decw(8'h10);

      asm_jp(JC_ALWAYS, L0_);
end
