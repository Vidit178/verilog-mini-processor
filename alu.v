module alu (
    input [7:0] operand1,     
    input [7:0] operand2,     
    input [2:0] alu_control,  
    output reg [7:0] alu_result 
);

    always @(*) begin
        case (alu_control)
            3'b001: alu_result = operand1 + operand2; // ADD
            3'b010: alu_result = operand1 - operand2; // SUB
            3'b011: alu_result = operand1 & operand2; // AND
            3'b100: alu_result = operand1 | operand2; // OR
            3'b101: alu_result = operand2;            // MOV
            default: alu_result = 8'b00000000;        
        endcase
    end

endmodule