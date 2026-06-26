module testbench;

    reg clk;
    reg reset;
    wire [7:0] final_output;
    wire [1:0] fsm_state;

    tiny_processor uut (
        .clk(clk),
        .reset(reset),
        .final_output(final_output),
        .fsm_state(fsm_state)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, testbench); 

        clk = 0;
        reset = 1;

        #10; 
        reset = 0; 

        // Increased time to allow the multi-cycle processor to finish
        #300;

        $display("Simulation complete. Check processor.vcd in GTKWave.");
        $finish;
    end

endmodule