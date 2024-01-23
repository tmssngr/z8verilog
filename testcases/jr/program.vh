localparam L0_ = 16'h000C;
localparam L1_ = 16'h0010;

initial begin
      default_interrupt_vectors();

label(L0_);
      asm_jr(JC_NEVER, L0_);

      asm_ld_r_IM(0, 3);

label(L1_);
      asm_add_R_IM(0, 8'hFF);
      asm_jr(JC_NZ, L1_);

      asm_jr(JC_ALWAYS, L0_);
end
