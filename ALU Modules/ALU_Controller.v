module ALU_Controller(ALU_Control,ALUOP,Function);
output reg [3:0] ALU_Control;
input wire [5:0] ALUOP;
input wire [5:0] Function;

always @ (ALUOP,Function)
begin
	case(ALUOP)
		6'h0: // R-type instructions: Look at 'Funct' field
		begin
			case(Function)
				6'h20: ALU_Control = 4'd1;	// ADD
				6'h22: ALU_Control = 4'd2;	// SUB
				6'h0: ALU_Control = 4'd3;	// SLL
				6'h2: ALU_Control = 4'd4;	// SRL
				6'h24: ALU_Control = 4'd5;	// AND
				6'h25: ALU_Control = 4'd6;	// OR
				6'h27: ALU_Control = 4'd7;	// NOR
				6'h2B: ALU_Control = 4'd8;	// SLTU
				6'h2A: ALU_Control = 4'd9;	// SLT
			endcase
		end
		6'h8: ALU_Control = 4'd1;	// ADDI = ADD
		6'h23: ALU_Control = 4'd1;	// LW = ADD
		6'h21: ALU_Control = 4'd1;	// LH = ADD
		6'h25: ALU_Control = 4'd1;	// LHU = ADD
		6'h2B: ALU_Control = 4'd1;	// SW = ADD
		6'hC : ALU_Control = 4'd5;	// ANDI = AND
		6'hD : ALU_Control = 4'd6;	// ORI = OR
		6'h4 : ALU_Control = 4'd2;	// BEQ = SUB
		

	endcase
		
end  

endmodule
