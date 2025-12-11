#==============================================================================
# IO Placement File for SPI Master Chip
# Defines pad locations around chip perimeter for Lab 3
# Format: Innovus IO placement file (.io)
#==============================================================================

(globals
    version = 3
    io_order = default
)

(iopad
    #--------------------------------------------------------------------------
    # Corner Pads (Required at all four corners)
    #--------------------------------------------------------------------------
    (topleft
        (inst name="corner_ul" offset=0)
    )

    (topright
        (inst name="corner_ur" offset=0)
    )

    (bottomleft
        (inst name="corner_ll" offset=0)
    )

    (bottomright
        (inst name="corner_lr" offset=0)
    )

    #--------------------------------------------------------------------------
    # LEFT SIDE PADS (bottom to top)
    # Layout: Power, System, Control signals
    #--------------------------------------------------------------------------
    (left
        (inst name="vss_pad0" offset=100)
        (inst name="pad_clk" offset=200)
        (inst name="pad_reset" offset=300)
        (inst name="pad_start" offset=400)
        (inst name="pad_cpol" offset=500)
        (inst name="pad_cpha" offset=600)
        (inst name="pad_clk_div_0" offset=700)
        (inst name="pad_clk_div_1" offset=800)
        (inst name="vdd_pad0" offset=900)
    )

    #--------------------------------------------------------------------------
    # BOTTOM SIDE PADS (left to right)
    # Layout: TX data bus (8 bits) + MISO input
    #--------------------------------------------------------------------------
    (bottom
        (inst name="pad_tx_data_0" offset=100)
        (inst name="pad_tx_data_1" offset=200)
        (inst name="pad_tx_data_2" offset=300)
        (inst name="pad_tx_data_3" offset=400)
        (inst name="pad_tx_data_4" offset=500)
        (inst name="pad_tx_data_5" offset=600)
        (inst name="pad_tx_data_6" offset=700)
        (inst name="pad_tx_data_7" offset=800)
        (inst name="pad_miso" offset=900)
    )

    #--------------------------------------------------------------------------
    # RIGHT SIDE PADS (bottom to top)
    # Layout: RX data bus (8 bits) + Power
    #--------------------------------------------------------------------------
    (right
        (inst name="pad_rx_data_0" offset=100)
        (inst name="pad_rx_data_1" offset=200)
        (inst name="pad_rx_data_2" offset=300)
        (inst name="pad_rx_data_3" offset=400)
        (inst name="pad_rx_data_4" offset=500)
        (inst name="pad_rx_data_5" offset=600)
        (inst name="pad_rx_data_6" offset=700)
        (inst name="pad_rx_data_7" offset=800)
        (inst name="vssio_pad0" offset=900)
    )

    #--------------------------------------------------------------------------
    # TOP SIDE PADS (left to right)
    # Layout: Status signals, SPI interface, Power pads
    #--------------------------------------------------------------------------
    (top
        (inst name="pad_rx_valid" offset=100)
        (inst name="pad_busy" offset=200)
        (inst name="pad_sclk" offset=300)
        (inst name="pad_mosi" offset=400)
        (inst name="pad_ss_n" offset=500)
        (inst name="vddio_pad0" offset=700)
        (inst name="vdd_pad1" offset=900)
        (inst name="vss_pad1" offset=1100)
    )
)

#==============================================================================
# NOTES:
#==============================================================================
# 1. Offset values are in microns from the corner of each side
# 2. Adjust offset spacing based on actual pad cell width (typically 100-120um)
# 3. Power pads distributed around perimeter for better current distribution
# 4. Signal grouping:
#    - LEFT:   System and control signals (inputs)
#    - BOTTOM: Transmit data bus (inputs)
#    - RIGHT:  Receive data bus (outputs)
#    - TOP:    Status and SPI interface (outputs)
# 5. Load this file in Innovus with: loadIoFile spi_master.io
# 6. Then commit placement with: commitIoPlacement
#==============================================================================
