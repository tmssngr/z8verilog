localparam L0_ = 16'h000C;
initial begin
      default_interrupt_vectors();

    label(L0_);
      asm_srp('h20);
      asm_ld_r_IM(0, 9);
      asm_ld_R_R('hE1, 'hE0);
      asm_ld_r_IM(1, 8'h22);
      asm_ld_IR_R(8'hE1, 8'hE0);
      asm_ld_R_IR(8'hE1, 8'hE1);

      asm_jp(JC_ALWAYS, L0_);
end
