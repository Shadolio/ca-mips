module program_counter(result, write, nextIntruction, reset, clk);
	input clk;
	input write; // law write = 1, kda ma3naha te2dar t7ot 7aga fl PC
	input reset;  //law reset = 1, then raga3 el PC b zero mn el awel
	input [31:0] nextIntruction;
	output reg [31:0] result;

	/*initial begin
		result <= 0;
	end*/

	always @(posedge clk, posedge reset) begin

		if (reset)
			result <= 0;  //raga3 el pc lel initial value

		else begin
			if (write)
				result <= nextIntruction;
		end

	end

endmodule
