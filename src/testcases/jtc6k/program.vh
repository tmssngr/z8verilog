initial begin
	if (initFile == "rom00.mem") begin
		$readmemh("../../roms/ub8830.mem", memory);
	end
	else if (initFile == "jtc6k-es40-rom08.mem") begin
		$readmemh("../../roms/jtc6k-es40-rom08.mem", memory);
	end
	else if (initFile == "jtc6k-es40-rom10.mem") begin
		$readmemh("../../roms/jtc6k-es40-rom10.mem", memory);
	end
	else if (initFile == "jtc6k-es40-rom18.mem") begin
		$readmemh("../../roms/jtc6k-es40-rom18.mem", memory);
	end
end
