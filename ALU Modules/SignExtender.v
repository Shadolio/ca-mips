module SignExtender(ExtendedValue,HalfWord,Unsigned);
output reg [31:0]ExtendedValue;
input wire [15:0]HalfWord;
input wire Unsigned;

always @ (HalfWord,Unsigned) begin

	ExtendedValue[15:0] <= HalfWord;

	if(Unsigned==1)
		ExtendedValue[31:16] <= 0;

	else if (Unsigned==0)
		ExtendedValue[31:16] <= { 16 { HalfWord[15] } };

end

endmodule
