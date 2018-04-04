module RegisterFile(ReadData1,ReadData2,ReadReg1,ReadReg2,WriteReg,WriteData,RegWriteSignal,clk);
    input [4:0] ReadReg1, ReadReg2, WriteReg;
    input [31:0] WriteData;
    input clk, RegWriteSignal;
    output [31:0] ReadData1, ReadData2;

    reg [31:0] Registers[31:0];

	assign ReadData1 = (ReadReg1 == 0) ? 32'd0 : Registers[ReadReg1];
	assign ReadData2 = (ReadReg2 == 0) ? 32'd0 : Registers[ReadReg2];
    
    always @ (posedge clk)
    begin
        if(RegWriteSignal==1)
            Registers[WriteReg] <= WriteData; 
    end
    
endmodule

module RegisterFile_tb ();
    reg [4:0] ReadReg1, ReadReg2, WriteReg;
    reg [31:0] writeData;
    reg clk, regWrite;
    wire [31:0] ReadData1, ReadData2;

	RegisterFile testRegFile (ReadData1, ReadData2, ReadReg1, ReadReg2, WriteReg, writeData, regWrite, clk);

	initial begin

		ReadReg1 <= 5'b10001;
		ReadReg2 <= 5'b10010;
		WriteReg <= 5'b10001;

		writeData <= 32'd17697;

		#10 $display("Value at %d = %d, Value at %d = %d", ReadReg1, ReadData1, ReadReg2, ReadData2);

		regWrite <= 1;
		clk <= 1;

		$display("Value %d written at address %d", writeData, WriteReg);

		#10 clk <= 0;
		regWrite <= 0;

		$display("Value at %d = %d, Value at %d = %d", ReadReg1, ReadData1, ReadReg2, ReadData2);

		#10 ReadReg1 <= 5'b11000;
		#10 ReadReg1 <= 5'b10001;

		#10 $display("Value at %d = %d, Value at %d = %d", ReadReg1, ReadData1, ReadReg2, ReadData2);

	end

endmodule
