localparam L0_ = 16'h000C;
initial begin
      default_interrupt_vectors();

    label(L0_);
      asm_srp('h20);
      asm_ld_r_IM(0, 8'h00);
      asm_ld_r_IM(1, 8'h02);
      asm_ld_r_IM(2, 8'h24);
      asm_ldci_Ir_Irr(2, 0);
      asm_ldci_Ir_Irr(2, 0);

      asm_ld_r_IM(0, 8'hFF);
      asm_ld_r_IM(1, 8'hFE);
      asm_ld_r_IM(2, 8'h24);
      asm_ldci_Irr_Ir(0, 2);
      asm_ldci_Irr_Ir(0, 2);

      asm_jp(JC_ALWAYS, L0_);
end
