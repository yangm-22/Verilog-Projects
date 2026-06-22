// CONVERTS HEX TO BCD

module hex_to_bcd_converter(input wire clk, reset, 
									input wire [19:0] hex_number,
									output [3:0] bcd_digit_0,bcd_digit_1,bcd_digit_2,bcd_digit_3, bcd_digit_4, bcd_digit_5);
	// DE1-SoC has 6 7_seg_LEDs, 20 bits can represent decimal 999999.
	//This module is designed to convert a 20 bit binary representation to BCD
	integer i, k, j;
	wire [19:0] hex_number1; // the last 20 bits of input hex_number
	reg [3:0] bcd_digit [5:0]; // 6 BCD for 0-5
	assign hex_number1 = hex_number[19:0];
	
	assign bcd_digit_0 = bcd_digit[0];
	assign bcd_digit_1 = bcd_digit[1];
	assign bcd_digit_2 = bcd_digit[2];
	assign bcd_digit_3 = bcd_digit[3];
	assign bcd_digit_4 = bcd_digit[4];
	assign bcd_digit_5 = bcd_digit[5];
	
	always @ (*) begin
		if (!reset) begin
			//set all 6 digits to 0
			for (j=5 ; j>=0 ; j=j-1) begin
				bcd_digit[j] = 4'b0000;
			end
		end 
		//set all 6 digits to 0
		for (j=5 ; j>=0 ; j=j-1) begin
			bcd_digit[j] = 4'b0000;
		end
		
		//shift 20 times
		for (i=19; i>=0; i=i-1)
		begin
		
			//check all 6 BCD tetrads
			for (k=5; k>=0; k=k-1)
			begin
				// if >=5 then add 3
				if (bcd_digit[k] >= 5) begin
					bcd_digit[k] = bcd_digit[k] + 4'b0011;
				end
			end
			
			//shift one bit of BIN/HEX left
			//for the first 5 tetrads
			for (k=5; k>=1; k=k-1)
			begin
				bcd_digit[k]=bcd_digit[k] << 1;
				bcd_digit[k][0]=bcd_digit[k-1][3];
			end
			
			//shift one bit of BIN/HEX left, for the last tetrad
			/* fill your code here */
			bcd_digit[0] = bcd_digit[0] << 1;
			bcd_digit[0][0] = hex_number[i];
			
		end //end for loop
	end //end of always.
endmodule


