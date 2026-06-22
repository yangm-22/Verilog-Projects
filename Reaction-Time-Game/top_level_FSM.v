module lab2 (input CLOCK_50,
                    input [3:0] KEY,
                    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
                    output [9:0] LEDR);

	// define states
	parameter [3:0]
		RESET = 4'b0000,
		START = 4'b0001,
		WAIT_LED = 4'b0010,
		COUNTING = 4'b0011,
		P1_CHEAT = 4'b0100,
		P2_CHEAT = 4'b0101,
		BOTH_CHEAT = 4'b0110,
		P1_WIN = 4'b0111,
		P2_WIN = 4'b1000;
	
	// curr state and next state
	reg [3:0] curr_state = RESET;
	reg [3:0] nxt_state = RESET;
	
	// scores
	reg [4:0] score1 = 5'b0;
	reg [4:0] score2 = 5'b0;
	
	
	// HEX displays
	wire [23:0] off = 24'hFFFFFF;
	reg [23:0] cheat_disp;

	
	// outputs for 7-seg decoder disp
	wire [6:0] digit0, digit1, digit2, digit3, digit4, digit5;
	
	// assign wires
	assign HEX0 = digit0;
	assign HEX1 = digit1;
	assign HEX2 = digit2;
	assign HEX3 = digit3;
	assign HEX4 = digit4;
	assign HEX5 = digit5;
	assign LEDR[4:0] = score1; // score for player 1
	assign LEDR[9:5] = score2; // score for player 2
						  
	// clk divider
	wire clk_ms;
	clock_divider clk1 (.Clock(CLOCK_50), 
								.Reset_n(KEY[1]), 
								.clk_ms(clk_ms));
	// counters
	wire [19:0] ms_counter;
	wire [19:0] disp_counter;
	reg disp_counter_enable;
	reg [19:0] disp_counter_val;
	reg main_counter_start;
	reg disp_counter_start;
	reg disp_counter_reset;
	counter main_counter (.clk(clk_ms),
							.reset_n(KEY[2]), 
							.start_n(main_counter_start), 
							.stop_n(1'b1),
							.ms_count(ms_counter));
							
	counter disp_counter_inst (.clk(clk_ms), 
                               .reset_n(disp_counter_reset), 
                               .start_n(disp_counter_start), 
                               .stop_n(disp_counter_enable), 
                               .ms_count(disp_counter));
	
	// RNG
	wire [13:0] random_wait;
	reg [13:0] random_wait_time;
	wire rng_ready;
	random rng1 (.clk(clk_ms),
						.reset_n(KEY[1]), 
						.resume_n(KEY[2]), 
                  .random(random_wait), 
                  .rnd_ready(rng_ready));
	
	// HEX to BCD converter
	wire [23:0] bcd_out;
	hex_to_bcd_converter bcd1 (.clk(clk_ms), 
										.reset(reset_n), 
										.hex_number(disp_counter),
										.bcd_digit_0(bcd_out[3:0]),
										.bcd_digit_1(bcd_out[7:4]),
										.bcd_digit_2(bcd_out[11:8]),
										.bcd_digit_3(bcd_out[15:12]),
										.bcd_digit_4(bcd_out[19:16]),
										.bcd_digit_5(bcd_out[23:20]));
										
	// LEDs blinker
	wire [23:0] blink_output;
	blink_leds blink1 (.clk(clk_ms),
                       .reset_n(KEY[1]),
                       .LEDs(blink_output));
							  
	// mux
	wire [23:0] mux_out;
	reg [1:0] sel;
	mux4_1 mux(.sel(sel), 
					.a(off), //00
					.b(bcd_out), //01
					.c(blink_output), //10
					.d(cheat_disp), //11
					.out(mux_out));
	
	// 7-seg disp decoder
	seven_seg_decoder seg0 (.x(mux_out[3:0]), .hex_LEDs(digit0));
	seven_seg_decoder seg1 (.x(mux_out[7:4]), .hex_LEDs(digit1));
	seven_seg_decoder seg2 (.x(mux_out[11:8]), .hex_LEDs(digit2));
	seven_seg_decoder seg3 (.x(mux_out[15:12]), .hex_LEDs(digit3));
	seven_seg_decoder seg4 (.x(mux_out[19:16]), .hex_LEDs(digit4));
	seven_seg_decoder seg5 (.x(mux_out[23:20]), .hex_LEDs(digit5));
	
	// check if rng is ready 
	always @(posedge CLOCK_50) begin
		if (rng_ready) begin
			random_wait_time = random_wait;
		end
		else begin
			random_wait_time = 2000; // default value
		end
	end
	
	// FSM
	always @(posedge CLOCK_50 or negedge KEY[1]) begin
		if (!KEY[1]) begin
			curr_state <= RESET;
		end
		else begin
			curr_state <= nxt_state;
		end
	end
	
	// determine nxt_state
	always @(*) begin
		// default conditions
		nxt_state = curr_state;
		sel = 2'b00;
		cheat_disp = 24'b0;
		
		case(curr_state) 
			RESET: begin
				//disp_counter_val = 20'b0;
				sel = 2'b00;
				nxt_state = START;
				disp_counter_enable = 0;
			end
			
			START: begin
				sel = 2'b10; // blink
				main_counter_start = 0;
				disp_counter_reset = 0;
				if (ms_counter >= 5000) begin
					nxt_state = WAIT_LED;
				end
				else begin
					nxt_state = START;
				end
			end
			
			WAIT_LED: begin
				sel = 2'b00; // off, waiting period	
				disp_counter_reset = 0;
				// check cheating 
				if (!KEY[0] && !KEY[3]) begin
					nxt_state = BOTH_CHEAT;
				end
				else if (!KEY[0]) begin
					nxt_state = P1_CHEAT;
				end
				else if (!KEY[3]) begin
					nxt_state = P2_CHEAT;
				end
				else if (ms_counter >= random_wait_time + 5000) begin
					nxt_state = COUNTING;
				end
			end
			
			// COUNTING state
			COUNTING: begin
				sel = 2'b01; // display reaction time
				disp_counter_reset = 1;
				disp_counter_enable = 1; // start counting reaction
				disp_counter_start = 0;
				
				if (!KEY[0] && !KEY[3]) begin
					nxt_state = BOTH_CHEAT;
				end
				else if (!KEY[0]) begin
					if (disp_counter < 80) begin
						nxt_state = P1_CHEAT;
					end
					else begin
						nxt_state = P1_WIN;
					end
				end
				else if (!KEY[3]) begin
					if (disp_counter < 80) begin
						nxt_state = P2_CHEAT;
					end
					else begin
						nxt_state = P2_WIN;
					end
				end
			end
			
			P1_CHEAT: begin
				sel = 2'b11;
				cheat_disp = 24'h111111;
				disp_counter_enable = 0;
				if (!KEY[2]) begin
					nxt_state = WAIT_LED;
				end
			end
			
			P2_CHEAT: begin
				sel = 2'b11;
				cheat_disp = 24'h222222;
				disp_counter_enable = 0;
				if (!KEY[2]) begin
					nxt_state = WAIT_LED;
				end
			end
			
			BOTH_CHEAT: begin
				sel = 2'b11;
				cheat_disp = 24'h888888;
				disp_counter_enable = 0;
				if (!KEY[2]) begin
					nxt_state = WAIT_LED;
				end
			end
			
			P1_WIN: begin
				disp_counter_enable = 0;
				disp_counter_start = 1;
				sel = 2'b01; // display winning time
				if (!KEY[2]) begin
					nxt_state = WAIT_LED;
				end
			end
			
			P2_WIN: begin
				disp_counter_enable = 0;
				disp_counter_start = 1;
				sel = 2'b01; // display winning time
				if (!KEY[2]) begin
					nxt_state = WAIT_LED;
				end
			end
			
			default: nxt_state = RESET;
		endcase 
	end
	
	// update scores
	always @(posedge CLOCK_50 or negedge KEY[1]) begin
		if (!KEY[1]) begin
			score1 <= 5'b0;
			score2 <= 5'b0;
		end
		else begin
			if (curr_state == P1_WIN && nxt_state == WAIT_LED) begin
				score1 <= (score1 << 1) | 5'b00001;
			end
			else if (curr_state == P2_WIN && nxt_state == WAIT_LED) begin
				score2 <= (score2 >> 1) | 5'b10000;
			end
		end
	end

endmodule

