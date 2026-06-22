module control_fsm (
	input clk, reset_n,
	// Status inputs
	input br, brz, addi, subi, sr0, srh0, clr, mov, mova, movr, movrhs, pause,
	input delay_done,
	input temp_is_positive, temp_is_negative, temp_is_zero,
	input register0_is_zero,
	// Control signal outputs
	output reg write_reg_file,
	output reg result_mux_select,
	output reg [1:0] op1_mux_select, op2_mux_select,
	output reg start_delay_counter, enable_delay_counter,
	output reg commit_branch, increment_pc,
	output reg alu_add_sub, alu_set_low, alu_set_high,
	output reg load_temp_register, increment_temp_register, decrement_temp_register,
	output reg [1:0] select_immediate,
	output reg [1:0] select_write_address
	
);
parameter RESET=5'b00000, FETCH=5'b00001, DECODE=5'b00010,
			BR=5'b00011, BRZ=5'b00100, ADDI=5'b00101, SUBI=5'b00110, SR0=5'b00111,
			SRH0=5'b01000, CLR=5'b01001, MOV=5'b01010, MOVA=5'b01011,
			MOVR=5'b01100, MOVRHS=5'b01101, PAUSE=5'b01110, MOVR_STAGE2=5'b01111,
			MOVR_DELAY=5'b10000, MOVRHS_STAGE2=5'b10001, MOVRHS_DELAY=5'b10010,
			PAUSE_DELAY=5'b10011, MOVA_STAGE2=5'b10100, MOVA_DELAY = 5'b10101;

