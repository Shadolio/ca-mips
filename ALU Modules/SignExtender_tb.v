module SignExtender_tb();
wire [31:0] ExtendedValue;
reg [15:0] HalfWord;
reg Unsigned;

SignExtender myExtender(ExtendedValue,HalfWord,Unsigned);

initial
begin
	HalfWord = 16'b1111111111111111;
	Unsigned = 1;
	#10;
	$display("%b \n",ExtendedValue);
	HalfWord = 16'b1111111111111111;
	Unsigned = 0;
	#10;
	$display("%b \n",ExtendedValue);
end

endmodule
