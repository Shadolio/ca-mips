// word == 0: half word (2 bytes), 1: full word (4 bytes)
// sign == 0: unsigned, 1: signed
module ram_32bitAddr (dataOut, dataIn, address, read, write, word, sign, clk);
	input clk, read, write, word, sign;
	input [31:0] address, dataIn;
	output reg [31:0] dataOut;

	reg [7:0] memory[0 : 65535]; // TODO: Support 2^32 locations?

	always @(posedge clk) begin
		// Read or write according to the signal, but not both.
		// If both memRead and memWrite signals are 1, do the read operation only.
		if(read) begin

			dataOut[7:0] <= memory[address];
			dataOut[15:8] <= memory[address + 1];
			
			if(word == 1) begin

				dataOut[23:16] <= memory[address + 2];
				dataOut[31:24] <= memory[address + 3];

			end
			else if(word == 0) begin

				if(sign == 0) dataOut[31:16] <= 16'd0;
				else if(sign == 1) dataOut[31:16] <= { 16 { dataOut[15] } };

			end

		end
		else if(write) begin

			memory[address] <= dataIn[7:0];
			memory[address + 1] <= dataIn[15:8];
			memory[address + 2] <= dataIn[23:16];
			memory[address + 3] <= dataIn[31:24];

		end
	end

endmodule


module ram_32bitAddr_tb ();
	reg clk, read, write, word, sign;
	reg [31:0] address, wordIn;
	wire [31:0] wordOut;

	ram_32bitAddr testRam (wordOut, wordIn, address, read, write, word, sign, clk);

	initial begin
		
		clk <= 0;
		address <= 32'd400;
		wordIn <= 32'hF00FF176;
		word <= 1;
		sign <= 1;

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
		
		word <= 0;
		#10 clk <= 1;

		#10 $display("Half word at address %d is now: %d", address, wordOut);
		clk <= 0;
		
		sign <= 0;
		#10 clk <= 1;

		#10 $display("Half word (unsigned) at address %d is now: %d", address, wordOut);
		clk <= 0;

	end

endmodule
