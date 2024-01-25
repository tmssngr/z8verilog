localparam L0_ = 16'h000C;
localparam L1_ = 16'h0010;

initial begin
      default_interrupt_vectors();

label(L0_);
      asm_srp('h30);
      asm_ld_r_IM(0, 3);

label(L1_);
      asm_nop();
      asm_djnz(0, L1_);

      asm_jr(JC_ALWAYS, L0_);
end
