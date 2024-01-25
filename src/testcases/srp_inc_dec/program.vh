localparam L0_ = 16'h0C;
initial begin
      default_interrupt_vectors();

    label(L0_);
      asm_srp('h10);
      asm_ld_r_IM(0, 9);
      asm_inc_r(4'h0);
      asm_dec('h10);

      asm_ld_r_IM(0, 8'h7F);
      asm_inc('h10);
      asm_dec('h10);

      asm_ld_r_IM(0, 8'hFE);
      asm_inc('h10);
      asm_inc('h10);
      asm_dec('h10);
      asm_dec('h10);

      asm_ld_r_IM(1, 8'h10);
      asm_decIn('hE1);

      asm_jp(JC_ALWAYS, L0_);
end
