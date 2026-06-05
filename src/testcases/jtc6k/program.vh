initial begin
	if (initFile == "rom00.mem") begin
		$readmemh("../../roms/ub8830.mem", memory);
	end
	else if (initFile == "jtc6k-rom08.mem") begin
		$readmemh("../../roms/jtc6k-rom08.mem", memory);
	end
	else if (initFile == "jtc6k-rom10.mem") begin
		$readmemh("../../roms/jtc6k-rom10.mem", memory);
	end
	else if (initFile == "jtc6k-rom18.mem") begin
		$readmemh("../../roms/jtc6k-rom18.mem", memory);
	end
end
