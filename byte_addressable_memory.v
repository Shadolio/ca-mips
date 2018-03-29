module byte_addressable_memory (wordOut, wordIn, address, memRead, memWrite, clk);
	input clk;
	input memRead, memWrite;
	input [31:0] address;
	input [31:0] wordIn;
	output [31:0] wordOut;

	reg [2^32 - 1: 0] memory[7:0];

	initial begin
		#10 $display("Value in memory at address (400) is: %d", memory[400]);
	end

endmodule
