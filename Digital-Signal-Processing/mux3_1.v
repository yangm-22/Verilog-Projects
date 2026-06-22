module mux3_1(input signed [15:0] og_signal, fir, echo,
					input [1:0] sel,
					output reg signed [15:0] out);
					
	always @(*) begin
		case (sel) 
			2'b00: out = og_signal;
			2'b01: out = fir;
			2'b10: out = echo;
			default: out = og_signal;
		endcase
	end
endmodule // mux3_1
