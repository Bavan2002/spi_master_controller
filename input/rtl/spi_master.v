//==============================================================================
// SPI Master Controller
// For EN4603 Digital IC Design Assignment
// Compatible with Lab 1, 2, 3 workflows
//==============================================================================

`timescale 1ns/1ps

module spi_master (
    // Clock and Reset
    input wire clk,           // System clock
    input wire reset,         // Active high reset

    // Control Interface
    input wire start,         // Start SPI transaction
    input wire cpol,          // Clock polarity (0 or 1)
    input wire cpha,          // Clock phase (0 or 1)
    input wire [1:0] clk_div, // Clock divider: 00=/2, 01=/4, 10=/8, 11=/16

    // Data Interface
    input wire [7:0] tx_data,     // Data to transmit
    output reg [7:0] rx_data,     // Received data
    output reg rx_valid,          // Received data valid
    output reg busy,              // Transaction in progress

    // SPI Interface
    output reg sclk,          // SPI clock
    output reg mosi,          // Master Out Slave In
    input wire miso,          // Master In Slave Out
    output reg ss_n           // Slave select (active low)
);

    // State machine states
    localparam IDLE      = 3'b000;
    localparam SETUP     = 3'b001;
    localparam TRANSFER  = 3'b010;
    localparam HOLD      = 3'b011;
    localparam DONE      = 3'b100;

    // Internal registers
    reg [2:0] state, next_state;
    reg [7:0] tx_shift_reg;
    reg [7:0] rx_shift_reg;
    reg [3:0] bit_counter;
    reg [3:0] clk_counter;
    reg [3:0] clk_divider;
    reg sclk_enable;
    reg internal_sclk;

    // Clock divider logic
    always @(*) begin
        case (clk_div)
            2'b00: clk_divider = 4'd1;   // Divide by 2
            2'b01: clk_divider = 4'd2;   // Divide by 4
            2'b10: clk_divider = 4'd4;   // Divide by 8
            2'b11: clk_divider = 4'd8;   // Divide by 16
            default: clk_divider = 4'd2;
        endcase
    end

    // Clock generation for SPI
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 4'd0;
            internal_sclk <= 1'b0;
        end else if (sclk_enable) begin
            if (clk_counter >= clk_divider) begin
                clk_counter <= 4'd0;
                internal_sclk <= ~internal_sclk;
            end else begin
                clk_counter <= clk_counter + 1'b1;
            end
        end else begin
            clk_counter <= 4'd0;
            internal_sclk <= cpol; // Idle state based on CPOL
        end
    end

    // Apply clock polarity
    always @(*) begin
        if (cpol) begin
            sclk = ~internal_sclk; // CPOL=1: idle high
        end else begin
            sclk = internal_sclk;  // CPOL=0: idle low
        end
    end

    // State machine - Sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // State machine - Next state logic
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start) begin
                    next_state = SETUP;
                end
            end

            SETUP: begin
                next_state = TRANSFER;
            end

            TRANSFER: begin
                if (bit_counter == 4'd0 && clk_counter >= clk_divider) begin
                    next_state = HOLD;
                end
            end

            HOLD: begin
                next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // State machine - Output logic and data shifting
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_shift_reg <= 8'd0;
            rx_shift_reg <= 8'd0;
            rx_data <= 8'd0;
            rx_valid <= 1'b0;
            busy <= 1'b0;
            mosi <= 1'b0;
            ss_n <= 1'b1;
            bit_counter <= 4'd0;
            sclk_enable <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    ss_n <= 1'b1;
                    rx_valid <= 1'b0;
                    sclk_enable <= 1'b0;
                    bit_counter <= 4'd8;

                    if (start) begin
                        tx_shift_reg <= tx_data;
                        busy <= 1'b1;
                    end
                end

                SETUP: begin
                    ss_n <= 1'b0;         // Assert slave select
                    sclk_enable <= 1'b1;  // Enable SPI clock

                    // Set initial MOSI based on CPHA
                    if (cpha == 1'b0) begin
                        // CPHA=0: Data valid on first edge
                        mosi <= tx_shift_reg[7];
                    end
                end

                TRANSFER: begin
                    // Data shifting based on CPHA
                    if (clk_counter == 4'd0) begin
                        if (cpha == 1'b0) begin
                            // CPHA=0: Sample on first edge, shift on second
                            if (internal_sclk == 1'b0) begin
                                // Leading edge - sample MISO
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                            end else begin
                                // Trailing edge - shift MOSI
                                if (bit_counter > 0) begin
                                    tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                    mosi <= tx_shift_reg[7];
                                    bit_counter <= bit_counter - 1'b1;
                                end
                            end
                        end else begin
                            // CPHA=1: Shift on first edge, sample on second
                            if (internal_sclk == 1'b1) begin
                                // Leading edge - shift MOSI
                                tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                                mosi <= tx_shift_reg[7];
                            end else begin
                                // Trailing edge - sample MISO
                                rx_shift_reg <= {rx_shift_reg[6:0], miso};
                                if (bit_counter > 0) begin
                                    bit_counter <= bit_counter - 1'b1;
                                end
                            end
                        end
                    end
                end

                HOLD: begin
                    sclk_enable <= 1'b0;
                    rx_data <= rx_shift_reg;
                    rx_valid <= 1'b1;
                end

                DONE: begin
                    ss_n <= 1'b1;
                    rx_valid <= 1'b0;
                    busy <= 1'b0;
                end

                default: begin
                    busy <= 1'b0;
                    ss_n <= 1'b1;
                    sclk_enable <= 1'b0;
                end
            endcase
        end
    end

endmodule
