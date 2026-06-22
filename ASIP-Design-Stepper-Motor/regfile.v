// This module implements the register file

module regfile (input clk, reset_n, write, input [7:0] data, input [1:0] select0, select1, wr_select,
				output reg [7:0] selected0, selected1, output [7:0] delay, position, register0);

	// The comment /* synthesis preserve */ after the declaration of a register
	// prevents Quartus from optimizing it, so that it can be observed in simulation
	// It is important that the comment appear before the semicolon
	reg [7:0] reg0 /* synthesis preserve */;
	reg [7:0] reg1 /* synthesis preserve */;
	reg [7:0] reg2 /* synthesis preserve */;
	reg [7:0] reg3 /* synthesis preserve */;

	assign register0 = reg0;
	assign position = reg2; 
	assign delay = reg3; 

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			reg0 <=8'b0; 
			reg1 <=8'b0; 
			reg2 <=8'b0; 
			reg3 <=8'b0; 
		end
		else if (write) begin
			case (wr_select)
				2'b00: reg0 <=data; 
				2'b01: reg1 <=data;
				2'b10: reg2 <=data;
				2'b11: reg3 <=data;	
			endcase
		end
	end
	
	always @(*) begin
		case (select0)
			2'b00: selected0 <=reg0; 
			2'b01: selected0 <=reg1;
			2'b10: selected0 <=reg2;
			2'b11: selected0 <=reg3;
		endcase
		case (select1)
			2'b00: selected1 <=reg0; 
			2'b01: selected1 <=reg1;
			2'b10: selected1 <=reg2;
			2'b11: selected1 <=reg3;
		endcase
	end

endmodule
