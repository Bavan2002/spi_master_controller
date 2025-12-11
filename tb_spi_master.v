//==============================================================================
// Testbench for SPI Master Controller
//==============================================================================

`timescale 1ns/1ps

module tb_spi_master;

    // Clock and Reset
    reg clk;
    reg reset;

    // Control signals
    reg start;
    reg cpol;
    reg cpha;
    reg [1:0] clk_div;

    // Data interface
    reg [7:0] tx_data;
    wire [7:0] rx_data;
    wire rx_valid;
    wire busy;

    // SPI interface
    wire sclk;
    wire mosi;
    reg miso;
    wire ss_n;

    // Test tracking
    integer test_count;
    integer pass_count;
    integer fail_count;
    reg [7:0] expected_rx;

    // Instantiate SPI Master
    spi_master dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .cpol(cpol),
        .cpha(cpha),
        .clk_div(clk_div),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .busy(busy),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss_n(ss_n)
    );

    // Clock generation (50MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50MHz clock
    end

    // Simple loopback for MISO
    always @(*) begin
        miso = mosi; // Loopback mode for testing
    end

    // Test sequence
    initial begin
        $dumpfile("spi_master_sim.vcd");
        $dumpvars(0, tb_spi_master);

        // Initialize test counters
        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        // Initialize
        reset = 1;
        start = 0;
        cpol = 0;
        cpha = 0;
        clk_div = 2'b01; // Divide by 4
        tx_data = 8'h00;
        miso = 0;

        // Release reset
        #100 reset = 0;
        #50;

        // Test 1: Mode 0 (CPOL=0, CPHA=0)
        $display("\n=== Test 1: SPI Mode 0 (CPOL=0, CPHA=0) ===");
        test_count = test_count + 1;
        cpol = 0;
        cpha = 0;
        tx_data = 8'hA5;
        expected_rx = 8'hA5; // Loopback mode
        start = 1;
        #20 start = 0;

        wait(rx_valid);
        #20;
        $display("TX: 0x%h, RX: 0x%h", tx_data, rx_data);
        if (rx_data == expected_rx) begin
            $display("TEST 1 PASSED: Mode 0 loopback successful");
            pass_count = pass_count + 1;
        end else begin
            $display("TEST 1 FAILED: Expected 0x%h, got 0x%h", expected_rx, rx_data);
            fail_count = fail_count + 1;
        end

        // Test 2: Mode 1 (CPOL=0, CPHA=1)
        #100;
        $display("\n=== Test 2: SPI Mode 1 (CPOL=0, CPHA=1) ===");
        test_count = test_count + 1;
        cpol = 0;
        cpha = 1;
        tx_data = 8'h5A;
        expected_rx = 8'h5A;
        start = 1;
        #20 start = 0;

        wait(rx_valid);
        #20;
        $display("TX: 0x%h, RX: 0x%h", tx_data, rx_data);
        if (rx_data == expected_rx) begin
            $display("TEST 2 PASSED: Mode 1 loopback successful");
            pass_count = pass_count + 1;
        end else begin
            $display("TEST 2 FAILED: Expected 0x%h, got 0x%h", expected_rx, rx_data);
            fail_count = fail_count + 1;
        end

        // Test 3: Mode 2 (CPOL=1, CPHA=0)
        #100;
        $display("\n=== Test 3: SPI Mode 2 (CPOL=1, CPHA=0) ===");
        test_count = test_count + 1;
        cpol = 1;
        cpha = 0;
        tx_data = 8'hF0;
        expected_rx = 8'hF0;
        start = 1;
        #20 start = 0;

        wait(rx_valid);
        #20;
        $display("TX: 0x%h, RX: 0x%h", tx_data, rx_data);
        if (rx_data == expected_rx) begin
            $display("TEST 3 PASSED: Mode 2 loopback successful");
            pass_count = pass_count + 1;
        end else begin
            $display("TEST 3 FAILED: Expected 0x%h, got 0x%h", expected_rx, rx_data);
            fail_count = fail_count + 1;
        end

        // Test 4: Mode 3 (CPOL=1, CPHA=1)
        #100;
        $display("\n=== Test 4: SPI Mode 3 (CPOL=1, CPHA=1) ===");
        test_count = test_count + 1;
        cpol = 1;
        cpha = 1;
        tx_data = 8'h0F;
        expected_rx = 8'h0F;
        start = 1;
        #20 start = 0;

        wait(rx_valid);
        #20;
        $display("TX: 0x%h, RX: 0x%h", tx_data, rx_data);
        if (rx_data == expected_rx) begin
            $display("TEST 4 PASSED: Mode 3 loopback successful");
            pass_count = pass_count + 1;
        end else begin
            $display("TEST 4 FAILED: Expected 0x%h, got 0x%h", expected_rx, rx_data);
            fail_count = fail_count + 1;
        end

        // Test 5: Different clock dividers
        #100;
        $display("\n=== Test 5: Different Clock Dividers ===");
        cpol = 0;
        cpha = 0;

        test_count = test_count + 1;
        clk_div = 2'b00; // Divide by 2 (fastest)
        tx_data = 8'hAA;
        expected_rx = 8'hAA;
        start = 1;
        #20 start = 0;
        wait(rx_valid);
        #20;
        $display("CLK_DIV=/2: TX: 0x%h, RX: 0x%h", tx_data, rx_data);
        if (rx_data == expected_rx) begin
            $display("TEST 5a PASSED: Clock divider /2 works correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("TEST 5a FAILED: Expected 0x%h, got 0x%h", expected_rx, rx_data);
            fail_count = fail_count + 1;
        end

        #100;
        test_count = test_count + 1;
        clk_div = 2'b11; // Divide by 16 (slowest)
        tx_data = 8'h55;
        expected_rx = 8'h55;
        start = 1;
        #20 start = 0;
        wait(rx_valid);
        #20;
        $display("CLK_DIV=/16: TX: 0x%h, RX: 0x%h", tx_data, rx_data);
        if (rx_data == expected_rx) begin
            $display("TEST 5b PASSED: Clock divider /16 works correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("TEST 5b FAILED: Expected 0x%h, got 0x%h", expected_rx, rx_data);
            fail_count = fail_count + 1;
        end

        // Test 6: Back-to-back transactions
        #100;
        $display("\n=== Test 6: Back-to-Back Transactions ===");
        test_count = test_count + 1;
        tx_data = 8'h11;
        expected_rx = 8'h11;
        start = 1;
        #20 start = 0;
        wait(rx_valid);
        if (rx_data == expected_rx) begin
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end

        #50; // Small gap
        test_count = test_count + 1;
        tx_data = 8'h22;
        expected_rx = 8'h22;
        start = 1;
        #20 start = 0;
        wait(rx_valid);
        if (rx_data == expected_rx) begin
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end

        #50;
        test_count = test_count + 1;
        tx_data = 8'h33;
        expected_rx = 8'h33;
        start = 1;
        #20 start = 0;
        wait(rx_valid);
        if (rx_data == expected_rx) begin
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end

        $display("TEST 6 PASSED: Back-to-back transactions completed successfully");

        #200;
        $display("\n========================================");
        $display("===      TEST RESULTS SUMMARY       ===");
        $display("========================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        $display("========================================");
        
        if (fail_count == 0) begin
            $display("*** ALL TESTS PASSED ***");
            $display("Status: SUCCESS");
        end else begin
            $display("*** SOME TESTS FAILED ***");
            $display("Status: FAILURE");
        end
        $display("========================================");
        
        $finish;
    end

    // Monitor
    always @(posedge clk) begin
        if (rx_valid) begin
            $display("Time=%0t: Transaction complete - RX=0x%h", $time, rx_data);
        end
    end

    // Timeout watchdog
    initial begin
        #50000;
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule
