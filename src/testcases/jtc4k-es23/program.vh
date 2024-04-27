initial begin
	if (initFile == "rom00.mem") begin
		$readmemh("../../ub8830.mem", memory);
	end
	else if (initFile) begin
		$display("initialize ", initFile);
		$readmemh(initFile, memory);
	end
end