reg [4:0] state = RESET;
reg [4:0] next_state_logic = FETCH; // NOT REALLY A REGISTER!!!

	// Next state logic
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			state <= RESET; 
		end
		else begin
			state <= next_state_logic;
		end
	end		

	
	// State register
	always @(*) begin
	
		next_state_logic = state; 
		
		write_reg_file = 1'b0;
		result_mux_select = 1'b0;
		op1_mux_select[1:0] =2'b0;
		op2_mux_select[1:0] = 2'b0;
		start_delay_counter = 1'b0; 
		enable_delay_counter= 1'b0;
		commit_branch =1'b0; 
		increment_pc = 1'b0; 
		alu_add_sub = 1'b0;
		alu_set_low = 1'b0; 
		alu_set_high = 1'b0;
		load_temp_register = 1'b0;
		increment_temp_register = 1'b0;
		decrement_temp_register = 1'b0; 
		select_immediate[1:0] = 2'b0;
		select_write_address[1:0] = 2'b0; 
		
		case (state)
			RESET: begin   
				next_state_logic = FETCH; 
			end
			FETCH: begin   
				next_state_logic = DECODE; 
			end

			DECODE: begin
				if      (br)     next_state_logic = BR;
				else if (brz)    next_state_logic = BRZ;
				else if (addi)   next_state_logic = ADDI;
				else if (subi)   next_state_logic = SUBI;
				else if (sr0)    next_state_logic = SR0;
				else if (srh0)   next_state_logic = SRH0;
				else if (clr)    next_state_logic = CLR;
				else if (mov)    next_state_logic = MOV;
				else if (mova)   next_state_logic = MOVA;
				else if (movr)   next_state_logic = MOVR;
				else if (movrhs) next_state_logic = MOVRHS;
				else if (pause)  next_state_logic = PAUSE;
				else             next_state_logic = FETCH;
			end

			BR: begin
				select_immediate = 2'b10; // signed extension in immediate_extractor
				op1_mux_select = 2'b00; // PC
				op2_mux_select = 2'b01;  //immediate
				alu_add_sub = 1'b0; //add
				commit_branch = 1'b1; // for true
				next_state_logic = FETCH;
			end 
			BRZ: begin
				if (register0_is_zero) begin
					select_immediate = 2'b10; // signed extension in immediate_extractor
					op1_mux_select = 2'b00; // PC
					op2_mux_select = 2'b01;  //immediate
					alu_add_sub = 1'b0; //add
					commit_branch = 1'b1; // PC = PC + imm5 aka sext
				end
				else begin
					increment_pc = 1'b1; //next instructions 
				end
				next_state_logic = FETCH;
			end
			
			ADDI: begin
				op1_mux_select = 2'b01; // register
				op2_mux_select = 2'b01; //immediate
				select_immediate = 2'b00; //3-bit immediate
				alu_add_sub = 1'b0; //  add
				result_mux_select = 1'b0; // alu is set to 'b0
				select_write_address = 2'b01; // writes to reg_field0 
				write_reg_file = 1'b1; //writes to regfile 
				increment_pc = 1'b1; 
				next_state_logic = FETCH;
			end
			SUBI: begin
				op1_mux_select = 2'b01; // register
				op2_mux_select = 2'b01; //immediate
				select_immediate = 2'b00; //3-bit immediate
				alu_add_sub = 1'b1; //  subtract
				result_mux_select = 1'b0; // alu is set to 'b0
				select_write_address = 2'b01; // writes to reg_field0 
				write_reg_file = 1'b1; //writes to regfile 
				increment_pc = 1'b1; 
				next_state_logic = FETCH;
			end
			SR0: begin 
				op1_mux_select = 2'b11; // register0
				op2_mux_select = 2'b01; //immediate
				select_immediate = 2'b01; //4-bit immediate
				alu_set_low = 1'b1; //sets it to true concatonates at bottom
				result_mux_select = 1'b0; // alu is set to 'b0
				select_write_address = 2'b00; // writes to R0 
				write_reg_file = 1'b1; //writes to regfile 
				increment_pc = 1'b1;
				next_state_logic = FETCH;
			end
			SRH0: begin
				op1_mux_select = 2'b11; // register0
				op2_mux_select = 2'b01; //immediate
				select_immediate = 2'b01; //4-bit immediate
				alu_set_high = 1'b1; //sets it to true concatonates at top
				result_mux_select = 1'b0; // alu is set to 'b0
				select_write_address = 2'b00; // writes to R0 
				write_reg_file = 1'b1; //writes to regfile 
				increment_pc = 1'b1;
				next_state_logic = FETCH;
			end
			CLR: begin
				result_mux_select = 1'b1; //sets it to 0 
				select_write_address = 2'b01; //sets reg_field0 to the setting point
				write_reg_file = 1'b1; //writes it
				increment_pc = 1'b1; //increments pc 
				next_state_logic = FETCH;
			end
			MOV: begin
				write_reg_file = 1'b1; // used to update register
				result_mux_select = 1'b0; // alu
				op1_mux_select = 2'b01; // register instructions [1:0]
				op2_mux_select = 2'b01; //immeidate 
				select_immediate = 2'b11; //sets immediates values to 0
				select_write_address = 2'b10; //writes to reg_Field1 
				alu_add_sub = 1'b0; // required to copy it to register
				increment_pc = 1'b1; //increment pc 
				next_state_logic = FETCH;
			end
// MOVR
			MOVR: begin
				load_temp_register = 1'b1; //enable temp register
				next_state_logic = MOVR_STAGE2; 
				
			end
			MOVR_STAGE2: begin
				if (temp_is_zero) begin 
					increment_pc = 1'b1; 
					next_state_logic = FETCH; 
				end
				else begin
					start_delay_counter = 1'b1; //already writen to RF[3]
					op1_mux_select = 2'b10; //position
					op2_mux_select = 2'b11; //constant 2 
					result_mux_select = 1'b0; // goes to alu
					select_write_address = 2'b11; // writes to RF[2] 
					write_reg_file = 1'b1; //writes to regfile
					
					if (temp_is_positive) begin
						decrement_temp_register = 1'b1; //decreases temp
						alu_add_sub = 1'b0; //adds them together so RF[2] + 2
					end
					else begin // temp_is_negative
						increment_temp_register = 1'b1; // increases temp
						alu_add_sub = 1'b1; //subs them together so RF[2] - 2
					end
					next_state_logic=MOVR_DELAY; // goes to MOVR_DELAY
				end
			end
			MOVR_DELAY: begin
				enable_delay_counter = 1'b1; //delay counter enabled
				if (delay_done) 
					next_state_logic = MOVR_STAGE2; 
				else 
					next_state_logic = MOVR_DELAY; 
			end
