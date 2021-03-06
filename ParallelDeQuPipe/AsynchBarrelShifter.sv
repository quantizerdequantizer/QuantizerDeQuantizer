module AsynchBarrelShifter #(
   parameter L2WIDTH = 512,
	parameter WWIDTH  = 32,
   parameter SWIDTH  = 5
)(
   input [0:0] clk,
   //input  rst,
   input  logic [L2WIDTH-1:0] InputStr,
   input  logic [SWIDTH-1:0]  NumShift,
   input logic  [8:0] AccNumShift,
   output logic [WWIDTH-1:0]  ExtractedBits,
   output logic               IsOutlier
);
//reg [WWIDTH-1:0]  ExtractedBits;
//reg IsOutlier;

logic [L2WIDTH-1:0] temp1;
logic  [WWIDTH-1:0] temp2, temp3, temp4, temp5;

//assign temp1 = InputStr >> NumShift;
//
assign temp2 =  InputStr[AccNumShift +: WWIDTH];                      //-- Get only the WWIDTH bits
assign temp3 = {WWIDTH{1'b1}} >> WWIDTH-NumShift;      //-- Create mask for extracted bits
assign temp4 = {WWIDTH{1'b1}} >> WWIDTH-NumShift+1;    //-- Create mask for IsOutlier

assign temp5 = temp4 | temp2;
always @(posedge clk) begin
	ExtractedBits <=  temp3|temp2;
	IsOutlier    <= &temp5;
end 
/*For P&R timing estimate
always @(posedge clk or negedge rst)
   if (~rst) OutputStr  <= 'h0;
   else OutputStr <= InputStr >> NumShift;
always @(posedge clk or negedge rst)
         if (~rst)  ExtractedBits <= 'h0;
         else  ExtractedBits <= temp3|temp2;
always @(posedge clk or negedge rst)
   if (~rst) IsOutlier <= 1'b0;
   else IsOutlier <= &temp5;
*/

endmodule
 
