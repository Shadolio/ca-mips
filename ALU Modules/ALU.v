module ALU(Zero, ALU_Result, InputData1, InputData2, ALU_Control);
output Zero;
output reg [31:0] ALU_Result;
input wire [31:0] InputData1;
input wire [31:0] InputData2;
input wire [3:0] ALU_Control;
reg [31:0] tmp1;
reg [31:0] tmp2;

assign Zero = (ALU_Result == 0)? 1 : 0;

always @ (InputData1,InputData2,ALU_Control)
begin
	case(ALU_Control)
// ADD
		4'd1: begin 
			ALU_Result <= InputData1+InputData2;
		       end
//SUB		
		4'd2: begin 
			ALU_Result <= InputData1-InputData2;
		       end
//SLL		
		4'd3: begin 
			ALU_Result <= InputData1 << InputData2;
		       end
//SRL		
		4'd4: begin 
			ALU_Result <= InputData1 >> InputData2;
		       end
//AND		
		4'd5: begin 
			ALU_Result <= InputData1&InputData2;
		       end
//OR		
		4'd6: begin 
			ALU_Result <= InputData1|InputData2;
		       end
//NOR		
		4'd7: begin 
			ALU_Result <= ~(InputData1|InputData2);
		       end
//SLTU		
		4'd8: begin 
			ALU_Result <= (InputData1<InputData2)? 1 : 0;
		       end
//SLT		
		4'd9: begin

			if((InputData1 >= 0 & InputData2 >= 0) | (InputData1 < 0 & InputData2 < 0))
				ALU_Result <= (InputData1 < InputData2);
			else if(InputData1 < 0 & InputData2 >= 0)
				ALU_Result <= 1;
			else if(InputData2 < 0 & InputData1 >= 0)
				ALU_Result <= 0;

		       end
		default: ALU_Result <= 0;
	endcase
end

endmodule
