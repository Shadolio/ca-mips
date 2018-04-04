module ALU_tb();
wire Zero;
wire [31:0] ALU_Result;
reg [31:0]InputData1;
reg [31:0]InputData2;
reg [3:0]ALU_Control;

ALU myALU(Zero,ALU_Result,InputData1,InputData2,ALU_Control);

initial
begin
	InputData1 = 32'b11111111111111111111111111111111;
	InputData2 = 32'b00000000000000000000000000000001;

	ALU_Control = 1;
	#10;
	$display("%b  %b \n",ALU_Result,Zero);
	ALU_Control = 2;
	#10;
	$display("%b  %b \n",ALU_Result,Zero);
	ALU_Control = 3;
	#10;
	$display("%b  %b \n",ALU_Result,Zero);
	ALU_Control = 4;
	#10;
	$display("%b  %b \n",ALU_Result,Zero);
	ALU_Control = 5;
	#10;
	$display("%b  %b \n",ALU_Result,Zero);
	ALU_Control = 6;
	#10;
	$display("%b  %b \n",ALU_Result,Zero);
	ALU_Control = 7;
	#10;
	$display("%b  %b \n",ALU_Result,Zero);
	ALU_Control = 8;
	#10;
	$display("%b  %b \n",ALU_Result,Zero);
	ALU_Control = 9;
	#10;
	$display("%b  %b \n",ALU_Result,Zero);
end

endmodule
