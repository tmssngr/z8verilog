`ifndef BENCH

	initial begin
		if (initFile == "rom00.mem") begin
			$readmemh("ub8830.mem", memory);
		end
		else if (initFile == "rom08.mem") begin
			$readmemh("testcases/jtc2k/rom08.mem", memory);
		end
	end

`endif
