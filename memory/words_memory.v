module words_memory (dataOut, dataIn, address, read, write, clk);
	input clk, read, write;
	input [31:0] dataIn, address;
	output [31:0] dataOut;

	ram_32bitAddr ram (dataOut, dataIn, address, read, write, 1'b1, 1'bx, clk);

endmodule

module words_memory_tb ();
	reg clk, read, write;
	reg [31:0] address, wordIn;
	wire [31:0] wordOut;

	words_memory testMem (wordOut, wordIn, address, read, write, clk);

	initial begin
		
		clk <= 0;
		address <= 32'd400;
		wordIn <= 32'hF00FF176;

		read <= 1;
		write <= 0;
		#10 clk <= 1;

		#10 $display("Value at address %d at start is: %d", address, wordOut);
		clk <= 0;

		read <= 0;
		write <= 1;
		#10 clk <= 1;

		#10 $display("Value %d is loaded at address %d", wordIn, address);
		clk <= 0;

		read <= 1;
		write <= 0;
		#10 clk <= 1;

		#10 $display("Value at address %d is now: %d", address, wordOut);
		clk <= 0;

	end

endmodule
