module branch_logic (input [7:0] register0, output reg branch); 
//had to change branch to output reg instead of just output for combinational logic
	
	always @(*) begin
		if (register0==8'b0) begin
			branch = 1'b1; 
		end
		else begin
			branch = 1'b0;
		end
	end

endmodule
