module fwd_unit(fwdA, fwdB,
		instrRs_E, instrRt_E,
		writeReg_M, writeReg_WB, regWrite_M, regWrite_WB,
		memToReg_M, memToReg_WB);

	input [4:0] instrRs_E, instrRt_E, writeReg_M, writeReg_WB;
	input regWrite_M, regWrite_WB, memToReg_M, memToReg_WB;
	output [1:0] fwdA, fwdB;

	wire fwd_ALU_A, fwd_MEM_A;
	wire fwd_ALU_B, fwd_MEM_B;

	wire fwd_ALU, fwd_MEM;

	// 00: no forwarding
	// 10: forward from ALU
	// 01: forward from MEM
	// 11: ----

	assign fwdA = { fwd_ALU_A, fwd_MEM_A };
	assign fwdB = { fwd_ALU_B, fwd_MEM_B };

	assign fwd_ALU = regWrite_M & (writeReg_M != 5'd0) & ~memToReg_M;
	assign fwd_MEM = regWrite_WB & (writeReg_WB != 5'd0) & memToReg_WB;

	assign fwd_ALU_A = fwd_ALU & (instrRs_E == writeReg_M);
	assign fwd_ALU_B = fwd_ALU & (instrRt_E == writeReg_M);

	assign fwd_MEM_A = fwd_MEM & (instrRs_E == writeReg_WB) & ~fwd_ALU_A;
	assign fwd_MEM_B = fwd_MEM & (instrRt_E == writeReg_WB) & ~fwd_ALU_B;

endmodule

module fwd_unit_tb();
	reg [4:0] instrRs_E, instrRt_E, writeReg_M, writeReg_WB;
	reg regWrite_M, regWrite_WB, memToReg_M, memToReg_WB;
	wire [1:0] fwdA, fwdB;

	fwd_unit testFwdUnit (fwdA, fwdB,
			instrRs_E, instrRt_E, writeReg_M, writeReg_WB, regWrite_M, regWrite_WB,
			memToReg_M, memToReg_WB);

	initial begin

		$monitor("FwdA: %b, FwdB: %b, Rs_E: %b, Rt_E: %b, write_M (%b)(%b): %b, write_WB (%b)(%b): %b",
			fwdA, fwdB, instrRs_E, instrRt_E,
			regWrite_M, memToReg_M, writeReg_M,
			regWrite_WB, memToReg_WB, writeReg_WB);

		instrRs_E <= 5'b01001;
		instrRt_E <= 5'b01011;

		writeReg_M <= 5'b01001;
		memToReg_M <= 1'b0;
		regWrite_M <= 1'b1;

		writeReg_WB <= 5'b01011;
		memToReg_WB <= 1'b1;
		regWrite_WB <= 1'b1;

	end

endmodule
