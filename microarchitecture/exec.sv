
module exec #(parameter N=4, parameter BW=82)(
	input clk, rst, en, //clock, flush, stall
	input [N-1:0] rd1, rd2, pc, imm, aluOut, result, // Posible Alu entries
	input [N-1:0] rd3,
	input [3:0] aluControl,
	input [3:0] Ra, Rb, Rc, // Register number
	input immSrc, branchFlag, memWrite, memToReg, regWrite,
	input [1:0] opType,
	input [3:0] opCode,
	input Fa, Fb, //Hazard Unit Flags
	output [BW-1:0] bufferOut
);
	
	//sub modules output
	logic [1:0] flags;
	logic [N-1:0] aluCurrentResult;
	logic [N-1:0] op1,op2;
	logic [N-1:0] rdt;
	logic [BW-1:0] bufferInput;
	logic zeroFlag, negFlag;
	
	//Alu entry selector
	operatorsALUMux #(.opSize(4)) aluMux(.RD1(rd1), .RD2(rd2), .Imm(imm), .pc(pc), .AluOut(aluOut), .Result(result), .immSrc(immSrc), .branchFlag(branchFlag), .Fa(Fa), .Fb(Fb), .op1(op1), .op2(op2));
	
	
	ALU #(.N(4)) alu(.a(op1), .b(op2), .select(aluControl), .result(aluCurrentResult), .flags(flags));
	
	
	//buffer setup
	buffer #(.Buffer_size(BW)) EX_MEM (.rst(rst), .clk(clk), .en(en), .bufferInput(bufferInput), .bufferOut(bufferOut));
	
	
	assign zeroFlag = flags[0];
	assign negFlag = flags[1];
	
	
//divide instruction:
//	   | opType | opCode | aluCurrentResult | zeroFlag | negFlag | branchFlag | memWrite | memToReg | regWrite | Ra | Rb | Rc | rd3  |
//Size:
//	   |   [2] 	|   [4]  |       [N]	       |  [1]     |   [1]   |    [1]     |   [1]    |    [1]   |   [1]    |[4] |[4] |[4] | [N]  | 
//	----------------------------------------------------------------------------------------------------------------
//    |57		|85		|81				    |49		   |48	    |47			  |46			 |45			|44		  | 43 | 39 | 35 |31   0|

  	assign bufferInput={opType,opCode,aluCurrentResult,zeroFlag,negFlag,branchFlag,memWrite,memToReg,regWrite,Ra,Rb,Rc,rd3};
	
endmodule