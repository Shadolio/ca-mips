module ALU_Controller(ALU_Control,ALUOP,Function);
output reg [3:0] ALU_Control;
input wire [5:0] ALUOP;
input wire [5:0] Function;

always @ (ALUOP,Function)
begin
	case(ALUOP)
		6'h0:
		begin
			case(Function)
				6'h20: ALU_Control = 4'd1;
				6'h22: ALU_Control = 4'd2;
				6'h0: ALU_Control = 4'd3;
				6'h2: ALU_Control = 4'd4;
				6'h24: ALU_Control = 4'd5;
				6'h25: ALU_Control = 4'd6;
				6'h27: ALU_Control = 4'd7;
				6'h2A: ALU_Control = 4'd9;
				6'h2B: ALU_Control = 4'd8;
			endcase
		end
		6'h8: ALU_Control = 4'd1;
		6'h23: ALU_Control = 4'd1;
		6'h21: ALU_Control = 4'd1;
		6'h25: ALU_Control = 4'd1;
		6'h2B: ALU_Control = 4'd1;
		6'hC : ALU_Control = 4'd5;
		6'hD : ALU_Control = 4'd6;
		6'h4 : ALU_Control = 4'd2;
		

	endcase
		
end  

endmodule
