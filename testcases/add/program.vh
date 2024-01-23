localparam L0_ = 16'h000C;

initial begin
      default_interrupt_vectors();

    label(L0_);
      asm_srp('h20);
      asm_ld_r_IM(0, 9);
      asm_ld_r_IM(1, 1);
      asm_add_r_r(0, 1);

      asm_ld_r_IM(1, 6);
      asm_add_r_r(0, 1);

      asm_ld_r_IM(1, 'h80);
      asm_add_r_r(0, 1);

      asm_ld_r_IM(1, 'h70);
      asm_add_R_R('hE0, 'hE1);

      asm_ld_r_IM(0, -1);
      asm_ld_r_IM(1, -1);
      asm_add_r_r(1, 0);

      asm_jp(JC_ALWAYS, L0_);
end
