module immediate_extractor (input [4:0] instruction, input [1:0] select, output reg [7:0] immediate);

	always @(*) begin
		  case (select)
				2'b00: begin
					 immediate[7:0] = {5'b00000, instruction[4:2]};
				end
				2'b01: begin
					 immediate[7:0] = {4'b0000, instruction[3:0]};
				end
				2'b10: begin
					 immediate[7:0] = {instruction[4], instruction[4], instruction[4], instruction[4:0]};
				end
				2'b11: begin
					 immediate[7:0] = 8'b0;
				end
				default: begin
					 immediate[7:0] = 8'b0;
				end
		  endcase
	end 

endmodule
