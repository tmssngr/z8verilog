initial begin
	if (initFile == "rom00.mem") begin
		$readmemh("../../roms/ub8830.mem", memory);
	end
	else if (initFile == "jtc4k-es23-rom08.mem") begin
		$readmemh("../../roms/jtc4k-es23-rom08.mem", memory);
	end
	else if (initFile == "jtc4k-es23-rom10.mem") begin
		$readmemh("../../roms/jtc4k-es23-rom10.mem", memory);
	end
end
