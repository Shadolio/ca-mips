module ShiftLeft2(PostShift,PreShift);
input wire [31:0]PreShift;
output reg [31:0]PostShift;

always @ (PreShift)
begin
	PostShift = PreShift << 2;
end

endmodule