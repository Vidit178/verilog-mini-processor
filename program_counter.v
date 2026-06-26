module program_counter (
    input clk,
    input reset,
    input pc_update,        // FSM tells PC when to increment
    output reg [3:0] pc     // 4-bit address output
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 4'b0000;  // Start at address 0
        end else if (pc_update) begin
            pc <= pc + 1;   // Increment only when FSM says so
        end
    end

endmodule