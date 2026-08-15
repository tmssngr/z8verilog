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

		else if (initFile == "jtc4k-es23-rom08.mem") begin
			$readmemh("roms/jtc4k-es23-rom08.mem", memory);
		end
		else if (initFile == "jtc4k-es23-rom10.mem") begin
			$readmemh("roms/jtc4k-es23-rom10.mem", memory);
		end

		else if (initFile == "jtc6k-es40-rom08.mem") begin
			$readmemh("roms/jtc6k-es40-rom08.mem", memory);
		end
		else if (initFile == "jtc6k-es40-rom10.mem") begin
			$readmemh("roms/jtc6k-es40-rom10.mem", memory);
		end
		else if (initFile == "jtc6k-es40-rom18.mem") begin
			$readmemh("roms/jtc6k-es40-rom18.mem", memory);
		end

		else if (initFile == "jtc6k-es45-rom08.mem") begin
			$readmemh("roms/jtc6k-es45-rom08.mem", memory);
		end
		else if (initFile == "jtc6k-es45-rom10.mem") begin
			$readmemh("roms/jtc6k-es45-rom10.mem", memory);
		end
		else if (initFile == "jtc6k-es45-rom18.mem") begin
			$readmemh("roms/jtc6k-es45-rom18.mem", memory);
		end
	end

`endif
