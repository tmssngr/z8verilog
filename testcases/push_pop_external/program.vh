localparam L0_ = 16'h0C;

initial begin
      default_interrupt_vectors();

    label(L0_);
      asm_srp('h20);
      asm_ld_R_IM(P01M, 'h92); // external stack
      asm_clr(SPH);
      asm_clr(SPL);

      asm_ld_r_IM(0, 'h12);
      asm_push('hE0);
      asm_pop('hE1);

      asm_jp(JC_ALWAYS, L0_);
end
