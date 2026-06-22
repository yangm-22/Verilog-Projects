// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module shiftregister (
	clock,
	shiftin,
	shiftout,
	taps);

	input	  clock;
	input	[15:0]  shiftin;
	output	[15:0]  shiftout;
	output	[511:0]  taps;

	wire [15:0] sub_wire0;
	wire [511:0] sub_wire1;
	wire [15:0] shiftout = sub_wire0[15:0];
	wire [511:0] taps = sub_wire1[511:0];

	altshift_taps	ALTSHIFT_TAPS_component (
				.clock (clock),
				.shiftin (shiftin),
				.shiftout (sub_wire0),
				.taps (sub_wire1)
				// synopsys translate_off
				,
				.aclr (),
				.clken (),
				.sclr ()
				// synopsys translate_on
				);
	defparam
		ALTSHIFT_TAPS_component.intended_device_family = "Cyclone V",
		ALTSHIFT_TAPS_component.lpm_hint = "RAM_BLOCK_TYPE=MLAB",
		ALTSHIFT_TAPS_component.lpm_type = "altshift_taps",
		ALTSHIFT_TAPS_component.number_of_taps = 64,
		ALTSHIFT_TAPS_component.tap_distance = 30,
		ALTSHIFT_TAPS_component.width = 16;
endmodule
