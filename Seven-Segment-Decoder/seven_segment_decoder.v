module lab1part3(
	input [9:0] SW,
	input [3:0] KEY,
	input CLOCK_50,
	output [6:0] HEX0
);

	// SW[9] and SW[8] for select line of mux4_1
	wire [1:0] x = {SW[9], SW[8]};
	
	// SW[3]-SW[0] for seven_seg_decoder 
	wire [3:0] seg = {SW[3], SW[2], SW[1], SW[0]};
	
	// bits for 30-bit counter and MSB 4-bits
	wire [29:0] count30_out;
	wire [3:0] count30_msb = count30_out[29:26];
	
	// declare wire for 4-bit counter output
	wire [3:0] count4_out;
	
	// declare wire for mux output
	wire [3:0] mux_out;

	// instantiate mux
	mux4_1 mux(
		.select(x),
		.in_seg(seg),
		.in_count4(count4_out),
		.in_count30(count30_msb),
		.out(mux_out)
	);

	// instantiate 4-bit counter => counter # times KEY[3] pressed
	counter4 count4(
		.clk(KEY[3]),
		.reset_n(KEY[0]), 
		.enable(1'b1),
		.out(count4_out)
	);
	
	// instantiate 30-bit counter
	counter30 count30(
		.clk(CLOCK_50),
		.reset_n(KEY[0]),
		.enable(1'b1),
		.result(count30_out)
    );
	 
	// instantiate 7-seg
	seven_seg_decoder decoder(
		.x(mux_out),
		.hex_LEDs(HEX0)
	);
    
endmodule


// mux
module mux4_1(input [1:0] select, input [3:0] in_seg, input [3:0] in_count4, input [3:0] in_count30, output reg [3:0] out);
					
	always@(*) begin
		case (select)
			2'b00: out = in_seg; // 7-seg takes input from SW3-SW0
			2'b01: out = in_count4; // 7-seg takes input from counter4
			2'b10: out = in_count30; // takes MSB 4 input from counter30
			2'b11: out = 4'b1111; // reset counters
			default: out = 4'b1111; // default behaviour
		endcase
	end
endmodule



// 4-bit counter module with active low reset (bc keys are active low)
module counter4(input clk, input reset_n, input enable, output reg [3:0] out);
	always@(negedge clk or negedge reset_n) begin
		if (!reset_n) begin
			out <= 4'b0000;
		end
		else if (enable) begin
			out <= out + 1'b1;
		end
	end
endmodule



// 30-bit counter module
module counter30(input clk, input reset_n, input enable, output reg[WIDTH-1:0] result);
	parameter WIDTH = 30;
	//2’s power of 26 is 67,108,864.
	// that is 1 second (2^ 26/50e6 = 1.34), if count is using CLOCK 50
	always@(posedge clk, negedge reset_n)
		if (!reset_n) begin
			result <= 30'b0;
		end else if (enable) begin
			result <= result + 1'b1;
		end
endmodule


// 7-seg decoder module
module seven_seg_decoder(input [3:0] x, output [6:0] hex_LEDs);
    reg [6:0] reg_LEDs;

    assign hex_LEDs[0] = (~x[3] & ~x[2] & ~x[1] & x[0]) | 
                        (x[2] & ~x[1] & ~x[0]) | 
                        (x[3] & x[2] & x[1]);
    assign hex_LEDs[1] = (~x[3] & x[2] & ~x[1] & x[0]) | 
                        (~x[3] & x[2] & x[1] & ~x[0]) | 
                        (x[3] & x[2] & ~x[1] & ~x[0]) | 
                        (x[3] & x[1] & x[0]);

    assign hex_LEDs[6:2]=reg_LEDs[6:2];

    always @(*)
    begin
        case (x)
            4'b0000: reg_LEDs[6:2]=5'b10000; //7'b1000000 decimal 0
            4'b0001: reg_LEDs[6:2]=5'b11110; //7'b1111001 decimal 1
            4'b0010: reg_LEDs[6:2]=5'b01001; //7'b0100100 decimal 2
            4'b0011: reg_LEDs[6:2]=5'b01100; //7'b0110000 decimal 3
            4'b0100: reg_LEDs[6:2]=5'b00110; //7'b0011001 decimal 4
            4'b0101: reg_LEDs[6:2]=5'b00100; //7'b0010010 decimal 5
            4'b0110: reg_LEDs[6:2]=5'b00000; //7'b0000010 decimal 6
            4'b0111: reg_LEDs[6:2]=5'b11110; //7'b1111000 decimal 7
            4'b1000: reg_LEDs[6:2]=5'b00000; //7'b0000000 decimal 8
            4'b1001: reg_LEDs[6:2]=5'b00100; //7'b0010000 decimal 9
            4'b1010: reg_LEDs[6:2]=5'b10010; //7'b1001000 letter M
            4'b1011: reg_LEDs[6:2]=5'b00001; //7'b0000110 letter E
            4'b1100: reg_LEDs[6:2]=5'b10001; //7'b1000111 letter L
            4'b1101: reg_LEDs[6:2]=5'b10000; //7'b1000000 letter O
            4'b1110: reg_LEDs[6:2]=5'b01000; //7'b0100001 letter D
            4'b1111: reg_LEDs[6:2]=5'b11111; //7'b1111111 OFF 
            default: reg_LEDs[6:2] = 5'b11111;
				
        endcase
    end
endmodule


