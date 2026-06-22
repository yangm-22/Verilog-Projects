module delay_counter (input clk, reset_n, start, enable, input [7:0] delay, output reg done);
parameter BASIC_PERIOD=20'd500000;   // can change this value to make delay longer

    reg [19:0] count_cycle;
    reg [7:0] count_delay;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count_cycle <= 20'b0;
            count_delay <= 8'b0;
            done <= 1'b0;
        end
        else if (start) begin
            count_cycle <= 20'b0;
            count_delay <= delay;
            done <= 1'b0;    
        end

        else if (enable) begin
            if (count_cycle < BASIC_PERIOD - 1) begin
                count_cycle <= count_cycle + 1;
            end
            else begin 
                count_cycle <= 20'b0;
                if (count_delay > 0) begin
                    count_delay <= count_delay - 1;
                end
                if (count_delay == 1) begin
                    done <= 1;
                end
                else begin
                    done <= 0;
                end
            end
        end
        else begin
            done <= 0;
        end
    end


endmodule
