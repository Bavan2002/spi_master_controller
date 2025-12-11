//==============================================================================
// PWM Controller - Top Level Module
// 3-Channel PWM Controller with Shared Timer
// For EN4603 Digital IC Design Assignment
//==============================================================================

`timescale 1ns/1ps

module pwm_controller (
    // Clock and Reset
    input wire clk,                    // System clock (50MHz)
    input wire reset,                  // Active high reset
    
    // Timer Configuration
    input wire [7:0] period,           // PWM period (0-255)
    input wire [7:0] prescaler,        // Clock prescaler (0-255)
    input wire timer_enable,           // Enable timer
    
    // Channel 0 Control
    input wire ch0_enable,             // Enable channel 0
    input wire [7:0] ch0_duty_cycle,   // Duty cycle for channel 0
    
    // Channel 1 Control
    input wire ch1_enable,             // Enable channel 1
    input wire [7:0] ch1_duty_cycle,   // Duty cycle for channel 1
    
    // Channel 2 Control
    input wire ch2_enable,             // Enable channel 2
    input wire [7:0] ch2_duty_cycle,   // Duty cycle for channel 2
    
    // PWM Outputs
    output wire pwm_out_0,             // PWM output channel 0
    output wire pwm_out_1,             // PWM output channel 1
    output wire pwm_out_2,             // PWM output channel 2
    
    // Status Outputs
    output wire period_complete,       // Period completion pulse
    output wire timer_overflow         // Timer overflow flag
);

    //==========================================================================
    // Internal Signals
    //==========================================================================
    wire [7:0] counter;                // Shared counter from timer
    
    //==========================================================================
    // Timer Module Instance
    // Generates shared timing base for all PWM channels
    //==========================================================================
    timer_module timer_inst (
        .clk(clk),
        .reset(reset),
        .period(period),
        .prescaler(prescaler),
        .timer_enable(timer_enable),
        .counter(counter),
        .period_complete(period_complete),
        .timer_overflow(timer_overflow)
    );
    
    //==========================================================================
    // PWM Channel 0 Instance
    //==========================================================================
    pwm_generator pwm_ch0 (
        .clk(clk),
        .reset(reset),
        .enable(ch0_enable),
        .duty_cycle(ch0_duty_cycle),
        .counter(counter),
        .pwm_out(pwm_out_0)
    );
    
    //==========================================================================
    // PWM Channel 1 Instance
    //==========================================================================
    pwm_generator pwm_ch1 (
        .clk(clk),
        .reset(reset),
        .enable(ch1_enable),
        .duty_cycle(ch1_duty_cycle),
        .counter(counter),
        .pwm_out(pwm_out_1)
    );
    
    //==========================================================================
    // PWM Channel 2 Instance
    //==========================================================================
    pwm_generator pwm_ch2 (
        .clk(clk),
        .reset(reset),
        .enable(ch2_enable),
        .duty_cycle(ch2_duty_cycle),
        .counter(counter),
        .pwm_out(pwm_out_2)
    );

endmodule

//==============================================================================
// Module Hierarchy:
//
// pwm_controller (TOP)
//   ├── timer_module
//   │     └── prescaler + counter logic
//   ├── pwm_generator (channel 0)
//   ├── pwm_generator (channel 1)
//   └── pwm_generator (channel 2)
//
// Features:
// - 3 independent PWM output channels
// - Shared timer for synchronized operation
// - 8-bit resolution for duty cycle (0-255 = 0-100%)
// - Configurable period and prescaler
// - Individual channel enable/disable
// - Period complete and overflow status signals
//
// Applications:
// - LED brightness control (3 RGB channels)
// - Motor speed control (3 motors)
// - Power regulation
// - Signal generation
//==============================================================================
