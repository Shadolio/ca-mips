// word == 0: half word (2 bytes), 1: full word (4 bytes)
// sign == 0: unsigned, 1: signed
module ram (dataOut, dataIn, address, write, word, sign, clk);
	input clk, write, word, sign;
	input [31:0] address, dataIn;
	output reg [31:0] dataOut;

	parameter memLimit = 8'd255; // currently supports 2^27 addresses

	reg [7:0] memory[memLimit : 0];

	// READ -- does not need clock or read signal
	wire [7:0] m0Ready, m1Ready, m2Ready, m3Ready;

	assign m0Ready = memory[address];
	assign m1Ready = memory[address + 1];
	assign m2Ready = memory[address + 2];
	assign m3Ready = memory[address + 3];

	always @(m0Ready, m1Ready, m2Ready, m3Ready, word, sign) begin

		dataOut[7:0] <= m0Ready;
		dataOut[15:8] <= m1Ready;

		if(word == 1) begin // Full word (4 bytes)

			dataOut[23:16] <= m2Ready;
			dataOut[31:24] <= m3Ready;

		end
		else if(word == 0) begin // Half words (2 bytes only)

			if(sign == 0) dataOut[31:16] <= 16'd0;
			else if(sign == 1) dataOut[31:16] <= { 16 { m1Ready[7] } };

		end

	end

	// WRITE -- needs a 'write' signal to be active when the positive edge of the clock comes.
	always @(posedge clk) begin
		if(write) begin

			memory[address] <= dataIn[7:0];
			memory[address + 1] <= dataIn[15:8];
			memory[address + 2] <= dataIn[23:16];
			memory[address + 3] <= dataIn[31:24];

		end
	end

endmodule


module ram_tb ();
	reg clk, write, word, sign;
	reg [31:0] address, wordIn;
	wire [31:0] wordOut;

	ram testRam (wordOut, wordIn, address, write, word, sign, clk);

	initial begin
		
		clk <= 0;
		address <= 32'd200;
		wordIn <= 32'hF00FF176;
		word <= 1;
		sign <= 1;
		write <= 0;

		#10 $display("Value at address %d at start is: %d", address, wordOut);

		write = 1;
		clk = 1;

		$display("Value %d is loaded at address %d", wordIn, address);

		#10 clk = 0;
		write = 0;

		$display("Value at address %d is now: %d", address, wordOut);

		word = 0;

		#10 $display("Half word at address %d is now: %d", address, wordOut);

		sign = 0;

		#10 $display("Half word (unsigned) at address %d is now: %d", address, wordOut);

		address = 32'd10;

		#10 $display("Value at address %d is now: %d", address, wordOut);

	end

endmodule
