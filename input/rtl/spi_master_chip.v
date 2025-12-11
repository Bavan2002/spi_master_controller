//==============================================================================
// SPI Master Chip - Top Level with IO Pads
// Wrapper module for Lab 3 - IO Pad Ring Integration
// EN4603 Digital IC Design Assignment
//==============================================================================

`timescale 1ns/1ps

module spi_master_chip (
    // External IO Pads - Power
    inout wire PAD_VDD,
    inout wire PAD_VSS,
    inout wire PAD_VDDIO,
    inout wire PAD_VSSIO,
    
    // External IO Pads - System Signals
    inout wire PAD_clk,
    inout wire PAD_reset,
    
    // External IO Pads - Control Signals
    inout wire PAD_start,
    inout wire PAD_cpol,
    inout wire PAD_cpha,
    inout wire PAD_clk_div_0,
    inout wire PAD_clk_div_1,
    
    // External IO Pads - TX Data Interface
    inout wire PAD_tx_data_0,
    inout wire PAD_tx_data_1,
    inout wire PAD_tx_data_2,
    inout wire PAD_tx_data_3,
    inout wire PAD_tx_data_4,
    inout wire PAD_tx_data_5,
    inout wire PAD_tx_data_6,
    inout wire PAD_tx_data_7,
    
    // External IO Pads - RX Data Interface
    inout wire PAD_rx_data_0,
    inout wire PAD_rx_data_1,
    inout wire PAD_rx_data_2,
    inout wire PAD_rx_data_3,
    inout wire PAD_rx_data_4,
    inout wire PAD_rx_data_5,
    inout wire PAD_rx_data_6,
    inout wire PAD_rx_data_7,
    
    // External IO Pads - Status Signals
    inout wire PAD_rx_valid,
    inout wire PAD_busy,
    
    // External IO Pads - SPI Interface
    inout wire PAD_sclk,
    inout wire PAD_mosi,
    inout wire PAD_miso,
    inout wire PAD_ss_n
);

    //==========================================================================
    // Internal Core Signals (between pads and core)
    //==========================================================================
    wire clk_core, reset_core;
    wire start_core, cpol_core, cpha_core;
    wire [1:0] clk_div_core;
    wire [7:0] tx_data_core;
    wire [7:0] rx_data_core;
    wire rx_valid_core, busy_core;
    wire sclk_core, mosi_core, miso_core, ss_n_core;
    
    //==========================================================================
    // Corner Pad Cells
    //==========================================================================
    // From giolib045.lef: padIORINGCORNER
    // These cells complete the pad ring at corners
    
    padIORINGCORNER corner_ll ();
    padIORINGCORNER corner_lr ();
    padIORINGCORNER corner_ul ();
    padIORINGCORNER corner_ur ();
    
    //==========================================================================
    // Power Pad Cells
    //==========================================================================
    // From giolib045.lef: PADVDD, PADVSS, PADVDDIOR, PADVSSIOR
    // Multiple power pads needed for current distribution around the ring
    // Core power pads (VDD/VSS)
    
    PADVDD vdd_pad0 (.PAD(PAD_VDD));
    PADVDD vdd_pad1 (.PAD(PAD_VDD));
    PADVSS vss_pad0 (.PAD(PAD_VSS));
    PADVSS vss_pad1 (.PAD(PAD_VSS));
    
    // IO ring power pads (VDDIOR/VSSIOR)
    PADVDDIOR vddio_pad0 (.PAD(PAD_VDDIO));
    PADVSSIOR vssio_pad0 (.PAD(PAD_VSSIO));
    
    //==========================================================================
    // Input Pad Cells - System Signals
    //==========================================================================
    // From giolib045.lef: PADDI (Input pad)
    // Ports: PAD (external), Y (to core), VDD, VSS, VDDIOR, VSSIOR
    
    PADDI pad_clk (
        .PAD(PAD_clk),
        .Y(clk_core)
    );
    
    PADDI pad_reset (
        .PAD(PAD_reset),
        .Y(reset_core)
    );
    
    //==========================================================================
    // Input Pad Cells - Control Signals
    //==========================================================================
    PADDI pad_start (
        .PAD(PAD_start),
        .Y(start_core)
    );
    
    PADDI pad_cpol (
        .PAD(PAD_cpol),
        .Y(cpol_core)
    );
    
    PADDI pad_cpha (
        .PAD(PAD_cpha),
        .Y(cpha_core)
    );
    
    PADDI pad_clk_div_0 (
        .PAD(PAD_clk_div_0),
        .Y(clk_div_core[0])
    );
    
    PADDI pad_clk_div_1 (
        .PAD(PAD_clk_div_1),
        .Y(clk_div_core[1])
    );
    
    //==========================================================================
    // Input Pad Cells - TX Data (8 bits)
    //==========================================================================
    PADDI pad_tx_data_0 (.PAD(PAD_tx_data_0), .Y(tx_data_core[0]));
    PADDI pad_tx_data_1 (.PAD(PAD_tx_data_1), .Y(tx_data_core[1]));
    PADDI pad_tx_data_2 (.PAD(PAD_tx_data_2), .Y(tx_data_core[2]));
    PADDI pad_tx_data_3 (.PAD(PAD_tx_data_3), .Y(tx_data_core[3]));
    PADDI pad_tx_data_4 (.PAD(PAD_tx_data_4), .Y(tx_data_core[4]));
    PADDI pad_tx_data_5 (.PAD(PAD_tx_data_5), .Y(tx_data_core[5]));
    PADDI pad_tx_data_6 (.PAD(PAD_tx_data_6), .Y(tx_data_core[6]));
    PADDI pad_tx_data_7 (.PAD(PAD_tx_data_7), .Y(tx_data_core[7]));
    
    //==========================================================================
    // Input Pad Cell - SPI MISO
    //==========================================================================
    PADDI pad_miso (
        .PAD(PAD_miso),
        .Y(miso_core)
    );
    
    //==========================================================================
    // Output Pad Cells - RX Data (8 bits)
    //==========================================================================
    // From giolib045.lef: PADDO (Output pad)
    // Ports: PAD (external), A (from core), VDD, VSS, VDDIOR, VSSIOR
    
    PADDO pad_rx_data_0 (.A(rx_data_core[0]), .PAD(PAD_rx_data_0));
    PADDO pad_rx_data_1 (.A(rx_data_core[1]), .PAD(PAD_rx_data_1));
    PADDO pad_rx_data_2 (.A(rx_data_core[2]), .PAD(PAD_rx_data_2));
    PADDO pad_rx_data_3 (.A(rx_data_core[3]), .PAD(PAD_rx_data_3));
    PADDO pad_rx_data_4 (.A(rx_data_core[4]), .PAD(PAD_rx_data_4));
    PADDO pad_rx_data_5 (.A(rx_data_core[5]), .PAD(PAD_rx_data_5));
    PADDO pad_rx_data_6 (.A(rx_data_core[6]), .PAD(PAD_rx_data_6));
    PADDO pad_rx_data_7 (.A(rx_data_core[7]), .PAD(PAD_rx_data_7));
    
    //==========================================================================
    // Output Pad Cells - Status Signals
    //==========================================================================
    PADDO pad_rx_valid (
        .A(rx_valid_core),
        .PAD(PAD_rx_valid)
    );
    
    PADDO pad_busy (
        .A(busy_core),
        .PAD(PAD_busy)
    );
    
    //==========================================================================
    // Output Pad Cells - SPI Interface
    //==========================================================================
    PADDO pad_sclk (
        .A(sclk_core),
        .PAD(PAD_sclk)
    );
    
    PADDO pad_mosi (
        .A(mosi_core),
        .PAD(PAD_mosi)
    );
    
    PADDO pad_ss_n (
        .A(ss_n_core),
        .PAD(PAD_ss_n)
    );
    
    //==========================================================================
    // SPI Master Core Instance
    //==========================================================================
    spi_master spi_core (
        // Clock and Reset
        .clk(clk_core),
        .reset(reset_core),
        
        // Control Interface
        .start(start_core),
        .cpol(cpol_core),
        .cpha(cpha_core),
        .clk_div(clk_div_core),
        
        // Data Interface
        .tx_data(tx_data_core),
        .rx_data(rx_data_core),
        .rx_valid(rx_valid_core),
        .busy(busy_core),
        
        // SPI Interface
        .sclk(sclk_core),
        .mosi(mosi_core),
        .miso(miso_core),
        .ss_n(ss_n_core)
    );

endmodule

//==============================================================================
// IMPLEMENTATION NOTES - gsclib045 IO Pads
//==============================================================================
// This module uses actual pad cells from giolib045.lef:
//
// PAD CELL SUMMARY:
// - Input pads:   PADDI (ports: PAD, Y, VDD, VSS, VDDIOR, VSSIOR)
// - Output pads:  PADDO (ports: PAD, A, VDD, VSS, VDDIOR, VSSIOR)
// - Power VDD:    PADVDD (port: PAD)
// - Power VSS:    PADVSS (port: PAD)
// - Power VDDIO:  PADVDDIOR (port: PAD)
// - Power VSSIO:  PADVSSIOR (port: PAD)
// - Corner cells: padIORINGCORNER (no connections needed)
// - Pad size:     60um x 240um each
//
// SYNTHESIS INSTRUCTIONS:
// 1. Make sure giolib045.lef is included in LEF library list
// 2. Read both files:
//    read_hdl {../input/rtl/spi_master.v ../input/rtl/spi_master_chip.v}
// 3. Elaborate the wrapper:
//    elaborate spi_master_chip
// 4. Continue with normal synthesis flow
//
// PLACE & ROUTE INSTRUCTIONS:
// 1. Load IO placement file: loadIoFile ../input/spi_master.io
// 2. Create floorplan with IO margins
// 3. Commit IO placement: commitIoPlacement
// 4. Continue with normal P&R flow
//
// POWER CONNECTION:
// - Power pads are connected automatically to VDD/VSS/VDDIOR/VSSIOR nets
// - No explicit connections needed in the instantiation
// - Power routing handled by sroute command in P&R
//==============================================================================
