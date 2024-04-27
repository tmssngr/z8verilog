`ifndef BENCH

	// used by GOWIN IDE
	initial begin
		if (initFile == "rom00.mem") begin
			$readmemh("roms/ub8830.mem", memory);
		end

		else if (initFile == "jtc2k-rom08.mem") begin
			$readmemh("roms/jtc2k-rom08.mem", memory);
		end

		else if (initFile == "jtc4k-rom08.mem") begin
			$readmemh("roms/jtc4k-rom08.mem", memory);
		end
		else if (initFile == "jtc4k-rom20.mem") begin
			$readmemh("roms/jtc4k-rom20.mem", memory);
		end
	end

`endif
