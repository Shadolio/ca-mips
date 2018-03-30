module byte_addressable_memory (wordOut, wordIn, address, memRead, memWrite, clk);
	input clk;
	input memRead, memWrite;
	input [31:0] address;
	input [31:0] wordIn;
	output reg [31:0] wordOut;

	reg [7:0] memory[0 : 65535];

	// TODO: Support load half word

	always @(posedge clk) begin
		// Read or write according to the signal, but not both.
		// If both memRead and memWrite signals are 1, do the read operation only.
		if(memRead) begin

			wordOut[31:24] <= memory[address];
			wordOut[23:16] <= memory[address + 1];
			wordOut[15:8] <= memory[address + 2];
			wordOut[7:0] <= memory[address + 3];

		end
		else if(memWrite) begin

			memory[address] <= wordIn[31:24];
			memory[address + 1] <= wordIn[23:16];
			memory[address + 2] <= wordIn[15:8];
			memory[address + 3] <= wordIn[7:0];

		end
	end

endmodule


module byte_addressable_memory_tb ();
	reg clk, read, write;
	reg [31:0] address, wordIn;
	wire [31:0] wordOut;

	byte_addressable_memory testMemory (wordOut, wordIn, address, read, write, clk);

	initial begin
		
		clk = 0;
		address = 32'd400;
		wordIn = 32'd176;

		read = 1;
		write = 0;
		#10 clk = 1;

		#10 $display("Value at address %d at start is: %d", address, wordOut);
		clk = 0;

		read = 0;
		write = 1;
		#10 clk = 1;

		#10 $display("Value %d is loaded at address %d", wordIn, address);
		clk = 0;

		read = 1;
		write = 0;
		#10 clk = 1;

		#10 $display("Value at address %d is now: %d", address, wordOut);
		clk = 0;

	end

endmodule
