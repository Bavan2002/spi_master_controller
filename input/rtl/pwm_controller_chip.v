//==============================================================================
// PWM Controller Chip - Top Level with IO Pads
// Wrapper module for Lab 3 - IO Pad Ring Integration
// For EN4603 Digital IC Design Assignment
//==============================================================================

`timescale 1ns/1ps

module pwm_controller_chip (
    // Note: Power pads (VDD/VSS/VDDIO/VSSIO) don't have PAD ports
    // They connect internally to supply1/supply0 nets
    
    // External IO Pads - System Signals
    inout wire PAD_clk,
    inout wire PAD_reset,
    
    // External IO Pads - Timer Configuration
    inout wire PAD_period_0,
    inout wire PAD_period_1,
    inout wire PAD_period_2,
    inout wire PAD_period_3,
    inout wire PAD_period_4,
    inout wire PAD_period_5,
    inout wire PAD_period_6,
    inout wire PAD_period_7,
    
    inout wire PAD_prescaler_0,
    inout wire PAD_prescaler_1,
    inout wire PAD_prescaler_2,
    inout wire PAD_prescaler_3,
    inout wire PAD_prescaler_4,
    inout wire PAD_prescaler_5,
    inout wire PAD_prescaler_6,
    inout wire PAD_prescaler_7,
    
    inout wire PAD_timer_enable,
    
    // External IO Pads - Channel 0
    inout wire PAD_ch0_enable,
    inout wire PAD_ch0_duty_0,
    inout wire PAD_ch0_duty_1,
    inout wire PAD_ch0_duty_2,
    inout wire PAD_ch0_duty_3,
    inout wire PAD_ch0_duty_4,
    inout wire PAD_ch0_duty_5,
    inout wire PAD_ch0_duty_6,
    inout wire PAD_ch0_duty_7,
    
    // External IO Pads - Channel 1
    inout wire PAD_ch1_enable,
    inout wire PAD_ch1_duty_0,
    inout wire PAD_ch1_duty_1,
    inout wire PAD_ch1_duty_2,
    inout wire PAD_ch1_duty_3,
    inout wire PAD_ch1_duty_4,
    inout wire PAD_ch1_duty_5,
    inout wire PAD_ch1_duty_6,
    inout wire PAD_ch1_duty_7,
    
    // External IO Pads - Channel 2
    inout wire PAD_ch2_enable,
    inout wire PAD_ch2_duty_0,
    inout wire PAD_ch2_duty_1,
    inout wire PAD_ch2_duty_2,
    inout wire PAD_ch2_duty_3,
    inout wire PAD_ch2_duty_4,
    inout wire PAD_ch2_duty_5,
    inout wire PAD_ch2_duty_6,
    inout wire PAD_ch2_duty_7,
    
    // External IO Pads - PWM Outputs
    inout wire PAD_pwm_out_0,
    inout wire PAD_pwm_out_1,
    inout wire PAD_pwm_out_2,
    
    // External IO Pads - Status Signals
    inout wire PAD_period_complete,
    inout wire PAD_timer_overflow
);

    //==========================================================================
    // Internal Core Signals
    //==========================================================================
    wire clk_core, reset_core;
    wire [7:0] period_core;
    wire [7:0] prescaler_core;
    wire timer_enable_core;
    wire ch0_enable_core;
    wire [7:0] ch0_duty_cycle_core;
    wire ch1_enable_core;
    wire [7:0] ch1_duty_cycle_core;
    wire ch2_enable_core;
    wire [7:0] ch2_duty_cycle_core;
    wire pwm_out_0_core, pwm_out_1_core, pwm_out_2_core;
    wire period_complete_core, timer_overflow_core;
    
    //==========================================================================
    // Power Supply Nets (for power pad connections)
    //==========================================================================
    supply1 VDD;      // Core power supply
    supply0 VSS;      // Core ground
    supply1 VDDIOR;   // IO ring power supply
    supply0 VSSIOR;   // IO ring ground
    
    //==========================================================================
    // Corner Pad Cells
    //==========================================================================
    padIORINGCORNER corner_ll ();
    padIORINGCORNER corner_lr ();
    padIORINGCORNER corner_ul ();
    padIORINGCORNER corner_ur ();
    
    //==========================================================================
    // Power Pad Cells (no PAD port - only power supply connections)
    //==========================================================================
    PADVDD vdd_pad0 (.VDD(VDD), .VSS(VSS), .VDDIOR(VDDIOR), .VSSIOR(VSSIOR));
    PADVDD vdd_pad1 (.VDD(VDD), .VSS(VSS), .VDDIOR(VDDIOR), .VSSIOR(VSSIOR));
    PADVSS vss_pad0 (.VDD(VDD), .VSS(VSS), .VDDIOR(VDDIOR), .VSSIOR(VSSIOR));
    PADVSS vss_pad1 (.VDD(VDD), .VSS(VSS), .VDDIOR(VDDIOR), .VSSIOR(VSSIOR));
    PADVDDIOR vddio_pad0 (.VDD(VDD), .VSS(VSS), .VDDIOR(VDDIOR), .VSSIOR(VSSIOR));
    PADVSSIOR vssio_pad0 (.VDD(VDD), .VSS(VSS), .VDDIOR(VDDIOR), .VSSIOR(VSSIOR));
    
    //==========================================================================
    // Input Pad Cells - System Signals
    //==========================================================================
    PADDI pad_clk (.PAD(PAD_clk), .Y(clk_core));
    PADDI pad_reset (.PAD(PAD_reset), .Y(reset_core));
    
    //==========================================================================
    // Input Pad Cells - Period Configuration
    //==========================================================================
    PADDI pad_period_0 (.PAD(PAD_period_0), .Y(period_core[0]));
    PADDI pad_period_1 (.PAD(PAD_period_1), .Y(period_core[1]));
    PADDI pad_period_2 (.PAD(PAD_period_2), .Y(period_core[2]));
    PADDI pad_period_3 (.PAD(PAD_period_3), .Y(period_core[3]));
    PADDI pad_period_4 (.PAD(PAD_period_4), .Y(period_core[4]));
    PADDI pad_period_5 (.PAD(PAD_period_5), .Y(period_core[5]));
    PADDI pad_period_6 (.PAD(PAD_period_6), .Y(period_core[6]));
    PADDI pad_period_7 (.PAD(PAD_period_7), .Y(period_core[7]));
    
    //==========================================================================
    // Input Pad Cells - Prescaler Configuration
    //==========================================================================
    PADDI pad_prescaler_0 (.PAD(PAD_prescaler_0), .Y(prescaler_core[0]));
    PADDI pad_prescaler_1 (.PAD(PAD_prescaler_1), .Y(prescaler_core[1]));
    PADDI pad_prescaler_2 (.PAD(PAD_prescaler_2), .Y(prescaler_core[2]));
    PADDI pad_prescaler_3 (.PAD(PAD_prescaler_3), .Y(prescaler_core[3]));
    PADDI pad_prescaler_4 (.PAD(PAD_prescaler_4), .Y(prescaler_core[4]));
    PADDI pad_prescaler_5 (.PAD(PAD_prescaler_5), .Y(prescaler_core[5]));
    PADDI pad_prescaler_6 (.PAD(PAD_prescaler_6), .Y(prescaler_core[6]));
    PADDI pad_prescaler_7 (.PAD(PAD_prescaler_7), .Y(prescaler_core[7]));
    
    //==========================================================================
    // Input Pad Cell - Timer Enable
    //==========================================================================
    PADDI pad_timer_enable (.PAD(PAD_timer_enable), .Y(timer_enable_core));
    
    //==========================================================================
    // Input Pad Cells - Channel 0
    //==========================================================================
    PADDI pad_ch0_enable (.PAD(PAD_ch0_enable), .Y(ch0_enable_core));
    PADDI pad_ch0_duty_0 (.PAD(PAD_ch0_duty_0), .Y(ch0_duty_cycle_core[0]));
    PADDI pad_ch0_duty_1 (.PAD(PAD_ch0_duty_1), .Y(ch0_duty_cycle_core[1]));
    PADDI pad_ch0_duty_2 (.PAD(PAD_ch0_duty_2), .Y(ch0_duty_cycle_core[2]));
    PADDI pad_ch0_duty_3 (.PAD(PAD_ch0_duty_3), .Y(ch0_duty_cycle_core[3]));
    PADDI pad_ch0_duty_4 (.PAD(PAD_ch0_duty_4), .Y(ch0_duty_cycle_core[4]));
    PADDI pad_ch0_duty_5 (.PAD(PAD_ch0_duty_5), .Y(ch0_duty_cycle_core[5]));
    PADDI pad_ch0_duty_6 (.PAD(PAD_ch0_duty_6), .Y(ch0_duty_cycle_core[6]));
    PADDI pad_ch0_duty_7 (.PAD(PAD_ch0_duty_7), .Y(ch0_duty_cycle_core[7]));
    
    //==========================================================================
    // Input Pad Cells - Channel 1
    //==========================================================================
    PADDI pad_ch1_enable (.PAD(PAD_ch1_enable), .Y(ch1_enable_core));
    PADDI pad_ch1_duty_0 (.PAD(PAD_ch1_duty_0), .Y(ch1_duty_cycle_core[0]));
    PADDI pad_ch1_duty_1 (.PAD(PAD_ch1_duty_1), .Y(ch1_duty_cycle_core[1]));
    PADDI pad_ch1_duty_2 (.PAD(PAD_ch1_duty_2), .Y(ch1_duty_cycle_core[2]));
    PADDI pad_ch1_duty_3 (.PAD(PAD_ch1_duty_3), .Y(ch1_duty_cycle_core[3]));
    PADDI pad_ch1_duty_4 (.PAD(PAD_ch1_duty_4), .Y(ch1_duty_cycle_core[4]));
    PADDI pad_ch1_duty_5 (.PAD(PAD_ch1_duty_5), .Y(ch1_duty_cycle_core[5]));
    PADDI pad_ch1_duty_6 (.PAD(PAD_ch1_duty_6), .Y(ch1_duty_cycle_core[6]));
    PADDI pad_ch1_duty_7 (.PAD(PAD_ch1_duty_7), .Y(ch1_duty_cycle_core[7]));
    
    //==========================================================================
    // Input Pad Cells - Channel 2
    //==========================================================================
    PADDI pad_ch2_enable (.PAD(PAD_ch2_enable), .Y(ch2_enable_core));
    PADDI pad_ch2_duty_0 (.PAD(PAD_ch2_duty_0), .Y(ch2_duty_cycle_core[0]));
    PADDI pad_ch2_duty_1 (.PAD(PAD_ch2_duty_1), .Y(ch2_duty_cycle_core[1]));
    PADDI pad_ch2_duty_2 (.PAD(PAD_ch2_duty_2), .Y(ch2_duty_cycle_core[2]));
    PADDI pad_ch2_duty_3 (.PAD(PAD_ch2_duty_3), .Y(ch2_duty_cycle_core[3]));
    PADDI pad_ch2_duty_4 (.PAD(PAD_ch2_duty_4), .Y(ch2_duty_cycle_core[4]));
    PADDI pad_ch2_duty_5 (.PAD(PAD_ch2_duty_5), .Y(ch2_duty_cycle_core[5]));
    PADDI pad_ch2_duty_6 (.PAD(PAD_ch2_duty_6), .Y(ch2_duty_cycle_core[6]));
    PADDI pad_ch2_duty_7 (.PAD(PAD_ch2_duty_7), .Y(ch2_duty_cycle_core[7]));
    
    //==========================================================================
    // Output Pad Cells - PWM Outputs
    //==========================================================================
    PADDO pad_pwm_out_0 (.A(pwm_out_0_core), .PAD(PAD_pwm_out_0));
    PADDO pad_pwm_out_1 (.A(pwm_out_1_core), .PAD(PAD_pwm_out_1));
    PADDO pad_pwm_out_2 (.A(pwm_out_2_core), .PAD(PAD_pwm_out_2));
    
    //==========================================================================
    // Output Pad Cells - Status Signals
    //==========================================================================
    PADDO pad_period_complete (.A(period_complete_core), .PAD(PAD_period_complete));
    PADDO pad_timer_overflow (.A(timer_overflow_core), .PAD(PAD_timer_overflow));
    
    //==========================================================================
    // PWM Controller Core Instance
    //==========================================================================
    pwm_controller pwm_core (
        .clk(clk_core),
        .reset(reset_core),
        .period(period_core),
        .prescaler(prescaler_core),
        .timer_enable(timer_enable_core),
        .ch0_enable(ch0_enable_core),
        .ch0_duty_cycle(ch0_duty_cycle_core),
        .ch1_enable(ch1_enable_core),
        .ch1_duty_cycle(ch1_duty_cycle_core),
        .ch2_enable(ch2_enable_core),
        .ch2_duty_cycle(ch2_duty_cycle_core),
        .pwm_out_0(pwm_out_0_core),
        .pwm_out_1(pwm_out_1_core),
        .pwm_out_2(pwm_out_2_core),
        .period_complete(period_complete_core),
        .timer_overflow(timer_overflow_core)
    );

endmodule

//==============================================================================
// PAD SUMMARY - gsclib045 IO Pads
//==============================================================================
// Total pads: 50
//   Input pads (PADDI):  38
//   Output pads (PADDO): 5
//   Power pads:          6 (2 VDD, 2 VSS, 1 VDDIO, 1 VSSIO)
//   Corner cells:        4
//
// Signal breakdown:
//   System: clk, reset (2 inputs)
//   Timer config: period[7:0], prescaler[7:0], timer_enable (17 inputs)
//   Channel 0: enable, duty_cycle[7:0] (9 inputs)
//   Channel 1: enable, duty_cycle[7:0] (9 inputs)
//   Channel 2: enable, duty_cycle[7:0] (9 inputs)
//   PWM outputs: pwm_out[2:0] (3 outputs)
//   Status: period_complete, timer_overflow (2 outputs)
//==============================================================================
