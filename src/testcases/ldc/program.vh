`include "alu.vh"
`include "assembly.vh"

localparam L0_ = 16'h000C;
initial begin
    if (initFile == "rom00.mem") begin
        default_interrupt_vectors();

      label(L0_);
        asm_srp('h20);
        asm_ld_r_IM(0, 0);
        asm_ld_r_IM(1, 'hB);
        asm_ldc_r_Irr(2, 0);

        // rom
        asm_ld_r_IM(0, 8'h08);
        asm_ld_r_IM(1, 8'h12);
        asm_ldc_Irr_r(0, 2);

        // ram
        asm_ld_r_IM(0, 8'hFF);
        asm_ld_r_IM(1, 8'h80);
        asm_ldc_r_Irr(2, 0);
        asm_alu1(ALU1_INC, 8'h22);
        asm_ldc_Irr_r(0, 2);

        asm_jp(JC_ALWAYS, L0_);
    end
    else if (initFile == "rom08.mem") begin
        $readmemh("../../2k-00filled.mem", memory);
    end
end
