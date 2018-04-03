module SignExtender(ExtendedValue,HalfWord,Unsigned);
output reg [31:0]ExtendedValue;
input wire [15:0]HalfWord;
input wire Unsigned;

always @ (HalfWord,Unsigned)
begin
	if(Unsigned==1)
	begin
		ExtendedValue[31:16] = 0;
		ExtendedValue[15:0] = HalfWord;
	end
	else if (Unsigned==0)
	begin
		if(HalfWord[15]==0)
			ExtendedValue[31:16] = 0;
		else if(HalfWord[15]==1)
			ExtendedValue[31:16] = 16'b1111111111111111;
		ExtendedValue[15:0] = HalfWord;
	end
end


endmodule
