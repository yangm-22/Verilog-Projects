// COUNTER 

module counter(input clk, input reset_n, start_n, stop_n, output reg [19:0] ms_count);
	reg isCounting; // counter flag
	
	always @(posedge clk or negedge reset_n) begin 
		if (!reset_n) begin
			ms_count <= 20'b0; // reset counter
			isCounting <= 1'b0; // reset flag
		end 
		else begin
			if (!start_n) begin
				ms_count <= 20'b0;
				isCounting <= 1'b1; // start counting
			end
			else if (!stop_n) begin
				ms_count <= ms_count; // store prev value
				isCounting <= 1'b0; // stop counting
			end
			if (isCounting && stop_n)  begin
				ms_count <= ms_count + 1'b1;
			end
		end
	end
endmodule
