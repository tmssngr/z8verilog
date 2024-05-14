	chk_ld_R_IM_noRegCheck(P3M, 8'h40);
		`assert(uut.proc.p3m, 8'h40);

	chk_ld_R_IM_noRegCheck(T0, 8'h01);
		`assert(uut.proc.t0load, 1);

	// PRE0 = 1, continues
	chk_ld_R_IM_noRegCheck(PRE0, 8'b000001_01);
		`assert(uut.proc.pre0, 8'h5);

	chk_ld_R_IM_noRegCheck(TMR, 8'b0000_0011);
		`assert(uut.proc.tmr, 8'b0000_0010);
		`assert(uut.proc.pre0counter, 9'b0_000001_01);
		`assert(uut.proc.t0counter, 1);
		`assert(uut.proc.irq, 0);

	// TX =================================================
		`assert(uut.proc.sioTxState, SIO_IDLE);
		`assert(serialOut, 1);
	chk_ld_R_IM_noRegCheck(SIO, 8'hA5);
		`assert(uut.proc.sioTx, 8'hA5);
		`assert(uut.proc.sioTxState, SIO_START);
		`assert(uut.proc.sioTxCounter, 4'h0);
		`assert(serialOut, 0);
		repeat (61) @(negedge clk);
		`assert(serialOut, 0);
		`assert(uut.proc.sioTx, 8'b1010_0101);
		`assert(uut.proc.sioTxState, SIO_START);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 8'hA5 = 8'b1010_0101
		//                    ^
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b1_1010_010);
		`assert(uut.proc.sioTxState, SIO_BIT0);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b1_1010_010);
		`assert(uut.proc.sioTxState, SIO_BIT0);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 8'hA5 = 8'b1010_0101
		//                   ^
		`assert(serialOut, 0);
		`assert(uut.proc.sioTx, 8'b11_1010_01);
		`assert(uut.proc.sioTxState, SIO_BIT1);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 0);
		`assert(uut.proc.sioTx, 8'b11_1010_01);
		`assert(uut.proc.sioTxState, SIO_BIT1);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 8'hA5 = 8'b1010_0101
		//                  ^
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b111_1010_0);
		`assert(uut.proc.sioTxState, SIO_BIT2);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b111_1010_0);
		`assert(uut.proc.sioTxState, SIO_BIT2);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 8'hA5 = 8'b1010_0101
		//                 ^
		`assert(serialOut, 0);
		`assert(uut.proc.sioTx, 8'b1111_1010);
		`assert(uut.proc.sioTxState, SIO_BIT3);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 0);
		`assert(uut.proc.sioTx, 8'b1111_1010);
		`assert(uut.proc.sioTxState, SIO_BIT3);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 8'hA5 = 8'b1010_0101
		//               ^
		`assert(serialOut, 0);
		`assert(uut.proc.sioTx, 8'b1_1111_101);
		`assert(uut.proc.sioTxState, SIO_BIT4);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 0);
		`assert(uut.proc.sioTx, 8'b1_1111_101);
		`assert(uut.proc.sioTxState, SIO_BIT4);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 8'hA5 = 8'b1010_0101
		//              ^
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b11_1111_10);
		`assert(uut.proc.sioTxState, SIO_BIT5);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b11_1111_10);
		`assert(uut.proc.sioTxState, SIO_BIT5);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 8'hA5 = 8'b1010_0101
		//             ^
		`assert(serialOut, 0);
		`assert(uut.proc.sioTx, 8'b111_1111_1);
		`assert(uut.proc.sioTxState, SIO_BIT6);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 0);
		`assert(uut.proc.sioTx, 8'b111_1111_1);
		`assert(uut.proc.sioTxState, SIO_BIT6);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 8'hA5 = 8'b1010_0101
		//            ^
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b1111_1111);
		`assert(uut.proc.sioTxState, SIO_BIT7);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b1111_1111);
		`assert(uut.proc.sioTxState, SIO_BIT7);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 1st stop bit
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b1111_1111);
		`assert(uut.proc.sioTxState, SIO_STOP1);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b1111_1111);
		`assert(uut.proc.sioTxState, SIO_STOP1);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);

		@(negedge clk);
		// 2nd stop bit
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b1111_1111);
		`assert(uut.proc.sioTxState, SIO_STOP2);
		`assert(uut.proc.sioTxCounter, 4'h0);
		repeat (63) @(negedge clk);
		`assert(serialOut, 1);
		`assert(uut.proc.sioTx, 8'b1111_1111);
		`assert(uut.proc.sioTxState, SIO_STOP2);
		`assert(uut.proc.sioTxCounter, 4'hF);
		`assert(uut.proc.irq, 0);
		@(negedge clk);
		`assert(uut.proc.irq, 8'h10);

		repeat (12) @(negedge clk);
		//chk_alu2_R_IM(ALU2_TM, IRQ, 8'h10,
		//              IRQ, 8'h10, FLAG_NONE);
		chk_jr_false(JC_Z, 8'hFB, 16'h0020);

		// RX =====================
		`assert(uut.proc.sioRxState, SIO_IDLE);
		// start bit
		serialIn = 0;
		@(negedge clk);
		`assert(uut.proc.sioRxState, SIO_START);
		`assert(uut.proc.sioRxCounter, 0);
		repeat(32) @(negedge clk);
		`assert(uut.proc.sioRxCounter, 8);
		`assert(uut.proc.sioRxState, SIO_BIT0);

		repeat(31) @(negedge clk);
		// 8'h5A = 8'b0101_1010
		//                    ^
		serialIn = 0;
		repeat(33) @(negedge clk);
		`assert(uut.proc.sioRxState, SIO_BIT1);
		`assert(uut.proc.sioRxShiftRegister[7], 1'b0);

		repeat(31) @(negedge clk);
		// 8'h5A = 8'b0101_1010
		//                   ^
		serialIn = 1;
		repeat(33) @(negedge clk);
		`assert(uut.proc.sioRxState, SIO_BIT2);
		`assert(uut.proc.sioRxShiftRegister[7:6], 2'b10);

		repeat(31) @(negedge clk);
		// 8'h5A = 8'b0101_1010
		//                  ^
		serialIn = 0;
		repeat(33) @(negedge clk);
		`assert(uut.proc.sioRxState, SIO_BIT3);
		`assert(uut.proc.sioRxShiftRegister[7:5], 3'b010);

		repeat(31) @(negedge clk);
		// 8'h5A = 8'b0101_1010
		//                 ^
		serialIn = 1;
		repeat(33) @(negedge clk);
		`assert(uut.proc.sioRxState, SIO_BIT4);
		`assert(uut.proc.sioRxShiftRegister[7:4], 4'b1010);

		repeat(31) @(negedge clk);
		// 8'h5A = 8'b0101_1010
		//               ^
		serialIn = 1;
		repeat(33) @(negedge clk);
		`assert(uut.proc.sioRxState, SIO_BIT5);
		`assert(uut.proc.sioRxShiftRegister[7:3], 5'b1_1010);

		repeat(31) @(negedge clk);
		// 8'h5A = 8'b0101_1010
		//              ^
		serialIn = 0;
		repeat(33) @(negedge clk);
		`assert(uut.proc.sioRxState, SIO_BIT6);
		`assert(uut.proc.sioRxShiftRegister[7:2], 6'b01_1010);

		repeat(31) @(negedge clk);
		// 8'h5A = 8'b0101_1010
		//             ^
		serialIn = 1;
		repeat(33) @(negedge clk);
		`assert(uut.proc.sioRxState, SIO_BIT7);
		`assert(uut.proc.sioRxShiftRegister[7:1], 7'b101_1010);

		repeat(31) @(negedge clk);
		// 8'h5A = 8'b0101_1010
		//            ^
		serialIn = 0;
		repeat(33) @(negedge clk);
		`assert(uut.proc.sioRxState, SIO_STOP1);
		`assert(uut.proc.sioRxShiftRegister, 8'b0101_1010);

		repeat(31) @(negedge clk);
		// stop bit (one is enough)
		serialIn = 1;
		repeat(33) @(negedge clk);
		`assert(uut.proc.sioRxState, SIO_IDLE);
		`assert(uut.proc.sioRxShiftRegister, 8'b0101_1010);
		`assert(uut.proc.sioRx, 8'h5A);
		`assert(uut.proc.irq, 8'b0001_1000);

		@(negedge clk);

//	chk_jp(16'h001B);
