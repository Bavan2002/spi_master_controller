//==============================================================================
// PWM Generator Module - Individual PWM Channel
// Generates PWM output based on duty cycle and period counter
// For EN4603 Digital IC Design Assignment
//==============================================================================

`timescale 1ns/1ps

module pwm_generator (
    // Clock and Reset
    input wire clk,              // System clock
    input wire reset,            // Active high reset
    
    // Control Interface
    input wire enable,           // Enable PWM output
    input wire [7:0] duty_cycle, // Duty cycle (0-255 = 0-100%)
    
    // Timer Interface
    input wire [7:0] counter,    // Counter value from timer
    
    // PWM Output
    output reg pwm_out           // PWM output signal
);

    // Internal registers
    reg [7:0] duty_reg;
    reg pwm_active;
    
    // Capture duty cycle on enable
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            duty_reg <= 8'd0;
        end else if (enable) begin
            duty_reg <= duty_cycle;
        end
    end
    
    // Generate PWM signal by comparing counter with duty cycle
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_out <= 1'b0;
            pwm_active <= 1'b0;
        end else begin
            if (enable) begin
                pwm_active <= 1'b1;
                // PWM high when counter < duty_cycle
                if (counter < duty_reg) begin
                    pwm_out <= 1'b1;
                end else begin
                    pwm_out <= 1'b0;
                end
            end else begin
                pwm_active <= 1'b0;
                pwm_out <= 1'b0;
            end
        end
    end

endmodule
