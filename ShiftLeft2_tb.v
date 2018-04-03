module ShifLeft2_tb();
wire [31:0]PostShift;
reg [31:0] PreShift;

ShiftLeft2 myShiftLeft(PostShift,PreShift);

initial
begin
	PreShift = 32'b 111;
	#10;
	$display("%b",PostShift);
end


endmodule