// MOVRHS
			MOVRHS: begin
				load_temp_register = 1'b1; //enable temp register
				next_state_logic = MOVRHS_STAGE2; 
			end
			MOVRHS_STAGE2: begin
				if (temp_is_zero) begin
					increment_pc = 1'b1; 
					next_state_logic = FETCH; 
				end
				else begin
					start_delay_counter = 1'b1; //already writen to RF[3]
					op1_mux_select = 2'b10; //position
					op2_mux_select = 2'b10; //constant 1 for half-step 
					result_mux_select = 1'b0; // goes to alu
					select_write_address = 2'b11; // writes to RF[2] 
					write_reg_file = 1'b1; //writes to regfile
					
					if (temp_is_positive) begin
						decrement_temp_register = 1'b1; //decreases temp
						alu_add_sub = 1'b0; //adds them together so RF[2] + 2
					end
					else begin // temp_is_negative
						increment_temp_register = 1'b1; // increases temp
						alu_add_sub = 1'b1; //subs them together so RF[2] - 2
					end
					next_state_logic=MOVRHS_DELAY; // goes to MOVR_DELAY
				end
			end
			MOVRHS_DELAY: begin
				enable_delay_counter = 1'b1; //delay counter enabled
				if (delay_done) 
					next_state_logic = MOVRHS_STAGE2; 
				else 
					next_state_logic = MOVRHS_DELAY; 
			end
// MOVA
			
			
			MOVA: begin
				load_temp_register = 1'b1; //temp as target register
				next_state_logic = MOVA_STAGE2;
			end
			MOVA_STAGE2: begin
				if (temp_is_zero) begin
					increment_pc = 1'b1; 
					next_state_logic = FETCH; 
				end
				else begin
					write_reg_file = 1'b1; //writes to regfile
					result_mux_select = 1'b0; // uses alu
					op1_mux_select = 2'b10; //retrieves position 
					select_write_address = 2'b11; //writes to position
					op2_mux_select = 2'b10; //1 half-step 	
					start_delay_counter = 1'b1; 
					
					if (temp_is_negative) begin //move backwards	
						alu_add_sub = 1'b1; //subtract
						increment_temp_register =1'b1; 
					end 
					else begin 
						alu_add_sub = 1'b0; //add
						decrement_temp_register = 1'b1; 
					end
					next_state_logic = MOVA_DELAY;
				end
			end
		
			MOVA_DELAY: begin
				enable_delay_counter = 1'b1; 
				if (delay_done) 
					next_state_logic = MOVA_STAGE2; 
				else 
					next_state_logic = MOVA_DELAY; 
			end
			PAUSE: begin
				start_delay_counter = 1'b1; // starts the delay counter
				next_state_logic = PAUSE_DELAY; 
			end
			PAUSE_DELAY: begin
				enable_delay_counter = 1'b1; //enables delay counter;
				if (delay_done) begin
					increment_pc = 1'b1; //increases pc
					next_state_logic = FETCH; //exits loop 
				end
				else
					next_state_logic = PAUSE_DELAY; 
			end
			
	// added because good practice 
			default: begin
				next_state_logic = FETCH; 
				write_reg_file = 1'b0;
				result_mux_select = 1'b0;
				op1_mux_select[1:0] =2'b0;
				op2_mux_select[1:0] = 2'b0;
				start_delay_counter = 1'b0; 
				enable_delay_counter= 1'b0;
				commit_branch =1'b0; 
				increment_pc = 1'b0; 
				alu_add_sub = 1'b0;
				alu_set_low = 1'b0; 
				alu_set_high = 1'b0;
				load_temp_register = 1'b0;
				increment_temp_register = 1'b0;
				decrement_temp_register = 1'b0; 
				select_immediate[1:0] = 2'b0;
				select_write_address[1:0] = 2'b0; 
			end
		endcase 
	end
		// Output logic
endmodule
