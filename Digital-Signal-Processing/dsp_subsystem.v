
module dsp_subsystem (
	input wire sample_clock,
	input wire reset,
	input wire [1:0] selector,
	input wire signed [15:0] input_sample,
	output signed [15:0] output_sample);
    
	wire signed [15:0] y_fir;
	wire signed [15:0] y_echo;
	wire signed [15:0] mux_out;
	
	// FIR filter
	fir_filter u_fir (
			.clk (sample_clock),
			.reset (reset),
			.x_in (input_sample),
			.y_out(y_fir)
	);
	defparam u_fir.TAPS = 65;

	// echo machine
	echo_machine u_echo (
			.clk (sample_clock),
			.reset (reset),
			.x_in (input_sample),
			.y_out (y_echo)
	);
	 
	// 3-to-1 multiplexer
	mux3_1 mux (
			.og_signal(input_sample),
			.fir(y_fir),
			.echo(y_echo),
			.sel(selector),
			.out(mux_out)
	);
	 
	assign output_sample = mux_out;
endmodule // dsp_subsystem
