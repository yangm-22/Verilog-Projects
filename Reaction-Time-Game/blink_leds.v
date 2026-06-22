module blink_leds (input clk, 
						input reset_n,
						output reg [23:0] LEDs);
						
	parameter factor = 200; 
	reg [11:0] counter;
	
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			counter <= 12'b0;
			LEDs <= 24'b0;
		end
			
		else begin
			if (counter < factor/2) begin
				counter <= counter + 1'b1;
			end
			else if (counter < factor) begin
				counter <= counter + 1'b1;
				LEDs <= 24'b111111111111111111111111;
			end
			else begin
				counter <= 12'b0;
				LEDs <= 24'b0;
			end
		end
	end		
endmodule
