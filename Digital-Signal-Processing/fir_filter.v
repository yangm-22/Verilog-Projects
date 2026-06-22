module fir_filter(
	input  wire clk,       // sample clock (8 kHz)
	input  wire reset,   // active-high reset
	input  wire signed [15:0] x_in,      // input sample
	output reg  signed [15:0] y_out      // output sample
);
	parameter TAPS = 65;  // default value 65
	
	// shift register for storing delays shifting to the right
	reg signed [15:0] x_delay [0:TAPS-1];  
	
	// store products from multiplier
	wire signed [31:0] prod [0:TAPS-1];  

	integer i;
	always @(posedge clk or posedge reset) begin
		if (reset) begin // active-high reset
			for (i=0 ; i<TAPS ; i=i+1) begin
				x_delay[i] <= 16'sd0;
			end
		end
		else begin
			x_delay[0] <= x_in; // save 
			for (i=1 ; i<TAPS ; i=i+1) begin
				x_delay[i] <= x_delay[i-1]; //shift down
			end
		end
	end

	// assign coefficients for MATLAB integers after x 32768

	reg signed [15:0] coeff [0:TAPS-1];

	integer k;
	always @(*) begin
		// default all zeros to avoid latches / unknowns
		coeff[0]=        -6;
		coeff[1]=        -0;
		coeff[2]=        18;
		coeff[3]=         0;
		coeff[4]=       -43;
		coeff[5]=        -0;
		coeff[6]=        87;
		coeff[7]=         0;
		coeff[8]=      -158;
		coeff[9]=        -0;
		coeff[10]=       261;
		coeff[11]=         0;
		coeff[12]=      -403;
		coeff[13]=        -0;
		coeff[14]=       585;
		coeff[15]=         0;
		coeff[16]=      -807;
		coeff[17]=        -0;
		coeff[18]=      1061;
		coeff[19]=         0;
		coeff[20]=     -1338;
		coeff[21]=        -0;
		coeff[22]=      1620;
		coeff[23]=         0;
		coeff[24]=     -1890;
		coeff[25]=        -0;
		coeff[26]=      2127;
		coeff[27]=         0;
		coeff[28]=     -2313;
		coeff[29]=        -0;
		coeff[30]=      2431;
		coeff[31]=         0;
		coeff[32]=     30296;
		coeff[33]=         0;
		coeff[34]=      2431;
		coeff[35]=        -0;
		coeff[36]=     -2313;
		coeff[37]=         0;
		coeff[38]=      2127;
		coeff[39]=        -0;
		coeff[40]=     -1890;
		coeff[41]=         0;
		coeff[42]=      1620;
		coeff[43]=        -0;
		coeff[44]=     -1338;
		coeff[45]=         0;
		coeff[46]=      1061;
		coeff[47]=        -0;
		coeff[48]=      -807;
		coeff[49]=         0;
		coeff[50]=       585;
		coeff[51]=        -0;
		coeff[52]=      -403;
		coeff[53]=         0;
		coeff[54]=       261;
		coeff[55]=        -0;
		coeff[56]=      -158;
		coeff[57]=         0;
		coeff[58]=        87;
		coeff[59]=        -0;
		coeff[60]=       -43;
		coeff[61]=         0;
		coeff[62]=        18;
		coeff[63]=        -0;
		coeff[64]=        -6;
	end
	 
	// 16x16 signed to 32-bit signed product of coefficients multiplied  by 32768 
	genvar t;
	generate
		for (t = 0; t < TAPS; t = t + 1) begin : GEN_MUL
			multiplier u_mult (
				.dataa(x_delay[t]),  // 16-bit signed
				.datab(coeff[t]),        // 16-bit signed
				.result(prod[t])      // 16-bit signed
			);
		end
	endgenerate
	
	// summing all true coefficients together(adder built in)  
	reg signed [31:0] sum; 
	integer s;
	always @(*) begin
		sum = 32'sd0;
		for (s=0 ; s<TAPS ; s=s+1)
			// summing together all products
			sum = sum + prod[s]; 
	end

	// divide by 2^15 (32768)
	wire signed [31:0] sum_scaled;
	assign sum_scaled = sum >>> 15;
	
	// output register per clock cycle
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			y_out <= 16'sd0;
		end
		else begin
			y_out <= sum_scaled[15:0]; // summed scaled sum truncated to 16 bits 
		end
	end

endmodule // fir_filter


