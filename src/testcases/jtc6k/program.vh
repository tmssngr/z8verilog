initial begin
	if (initFile == "rom00.mem") begin
		$readmemh("../../ub8830.mem", memory);
	end
	else if (initFile) begin
		$readmemh(initFile, memory);
	end
end
