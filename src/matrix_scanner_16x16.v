`timescale 1ns / 1ps
module matrix_shift_scanner_with_ctrl (
    input clk,
    input master_rst,
    input fsync,
    input intg,
    output reg [15:0] row,  // Changed to 16-bit for 16 rows
    output reg [15:0] col   // Changed to 16-bit for 16 columns
);
    // State encoding 
    parameter IDLE                  = 4'd0,
              WAIT_INTG_RISE        = 4'd1,
              WAIT_INTG_FALL        = 4'd2,
              DELAY_AFTER_INTG_FALL = 4'd3,
              ROW_SETUP             = 4'd4,
              COL_DELAY             = 4'd5,
              COL_SCAN              = 4'd6,
              NEXT_ROW              = 4'd7,
              FRAME_DONE            = 4'd8;
    
    reg [3:0] state;
    reg [1:0] delay_counter;
    reg [4:0] col_counter;  // Changed to 5-bit to count 0-15
    reg [4:0] row_counter;  // Changed to 5-bit to count 0-15
    reg prev_fsync, prev_intg;
    
    // Edge detection
    wire fsync_rise = fsync & ~prev_fsync;
    wire intg_rise  = intg  & ~prev_intg;
    wire intg_fall  = ~intg & prev_intg;
    
    always @(posedge clk or posedge master_rst) begin
        if (master_rst) begin
            state        <= IDLE;
            row          <= 16'b0000000000000000;
            col          <= 16'b0000000000000000;
            delay_counter<= 0;
            col_counter  <= 0;
            row_counter  <= 0;
            prev_fsync   <= 0;
            prev_intg    <= 0;
        end else begin
            prev_fsync <= fsync;
            prev_intg  <= intg;
            
            case (state)
                IDLE: begin
                    row <= 16'b0000000000000000;
                    col <= 16'b0000000000000000;
                    if (fsync_rise)
                        state <= WAIT_INTG_RISE;
                end
                
                WAIT_INTG_RISE: begin
                    // Wait for intg rising edge
                    if (intg_rise)
                        state <= WAIT_INTG_FALL;
                end
                
                WAIT_INTG_FALL: begin
                    // Wait for intg falling edge
                    if (intg_fall) begin
                        delay_counter <= 0;
                        state <= DELAY_AFTER_INTG_FALL;
                    end
                end
                
                DELAY_AFTER_INTG_FALL: begin
                    // Wait 2 cycles after intg falls
                    if (delay_counter == 1) begin
                        state <= ROW_SETUP;
                        row_counter <= 0;
                    end else begin
                        delay_counter <= delay_counter + 1;
                    end
                end
                
                ROW_SETUP: begin
                    // Set row using shift pattern (one-hot encoding)
                    row <= 16'b0000000000000001 << row_counter;
                    col <= 16'b0000000000000000; // Clear column
                    state <= COL_DELAY;
                end
                
                COL_DELAY: begin
                    col <= 16'b0000000000000000; // Clear column before starting scan
                    state <= COL_SCAN;
                    col_counter <= 0;
                end
                
                COL_SCAN: begin
                    // Set column using shift pattern (one-hot encoding)
                    col <= 16'b0000000000000001 << col_counter;
                    
                    if (col_counter < 15) begin  // Changed from 2 to 15
                        col_counter <= col_counter + 1;
                    end else begin
                        state <= NEXT_ROW;
                    end
                end
                
                NEXT_ROW: begin
                    row <= 16'b0000000000000000;
                    col <= 16'b0000000000000000;
                    if (row_counter == 15)  // Changed from 2 to 15
                        state <= FRAME_DONE;
                    else begin
                        row_counter <= row_counter + 1;
                        state <= ROW_SETUP;
                    end
                end
                
                FRAME_DONE: begin
                    row <= 16'b0000000000000000;
                    col <= 16'b0000000000000000;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule