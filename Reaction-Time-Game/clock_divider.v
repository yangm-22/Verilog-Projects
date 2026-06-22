// CLOCK DIVIDER => MAKES FAST CLOCK (50 MHz) --> SLOWER (1 KHz)

module clock_divider (input Clock, Reset_n, output reg clk_ms);
	parameter factor = 50000; //50000; // 32’h000061a7;
	reg [31:0] countQ;
	
	always @ (posedge Clock, negedge Reset_n) begin
		if (!Reset_n) begin
			countQ <= 32'b0; // reset countQ to 0
			clk_ms <= 1'b0;
		end
		else begin
			if (countQ < factor/2) begin // clk is low
				countQ <= countQ + 1'b1; // increament countQ
				clk_ms <= 1'b1;
			end
			else if (countQ < factor) begin // clk is high
				countQ <= countQ + 1'b1;
				clk_ms <= 1'b0;
				
			end
			else begin //countQ == factor => nxt clk cycle
				countQ <= 32'b0; // reset countQ
			end
		end
	end
endmodule

