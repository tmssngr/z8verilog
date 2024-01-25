localparam L0_ = 16'h000C;
initial begin
      default_interrupt_vectors();

    label(L0_);
      asm_srp('h20);
      asm_ld_r_IM(0, 9);
      asm_ld_R_R('hE1, 'hE0);

      asm_jp(JC_ALWAYS, L0_);
end
