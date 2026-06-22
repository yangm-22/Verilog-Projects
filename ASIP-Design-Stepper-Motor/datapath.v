module datapath (input clk, reset_n,
				// Control signals
				input write_reg_file, result_mux_select,
				input [1:0] op1_mux_select, op2_mux_select,
				input start_delay_counter, enable_delay_counter,
				input commit_branch, increment_pc,
				input alu_add_sub, alu_set_low, alu_set_high,
				input load_temp, increment_temp, decrement_temp,
				input [1:0] select_immediate,
				input [1:0] select_write_address,
				// Status outputs
				output br, brz, addi, subi, sr0, srh0, clr, mov, mova, movr, movrhs, pause,
				output delay_done,
				output temp_is_positive, temp_is_negative, temp_is_zero,
				output register0_is_zero,
				// Motor control outputs
				output [3:0] stepper_signals
);
// The comment /*synthesis keep*/ after the declaration of a wire
// prevents Quartus from optimizing it, so that it can be observed in simulation
// It is important that the comment appear before the semicolon
wire [7:0] position /*synthesis keep*/;
wire [7:0] delay /*synthesis keep*/;
wire [7:0] register0 /*synthesis keep*/;

// Based on our values labeled in Appendix B
wire [7:0] instruction_out /*synthesis keep*/; 
wire [7:0] PC_out /*synthesis keep*/;
wire [7:0] ALU_out /*synthesis keep*/;
wire [7:0] sel0_out /*synthesis keep*/;
wire [7:0] sel1_out /*synthesis keep*/;
wire [7:0] immed_op_out /*synthesis keep*/;
wire [7:0] muxres_out /*synthesis keep*/;
wire [7:0] mux1_out /*synthesis keep*/;
wire [7:0] mux2_out /*synthesis keep*/;
wire [1:0] w_addr_sel /*synthesis keep*/;

decoder the_decoder (
	// Inputs
	.instruction (instruction_out[7:0]),
	// Outputs
	.br (br),
	.brz (brz),
	.addi (addi),
	.subi (subi),
	.sr0 (sr0),
	.srh0 (srh0),
	.clr (clr),
	.mov (mov),
	.mova (mova),
	.movr (movr),
	.movrhs (movrhs),
	.pause (pause)
);
regfile the_regfile(
	// Inputs
	.clk (clk),
	.reset_n (reset_n),
	.write (write_reg_file),
	.data (muxres_out), 
	.select0 (instruction_out[1:0]),
	.select1 (instruction_out[3:2]),
	.wr_select (w_addr_sel),
	// Outputs
	.selected0 (sel0_out),
	.selected1 (sel1_out),
	.delay (delay),
	.position (position),
	.register0 (register0)
);

op1_mux the_op1_mux(
	// Inputs
	.select (op1_mux_select),
	.pc (PC_out),
	.register (sel0_out),
	.register0 (register0),
	.position (position),
	// Outputs
	.result(mux1_out)
);

op2_mux the_op2_mux(
	// Inputs
	.select (op2_mux_select),
	.register (sel1_out),
	.immediate (immed_op_out),
	// Outputs
	.result (mux2_out)
);

delay_counter the_delay_counter(
	// Inputs
	.clk(clk),
	.reset_n (reset_n),
	.start (start_delay_counter),
	.enable (enable_delay_counter),
	.delay (delay),
	// Outputs
	.done (delay_done)
);

stepper_rom the_stepper_rom(
	// Inputs
	.address (position[2:0]),
	.clock (clk),
	// Outputs
	.q (stepper_signals)
);

pc the_pc(
	// Inputs
	.clk (clk),
	.reset_n (reset_n),
	.branch (commit_branch),
	.increment (increment_pc),
	.newpc (ALU_out),
	// Outputs
	.pc (PC_out)
);

instruction_rom the_instruction_rom(
	// Inputs
	.address (PC_out),
	.clock (clk),
	// Outputs
	.q (instruction_out)
);

alu the_alu(
	// Inputs
	.add_sub (alu_add_sub),
	.set_low (alu_set_low),
	.set_high (alu_set_high),
	.operanda (mux1_out),
	.operandb (mux2_out),
	// Outputs
	.result (ALU_out)
);

temp_register the_temp_register(
	// Inputs
	.clk (clk),
	.reset_n (reset_n),
	.load (load_temp),
	.increment (increment_temp),
	.decrement (decrement_temp),
	.data (sel0_out),
	// Outputs
	.negative (temp_is_negative),
	.positive (temp_is_positive),
	.zero (temp_is_zero)
);

immediate_extractor the_immediate_extractor(
	// Inputs
	.instruction (instruction_out[4:0]),
	.select (select_immediate),
	// Outputs
	.immediate (immed_op_out)
);

write_address_select the_write_address_select(
	// Inputs
	.select (select_write_address),
	.reg_field0 (instruction_out[1:0]),
	.reg_field1 (instruction_out[3:2]),
	// Outputs
	.write_address(w_addr_sel)
);

result_mux the_result_mux (
	.select_result (result_mux_select),
	.alu_result (ALU_out),
	.result (muxres_out)
);

branch_logic the_branch_logic(
	// Inputs
	.register0 (register0),
	// Outputs
	.branch (register0_is_zero)
);

endmodule
