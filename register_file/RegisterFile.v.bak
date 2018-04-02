module RegisterFile(clk,RegWriteSignal,ReadReg1,ReadReg2,WriteReg,WriteData,ReadData1,ReadData2);
    input [4:0] ReadReg1;
    input [4:0] ReadReg2;
    input [4:0] WriteReg;
    input [31:0] WriteData;
    input clk, RegWriteSignal;
    output reg [31:0] ReadData1;
    output reg [31:0] ReadData2;
    reg [31:0] Registers[4:0];
    
    always @ (ReadReg1 or ReadReg2)
    begin
        if(ReadReg1!=0)
            ReadData1 <= Registers[ReadReg1];
        else
            ReadData1 <= 0;
            
        if(ReadReg2!=0)
            ReadData2 <= Registers[ReadReg2];
        else
            ReadData2 <= 0;
    end
    
    always @ (posedge clk)
    begin
        if(RegWriteSignal==1)
            Registers[WriteReg] <= WriteData; 
    end
    
endmodule
