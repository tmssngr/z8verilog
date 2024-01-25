localparam L0_ = 16'h0C;
initial begin
      default_interrupt_vectors();
    label(L0_);
      asm_srp('h10);
      asm_ld_r_IM(0, 9);
      asm_ld_r_IM(1, 1);

      asm_add_r_r(0, 1);
      asm_da('hE0);
      asm_sub_r_r(0, 1);
      asm_da('hE0);


      asm_ld_r_IM(1, 9);

      asm_add_r_r(0, 1);
      asm_da('h10);
      asm_sub_r_r(0, 1);
      asm_da('h10);


      asm_ld_r_IM(0, 'h15);
      asm_ld_r_IM(1, 'h87);

      asm_add_r_r(0, 1);
      asm_da('h10);
      asm_sub_r_r(0, 1);
      asm_da('h10);


      asm_ld_r_IM(0, 'h00);
      asm_ld_r_IM(1, 'h01);

      asm_sub_r_r(0, 1);
      asm_da('h10);
      asm_add_r_r(0, 1);
      asm_da('h10);

      asm_jp(JC_ALWAYS, L0_);
end
