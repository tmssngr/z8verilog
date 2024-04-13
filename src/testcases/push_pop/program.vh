`include "alu.vh"
`include "assembly.vh"
`include "sfr.vh"

localparam L0_ = 16'h0C;
initial begin
      default_interrupt_vectors();

    label(L0_);
      asm_srp('h20);
      asm_ld_r_IM(0, 'h12);
      asm_ld_r_IM(1, 'h34);
      asm_ld_R_IM(SPH, 'h00);
      asm_ld_R_IM(SPL, 'h80);
      asm_push('hE0);
      asm_push('hE1);
      asm_pop('hE0);
      asm_pop('hE1);

      asm_ld_r_IM(2, 'h20);
      asm_push_IR('h22);
      asm_ld_r_IM(2, 'h24);
      asm_pop_IR('h22);

      asm_jp(JC_ALWAYS, L0_);
end
