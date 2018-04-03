module ALU_Controller_tb();
wire [3:0] ALU_Control;
reg [5:0] ALUOP;
reg [5:0] Function;

ALU_Controller MyALUController(ALU_Control,ALUOP,Function);
initial
begin
	ALUOP = 0;
	Function = 6'h20;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 0;
	Function = 6'h22;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 0;
	Function = 0;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 0;
	Function = 2;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 0;
	Function = 6'h24;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 0;
	Function = 6'h25;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 0;
	Function = 6'h27;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 0;
	Function = 6'h2A;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 0;
	Function = 6'h2B;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 8;
	Function = 20;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 23;
	Function = 20;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 21;
	Function = 20;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 25;
	Function = 20;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 6'h2B;
	Function = 20;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 6'hC;
	Function = 20;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 6'hD;
	Function = 20;
	#10;
	$display("%b \n",ALU_Control);
	ALUOP = 4;
	Function = 20;
	#10;
	$display("%b \n",ALU_Control);
end


endmodule