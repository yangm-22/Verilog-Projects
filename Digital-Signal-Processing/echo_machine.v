module echo_machine (
	input  wire clk,
	input  wire reset,
	input  wire signed [15:0] x_in,
	output reg  signed [15:0] y_out
);

	wire signed [15:0] delayed_sample;

	shiftregister u_delay (
		.clock (clk),
		.shiftin (x_in),
		.shiftout(delayed_sample)
	);
	
	// divider
	wire signed [15:0] scaled_echo;
	assign scaled_echo = delayed_sample >>> 2;

	// adder
	wire signed [18:0] sum; //allows for overflow cases
	assign sum = x_in + scaled_echo;

	// output register
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			y_out <= 16'sd0;
		end
		else begin
			y_out <= sum[15:0];  // truncated to 16-bits 
		end
	end
	
endmodule // echo_machine
