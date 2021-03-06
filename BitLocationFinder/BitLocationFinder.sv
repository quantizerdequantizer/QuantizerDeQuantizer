//This implementation is for the case that we avoid partial blocks in L1 by requesting the subsequent bits from higher level cache
//
`define BitLocationFinderWithAccLen
`ifdef BitLocationFinderWithAccLen
module BitLocationFinder (PageOffset,WordNumberOfStartOfQuantizedBlock, ResidueOfOffsettDivision,QntStructBits, NumWord, StartWord, AccLen, BitLocationStart);
`endif
parameter PageOffsetWidth= 12;
parameter BlockOffsetWidth= 6;
parameter MaximumNumberOfWord=32;
//LPGG: Warning port size differs in port connection
//parameter MaximumNumberOfWordWidth=5;
parameter MaximumNumberOfWordWidth=9;
parameter WordNumberWidth=10;
//LPGG: Warning port size differs in port connection
//parameter BitLocationWidth=9;
parameter BitLocationWidth=10;
parameter QntStructBitsWidth=10;

input [PageOffsetWidth-1:0] PageOffset;
input [WordNumberWidth-1:0]WordNumberOfStartOfQuantizedBlock;
input [BitLocationWidth-1:0] ResidueOfOffsettDivision; //=Voffset % DeQntWords
input [QntStructBitsWidth-1:0]QntStructBits;
input [MaximumNumberOfWordWidth-1:0]NumWord;
input [MaximumNumberOfWordWidth:0] StartWord;
//----------------------
`ifdef BitLocationFinderWithAccLen
input [MaximumNumberOfWord*BitLocationWidth-1:0] AccLen; //Two times the maximum numberOfWords
`endif
//-----------------------
//------------------------------------
output [BitLocationWidth-1:0] BitLocationStart;
reg [BitLocationWidth-1:0] BitLocationStart;
reg [BitLocationWidth-1:0] bitLocationInitial;
reg signed[BitLocationWidth-1+1:0] BitLocationStartTmp;

//-----------------------
reg [MaximumNumberOfWordWidth-1:0]  EndlResidue;
reg [MaximumNumberOfWordWidth-1:0]  StartResidue;
reg [MaximumNumberOfWordWidth-1:0]  tmpResidue;

//LPGG : Warning size differs in port connection
logic [5:0] numberOfCompleteStructElements;
logic [8:0] RemainderOfCompleteStructueElements;

//-----------------------
`undef FivePortDivider
dividerRemainder InstDR(.dividend(ResidueOfOffsettDivision), .divisor(NumWord),.quotient(numberOfCompleteStructElements),.remainder(RemainderOfCompleteStructueElements) );
always @(WordNumberOfStartOfQuantizedBlock or StartWord or NumWord) begin
	StartResidue<=(WordNumberOfStartOfQuantizedBlock+StartWord)%NumWord;
end

always @( numberOfCompleteStructElements or RemainderOfCompleteStructueElements or tmpResidue) begin
	bitLocationInitial <=numberOfCompleteStructElements*QntStructBits;
	tmpResidue<=(RemainderOfCompleteStructueElements+StartWord);
	if(tmpResidue>NumWord) begin
		EndlResidue<=tmpResidue-NumWord;
	end else begin
		EndlResidue<=tmpResidue;
	end
end
`ifdef BitLocationFinderWithAccLen
//TODO:
always @(AccLen or StartResidue or EndlResidue ) begin
	BitLocationStart<= AccLen[(EndlResidue*BitLocationWidth-1) -: BitLocationWidth]-AccLen[(StartResidue*BitLocationWidth-1) -: BitLocationWidth]+ QntStructBits;
end
`endif
endmodule
//We use AccLen to avoid computation of the following psudo code, the following would need an adder tree or impose a high latency for corner cases, where 
//------------------Psudo code
//WN=StartWordOfTheQuantizedBlock
//for (i=0; i<FinalResidue;i++){
//    bitLocation=bitLocation+StructureSet[WN].BitWidth
//    WN=WN+1; If (WN>NumWord) { WN=0} }
//
//----------------------





