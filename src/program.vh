`ifdef BENCH

    `include "alu.vh"
    `include "assembly.vh"

    localparam L0_ = 16'h000C;
    localparam L1_ = 16'h0012;

    initial begin
        default_interrupt_vectors();

    label(L0_);
        asm_srp('h00);
        asm_ld_r_IM(4, 5);
        asm_ld_r_IM(2, 8'b1);

    label(L1_);
        asm_alu1(ALU1_RL, 8'hE2);
        asm_djnz(4, L1_);

        asm_jr(JC_ALWAYS, L0_);
    end

`else

	initial begin
		if (initFile == "rom00.mem") begin
			$readmemh("ub8830.mem", memory);
		end
		else if (initFile == "rom08.mem") begin
			$readmemh("testcases/jtc4k-es23/rom08.mem", memory);
		end
		else if (initFile == "rom10.mem") begin
			$readmemh("testcases/jtc4k-es23/rom10.mem", memory);
		end
	end

`endif
