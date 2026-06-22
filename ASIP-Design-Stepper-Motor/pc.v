module pc (input clk, reset_n, branch, increment, input [7:0] newpc,
			output reg [7:0] pc);
			
	parameter RESET_LOCATION = 8'h00;
	
	always@(posedge clk or negedge reset_n) begin
	
		if(!reset_n)
			pc <=RESET_LOCATION;
			
		else if(branch)
			pc <= newpc; 
			
		else if(increment)
			pc <= pc + 8'b00000001; 
			
	end
				
endmodule
