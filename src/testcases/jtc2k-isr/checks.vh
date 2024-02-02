	repeat (70) begin
		@(negedge clk);
		`assert(uut.proc.port3, 0);
	end
	repeat (64) begin
		repeat (3) begin
			$display("LH on port37 expected");
			repeat (10) begin
				@(negedge clk);
				`assert(uut.proc.port3, 8'h80);
			end
			$display("HL on port37 expected");
			repeat (246) begin
				@(negedge clk);
				`assert(uut.proc.port3, 0);
			end
		end
	end
