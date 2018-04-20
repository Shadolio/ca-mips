module ALU_tb();
wire Zero;
wire [31:0] ALU_Result;
reg [31:0] InputData1, InputData2;
reg [4:0] shamt;
reg [3:0]ALU_Control;

ALU myALU(Zero, ALU_Result, InputData1, InputData2, shamt, ALU_Control);

initial
begin
	InputData1 <= 32'b11111111111111111111111111111111;
	InputData2 <= 32'b00000000000000000000000000000001;

	$monitor("In1: %b, In2: %b, shamt: %b .. Res: %b, Zero: %b. (ALU control: %d)", InputData1, InputData2, shamt, ALU_Result, Zero, ALU_Control);

	// ADD
	#10 ALU_Control <= 1;

	// SUB
	#10 ALU_Control <= 2;

	// SLL
	#10 InputData2 <= 32'd5;
	shamt <= 5'd3;
	ALU_Control <= 3;

	// SRL
	#10 shamt <= 5'd2;
	ALU_Control <= 4;

	// AND
	#10 InputData2 <= 32'd1;
	ALU_Control <= 5;

	// OR
	#10 ALU_Control <= 6;

	// NOR
	#10 ALU_Control <= 7;

	// SLTU
	#10 ALU_Control <= 8;

	// SLT
	#10 InputData1 <= 32'b11111111111111111111111111111110;
	ALU_Control <= 9;

end

endmodule
