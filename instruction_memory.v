module instruction_memory (
    input [3:0] pc,              
    output reg [15:0] instruction 
);

    // Memory array: 16 rows, 16 bits wide
    reg [15:0] memory [15:0];

    initial begin
        // Format: {Opcode(3), Rd(2), Rs(2), Flag(1), Immediate(8)}
        // 0000: LOAD R1, 2  
        memory[4'b0000] = 16'b000_01_00_0_00000010; 
        // 0001: LOAD R2, 8 
        memory[4'b0001] = 16'b000_10_00_0_00001000; 
        // 0010: ADD R1, R2  
        memory[4'b0010] = 16'b001_01_10_0_00000000; 
        // 0011: LOAD R2, 10
        memory[4'b0011] = 16'b000_10_00_0_00001010; 
        // 0100: AND R1, R2    
        memory[4'b0100] = 16'b011_00_01_0_00000000; 
        // 0101: STORE R1       
        memory[4'b0101] = 16'b110_00_01_0_00000000; 

        // Fill remaining memory with HALT
        memory[4'b0110] = 16'b111_00_00_0_00000000;
        memory[4'b0111] = 16'b111_00_00_0_00000000;
        memory[4'b1000] = 16'b111_00_00_0_00000000;
        memory[4'b1001] = 16'b111_00_00_0_00000000;
        memory[4'b1010] = 16'b111_00_00_0_00000000;
        memory[4'b1011] = 16'b111_00_00_0_00000000;
        memory[4'b1100] = 16'b111_00_00_0_00000000;
        memory[4'b1101] = 16'b111_00_00_0_00000000;
        memory[4'b1110] = 16'b111_00_00_0_00000000;
        memory[4'b1111] = 16'b111_00_00_0_00000000;
    end

    always @(*) begin
        instruction = memory[pc];
    end

endmodule