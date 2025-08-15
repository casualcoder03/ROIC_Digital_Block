`timescale 1ns / 1ps
module tb_matrix_shift_scanner_with_ctrl;
    // Testbench signals
    reg clk;
    reg master_rst;
    reg fsync;
    reg intg;
    wire [15:0] row;  // Changed to 16-bit
    wire [15:0] col;  // Changed to 16-bit
    
    // Instantiate the DUT
    matrix_shift_scanner_with_ctrl dut (
        .clk(clk),
        .master_rst(master_rst),
        .fsync(fsync),
        .intg(intg),
        .row(row),
        .col(col)
    );
    
    // Clock generation: 100 MHz (10ns period)
    always #5 clk = ~clk;
    
    initial begin
        // Initialize
        clk = 0;
        master_rst = 1;
        fsync = 0;
        intg = 0;
        #100;
        master_rst = 0;
        #50;
        
        // Repeat frame cycles as long as desired
        forever begin  
            // fsync pulse (1 cycle)
            fsync = 1;
            #10;           // 1 clock cycle
            fsync = 0;
            
            // Wait 1 clock cycle before intg
            #10;
            
            // intg pulse (10 cycles)
            intg = 1;
            #100;          // 10 clock cycles
            intg = 0;
            
            // Wait for scanning to complete 
            // 16x16 matrix: 16 rows * 16 cols * ~3 clocks per position + overhead
            #8000;  // Increased wait time for full 16x16 scan        
        end
    end
    
    // Enhanced monitor for 16x16 matrix - show actual bit positions
    initial begin
        $monitor("T=%0t | fsync=%b intg=%b | row=%h col=%h | state=%0d", 
                 $time, fsync, intg, row, col, dut.state);
    end
    
    // Additional monitor to track scanning progress
    always @(posedge clk) begin
        if (row != 0 && col != 0) begin
            $display("Active scan at T=%0t: row=%h col=%h (row_idx=%0d, col_idx=%0d)", 
                     $time, row, col, dut.row_counter, dut.col_counter);
        end
    end
    
endmodule