module mux4_1(input [1:0] sel, 
					input [23:0] a, b, c, d,
					output reg [23:0] out);
					
	always@(*) begin
		case (sel)
			2'b00: out = a; // off
			2'b01: out = b; //
			2'b10: out = c;
			2'b11: out = d;
			default: out = 24'b0;
		endcase
	end
	
endmodule
