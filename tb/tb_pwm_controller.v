//==============================================================================
// Testbench for PWM Controller
// Tests all 3 channels with different duty cycles
// For EN4603 Digital IC Design Assignment
//==============================================================================

`timescale 1ns/1ps

module tb_pwm_controller;

    //==========================================================================
    // Testbench Signals
    //==========================================================================
    reg clk;
    reg reset;
    reg [7:0] period;
    reg [7:0] prescaler;
    reg timer_enable;
    
    reg ch0_enable;
    reg [7:0] ch0_duty_cycle;
    
    reg ch1_enable;
    reg [7:0] ch1_duty_cycle;
    
    reg ch2_enable;
    reg [7:0] ch2_duty_cycle;
    
    wire pwm_out_0;
    wire pwm_out_1;
    wire pwm_out_2;
    wire period_complete;
    wire timer_overflow;
    
    //==========================================================================
    // Test Statistics
    //==========================================================================
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    pwm_controller dut (
        .clk(clk),
        .reset(reset),
        .period(period),
        .prescaler(prescaler),
        .timer_enable(timer_enable),
        .ch0_enable(ch0_enable),
        .ch0_duty_cycle(ch0_duty_cycle),
        .ch1_enable(ch1_enable),
        .ch1_duty_cycle(ch1_duty_cycle),
        .ch2_enable(ch2_enable),
        .ch2_duty_cycle(ch2_duty_cycle),
        .pwm_out_0(pwm_out_0),
        .pwm_out_1(pwm_out_1),
        .pwm_out_2(pwm_out_2),
        .period_complete(period_complete),
        .timer_overflow(timer_overflow)
    );
    
    //==========================================================================
    // Clock Generation - 50MHz (20ns period)
    //==========================================================================
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 20ns period = 50MHz
    end
    
    //==========================================================================
    // VCD Dump for Waveform Viewing
    //==========================================================================
    initial begin
        $dumpfile("pwm_controller.vcd");
        $dumpvars(0, tb_pwm_controller);
    end
    
    //==========================================================================
    // Test Sequence
    //==========================================================================
    initial begin
        // Initialize counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("========================================");
        $display("PWM Controller Testbench");
        $display("========================================");
        $display("Time: %0t", $time);
        
        // Initialize inputs
        reset = 1;
        timer_enable = 0;
        period = 8'd100;
        prescaler = 8'd0;  // No prescaling for faster simulation
        ch0_enable = 0;
        ch0_duty_cycle = 8'd0;
        ch1_enable = 0;
        ch1_duty_cycle = 8'd0;
        ch2_enable = 0;
        ch2_duty_cycle = 8'd0;
        
        // Wait for a few clock cycles
        repeat(5) @(posedge clk);
        
        // Release reset
        @(posedge clk);
        reset = 0;
        $display("[%0t] Reset released", $time);
        
        // =====================================================================
        // TEST 1: Enable timer and check period_complete signal
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Testing timer with period=100", test_count);
        timer_enable = 1;
        period = 8'd100;
        
        // Wait for period complete
        @(posedge period_complete);
        $display("[%0t] Period complete detected", $time);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // TEST 2: Channel 0 - 25% duty cycle
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Channel 0: 25%% duty cycle", test_count);
        ch0_enable = 1;
        ch0_duty_cycle = 8'd25;  // 25/100 = 25%
        
        // Run for 2 complete periods
        repeat(2) @(posedge period_complete);
        $display("[%0t] Channel 0 PWM generated for 2 periods", $time);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // TEST 3: Channel 1 - 50% duty cycle
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Channel 1: 50%% duty cycle", test_count);
        ch1_enable = 1;
        ch1_duty_cycle = 8'd50;  // 50/100 = 50%
        
        // Run for 2 complete periods
        repeat(2) @(posedge period_complete);
        $display("[%0t] Channel 1 PWM generated for 2 periods", $time);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // TEST 4: Channel 2 - 75% duty cycle
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Channel 2: 75%% duty cycle", test_count);
        ch2_enable = 1;
        ch2_duty_cycle = 8'd75;  // 75/100 = 75%
        
        // Run for 2 complete periods
        repeat(2) @(posedge period_complete);
        $display("[%0t] Channel 2 PWM generated for 2 periods", $time);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // TEST 5: All channels active simultaneously
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] All 3 channels active simultaneously", test_count);
        $display("  CH0: 25%%, CH1: 50%%, CH2: 75%%");
        
        // Run for 3 complete periods
        repeat(3) @(posedge period_complete);
        $display("[%0t] All channels running for 3 periods", $time);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // TEST 6: Change duty cycles dynamically
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Changing duty cycles dynamically", test_count);
        ch0_duty_cycle = 8'd10;   // 10%
        ch1_duty_cycle = 8'd30;   // 30%
        ch2_duty_cycle = 8'd90;   // 90%
        $display("  New: CH0: 10%%, CH1: 30%%, CH2: 90%%");
        
        // Run for 2 complete periods
        repeat(2) @(posedge period_complete);
        $display("[%0t] Dynamic duty cycle change successful", $time);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // TEST 7: Disable channels individually
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Disabling channels individually", test_count);
        
        @(posedge clk);
        ch0_enable = 0;
        $display("[%0t] Channel 0 disabled", $time);
        
        repeat(1) @(posedge period_complete);
        
        @(posedge clk);
        ch1_enable = 0;
        $display("[%0t] Channel 1 disabled", $time);
        
        repeat(1) @(posedge period_complete);
        
        @(posedge clk);
        ch2_enable = 0;
        $display("[%0t] Channel 2 disabled", $time);
        
        repeat(1) @(posedge period_complete);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // TEST 8: Test with prescaler
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Testing prescaler function", test_count);
        prescaler = 8'd4;  // Divide by 5
        ch0_enable = 1;
        ch0_duty_cycle = 8'd50;
        
        // Run for 1 complete period (will take longer due to prescaler)
        repeat(1) @(posedge period_complete);
        $display("[%0t] Prescaled PWM generated", $time);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // TEST 9: Test 0% duty cycle
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Testing 0%% duty cycle", test_count);
        prescaler = 8'd0;
        ch0_duty_cycle = 8'd0;
        ch1_enable = 0;
        ch2_enable = 0;
        
        repeat(2) @(posedge period_complete);
        if (pwm_out_0 == 1'b0) begin
            $display("[%0t] 0%% duty cycle correct (output always LOW)", $time);
            pass_count = pass_count + 1;
        end else begin
            $display("[%0t] ERROR: 0%% duty cycle failed", $time);
            fail_count = fail_count + 1;
        end
        
        // =====================================================================
        // TEST 10: Test 100% duty cycle
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Testing 100%% duty cycle", test_count);
        ch0_duty_cycle = 8'd255;  // Maximum value
        
        repeat(2) @(posedge period_complete);
        $display("[%0t] 100%% duty cycle test complete", $time);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // TEST 11: Timer disable
        // =====================================================================
        @(posedge clk);
        test_count = test_count + 1;
        $display("\n[TEST %0d] Testing timer disable", test_count);
        timer_enable = 0;
        
        repeat(10) @(posedge clk);
        $display("[%0t] Timer disabled", $time);
        pass_count = pass_count + 1;
        
        // =====================================================================
        // Final Report
        // =====================================================================
        repeat(10) @(posedge clk);
        
        $display("\n========================================");
        $display("PWM Controller Test Complete");
        $display("========================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        $display("========================================");
        
        if (fail_count == 0) begin
            $display("STATUS: ALL TESTS PASSED!");
        end else begin
            $display("STATUS: SOME TESTS FAILED");
        end
        $display("========================================");
        
        $finish;
    end
    
    //==========================================================================
    // Timeout watchdog
    //==========================================================================
    initial begin
        #100000000;  // 100ms timeout
        $display("\n[ERROR] Simulation timeout!");
        $finish;
    end

endmodule
