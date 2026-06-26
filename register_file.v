module register_file (
    input clk,
    input reset,
    input reg_write,          
    input [1:0] read_reg1,    
    input [1:0] read_reg2,    
    input [1:0] write_reg,    
    input [7:0] write_data,   
    output [7:0] read_data1,  
    output [7:0] read_data2   
);

    reg [7:0] registers [3:0];

    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            registers[0] <= 8'b00000000;
            registers[1] <= 8'b00000000;
            registers[2] <= 8'b00000000;
            registers[3] <= 8'b00000000;
        end else if (reg_write) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule