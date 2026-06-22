module alu (input add_sub, set_low, set_high, input [7:0] operanda , operandb, output reg [7:0] result);

	always @(*) begin
		result = 8'b0; 
		if (set_low) begin
			result [7:4] = operanda[7:4]; 
			result [3:0] = operandb[3:0]; 
		end
		else if (set_high) begin
			result[7:4] = operandb[3:0];
			result[3:0] = operanda[3:0];
		end
		else if(add_sub==1'b0) begin
			result = operanda + operandb; 
		end
		else if (add_sub==1'b1) begin
			result = operanda- operandb; 
		end
	end



endmodule
