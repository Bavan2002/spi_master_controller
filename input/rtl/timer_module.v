//==============================================================================
// Timer Module - Generates Counter and Period Signal
// Provides timing base for all PWM channels
// For EN4603 Digital IC Design Assignment
//==============================================================================

`timescale 1ns/1ps

module timer_module (
    // Clock and Reset
    input wire clk,                    // System clock
    input wire reset,                  // Active high reset
    
    // Configuration Interface
    input wire [7:0] period,           // PWM period (0-255)
    input wire [7:0] prescaler,        // Clock prescaler (0-255)
    input wire timer_enable,           // Enable timer
    
    // Timer Outputs
    output reg [7:0] counter,          // Current counter value
    output reg period_complete,        // Pulse when period completes
    output reg timer_overflow          // Overflow flag
);

    // Internal registers
    reg [7:0] prescaler_count;
    reg [7:0] period_reg;
    reg prescaler_tick;
    
    // Prescaler counter - divides system clock
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            prescaler_count <= 8'd0;
            prescaler_tick <= 1'b0;
        end else if (timer_enable) begin
            if (prescaler_count >= prescaler) begin
                prescaler_count <= 8'd0;
                prescaler_tick <= 1'b1;
            end else begin
                prescaler_count <= prescaler_count + 8'd1;
                prescaler_tick <= 1'b0;
            end
        end else begin
            prescaler_count <= 8'd0;
            prescaler_tick <= 1'b0;
        end
    end
    
    // Capture period value
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            period_reg <= 8'd255;  // Default full period
        end else if (!timer_enable) begin
            period_reg <= period;
        end
    end
    
    // Main counter - counts prescaled ticks
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 8'd0;
            period_complete <= 1'b0;
            timer_overflow <= 1'b0;
        end else if (timer_enable) begin
            if (prescaler_tick) begin
                if (counter >= period_reg) begin
                    counter <= 8'd0;
                    period_complete <= 1'b1;
                    timer_overflow <= 1'b0;
                end else begin
                    counter <= counter + 8'd1;
                    period_complete <= 1'b0;
                    
                    // Check for overflow
                    if (counter == 8'd255) begin
                        timer_overflow <= 1'b1;
                    end else begin
                        timer_overflow <= 1'b0;
                    end
                end
            end else begin
                period_complete <= 1'b0;
                timer_overflow <= 1'b0;
            end
        end else begin
            counter <= 8'd0;
            period_complete <= 1'b0;
            timer_overflow <= 1'b0;
        end
    end

endmodule
