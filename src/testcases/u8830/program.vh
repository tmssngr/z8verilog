localparam P3M  = 8'hF7;

localparam M_001D = 16'h001D;
localparam M_003D = 16'h003D;

initial begin
      default_interrupt_vectors();

// start of U8830
      asm_srp(0);
      asm_ld_r_IM(3, 'h0F);
      asm_nop();
      asm_tm_R_IM('hE3, 'b0000_0100);
      asm_ld_r_IM(3, 'hFF);
      asm_jr(JC_NZ, M_001D);
      asm_tm_R_IM('hE3, 'b0000_0100);
      asm_jr(JC_NZ, M_003D);
label(M_001D);
      asm_ld_R_IM(P01M, 'hB6); // P00-P03 = A8-A11, Stack intern, P1x = AD0-AD7, P04-P04 = A12-A15, extended memory timing
      asm_ld_R_IM(P3M, 8);     // P30-P33 input, P35-P37 output, P34 DM, Port 2 open-drain
      asm_ld_r_IM(4, 8);       // if %0812 is writable
      asm_ld_r_IM(5, 'h12);
      asm_ldc_r_Irr(6, 4);
      asm_com('hE6);
      asm_ldc_Irr_r(4, 6);
      asm_ldc_r_Irr(7, 4);
      asm_com('hE6);
      asm_ldc_Irr_r(4, 6);
      asm_xor_r_r(6, 7);
      asm_srp('hF0);
      asm_jp(JC_NZ, 16'hE000);
      asm_jp(JC_ALWAYS, 16'h0812);
label(M_003D);
      asm_jp(JC_ALWAYS, M_003D);
end
