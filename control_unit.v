module control_unit (
    input clk,                  
    input reset,                
    input [15:0] instruction,   
    output reg reg_write,       
    output reg use_imm,         
    output reg pc_update,       
    output reg store_en,        
    output reg [2:0] alu_control, 
    output [1:0] read_reg1,     
    output [1:0] read_reg2,     
    output [1:0] write_reg,     
    output [7:0] imm_out,
    output [1:0] fsm_state      
);

    parameter FETCH     = 2'b00;
    parameter DECODE    = 2'b01;
    parameter EXECUTE   = 2'b10;
    parameter WRITEBACK = 2'b11;
    
    reg [1:0] current_state, next_state;

    wire [2:0] opcode = instruction[15:13];
    assign write_reg  = instruction[12:11];
    assign read_reg1  = instruction[12:11];
    assign read_reg2  = instruction[10:9];
    assign imm_out    = instruction[7:0];
    assign fsm_state  = current_state; 

    // State Memory 
    always @(posedge clk or posedge reset) begin
        if (reset) current_state <= FETCH;
        else current_state <= next_state;
    end

    // Next State Logic 
    always @(*) begin
        case (current_state)
            FETCH:     next_state = (opcode == 3'b111) ? FETCH : DECODE;
            DECODE:    next_state = EXECUTE;
            EXECUTE:   next_state = WRITEBACK;
            WRITEBACK: next_state = FETCH;
            default:   next_state = FETCH;
        endcase
    end

    // Output Logic 
    always @(*) begin
        reg_write   = 1'b0;
        pc_update   = 1'b0;
        use_imm     = 1'b0;
        store_en    = 1'b0;  
        alu_control = 3'b000;

        if (current_state == EXECUTE || current_state == WRITEBACK) begin
            case (opcode)
                3'b000: begin 
                    use_imm     = 1'b1;       
                    alu_control = 3'b101; 
                end     
                3'b001: alu_control = 3'b001;     
                3'b010: alu_control = 3'b010;     
                3'b011: alu_control = 3'b011;     
                3'b100: alu_control = 3'b100;     
                3'b101: alu_control = 3'b101;     
                default: ; 
            endcase
        end

        if (current_state == WRITEBACK) begin
            if (opcode == 3'b110) begin
                store_en = 1'b1; 
            end else if (opcode != 3'b111) begin
                reg_write = 1'b1;
            end
            pc_update = 1'b1;
        end
    end

endmodule