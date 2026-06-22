module temp_register (input clk, reset_n, load, increment, decrement, input signed [7:0] data,
					output negative, positive, zero); // changed data to signed to make it simpler and the code work
	
	reg signed [7:0] halfsteps; //signed since temp can be negative or positive
	
	assign positive = (halfsteps>0); 
	assign zero =  (halfsteps==0);
	assign negative = (halfsteps<0); 
		
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			halfsteps <= 0;
		end
		else if(load) begin
			halfsteps <= data; 
		end
		else if(increment) begin
			halfsteps <=halfsteps +1;
		end
		else if(decrement) begin
			halfsteps <=halfsteps-1;
		end
	end
					
endmodule
