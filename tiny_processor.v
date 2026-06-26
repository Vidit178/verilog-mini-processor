module tiny_processor (
    input clk,
    input reset,
    output reg [7:0] final_output, 
    output [1:0] fsm_state         
);

    wire [3:0] pc_wire;
    wire [15:0] instruction_wire;
    
    wire reg_write_wire;
    wire use_imm_wire;
    wire pc_update_wire;  
    wire store_en_wire;            
    wire [2:0] alu_control_wire;
    wire [1:0] read_reg1_wire;
    wire [1:0] read_reg2_wire;
    wire [1:0] write_reg_wire;
    wire [7:0] imm_out_wire;
    
    wire [7:0] read_data1_wire;
    wire [7:0] read_data2_wire;
    wire [7:0] alu_result_wire;

    wire [7:0] alu_operand2 = use_imm_wire ? imm_out_wire : read_data2_wire;

    // Output Register Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            final_output <= 8'b00000000;
        end else if (store_en_wire) begin
            final_output <= read_data2_wire; 
        end
    end

    program_counter pc_module (
        .clk(clk),
        .reset(reset),
        .pc_update(pc_update_wire), 
        .pc(pc_wire)
    );

    instruction_memory imem_module (
        .pc(pc_wire),
        .instruction(instruction_wire)
    );

    control_unit cu_module (
        .clk(clk),                  
        .reset(reset),              
        .instruction(instruction_wire),
        .reg_write(reg_write_wire),
        .use_imm(use_imm_wire),
        .pc_update(pc_update_wire), 
        .store_en(store_en_wire),      
        .alu_control(alu_control_wire),
        .read_reg1(read_reg1_wire),
        .read_reg2(read_reg2_wire),
        .write_reg(write_reg_wire),
        .imm_out(imm_out_wire),
        .fsm_state(fsm_state)          
    );

    register_file reg_file_module (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write_wire),
        .read_reg1(read_reg1_wire),
        .read_reg2(read_reg2_wire),
        .write_reg(write_reg_wire),
        .write_data(alu_result_wire),
        .read_data1(read_data1_wire),
        .read_data2(read_data2_wire)
    );

    alu alu_module (
        .operand1(read_data1_wire),
        .operand2(alu_operand2),
        .alu_control(alu_control_wire),
        .alu_result(alu_result_wire)
    );

endmodule