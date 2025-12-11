#==============================================================================
# IO Placement File for PWM Controller Chip - CORRECTED SPACING
#==============================================================================
# Design: PWM Controller with IO Pads
# Die Size: 1460um × 1460um (SQUARE, pad-limited)
# Core Size: 960um × 960um
# IO Margin: 250um (240um pad height + 10um clearance)
#
# Pad Dimensions:
#   - Signal/Power pads: 60um (width) × 240um (height)
#   - Corner pads: 240um × 240um
#
# Distribution:
#   - Bottom edge: 15 pads (65.00um pitch, 5.00um gaps)
#   - Right edge:  13 pads (74.29um pitch, 14.29um gaps)
#   - Top edge:    14 pads (69.33um pitch, 9.33um gaps)
#   - Left edge:   15 pads (65.00um pitch, 5.00um gaps)
#
# Total: 53 pads (4 corners + 6 power + 43 signal)
#==============================================================================

(globals
    version = 3
    io_order = default
)

(iopad
    #--------------------------------------------------------------------------
    # Corner Pads (240um × 240um each)
    #--------------------------------------------------------------------------
    (topleft
        (inst name="corner_ul")
    )

    (topright
        (inst name="corner_ur")
    )

    (bottomleft
        (inst name="corner_ll")
    )

    (bottomright
        (inst name="corner_lr")
    )

    #--------------------------------------------------------------------------
    # BOTTOM EDGE - 15 pads total (2 power + 13 signal)
    # Pitch: 65.00um | Gap: 5.00um
    #--------------------------------------------------------------------------
    (bottom
        (inst name="vss_pad0" offset=245.00)
        (inst name="vssio_pad0" offset=310.00)
        (inst name="pad_clk" offset=375.00)
        (inst name="pad_ch0_duty_0" offset=440.00)
        (inst name="pad_ch0_duty_4" offset=505.00)
        (inst name="pad_ch1_duty_0" offset=570.00)
        (inst name="pad_ch1_duty_4" offset=635.00)
        (inst name="pad_ch2_duty_0" offset=700.00)
        (inst name="pad_ch2_duty_4" offset=765.00)
        (inst name="pad_prescaler_0" offset=830.00)
        (inst name="pad_prescaler_4" offset=895.00)
        (inst name="pad_pwm_out_1" offset=960.00)
        (inst name="pad_timer_overflow" offset=1025.00)
        (inst name="pad_prescaler_7" offset=1090.00)
        (inst name="pad_period_4" offset=1155.00)
    )

    #--------------------------------------------------------------------------
    # RIGHT EDGE - 13 pads total (1 power + 12 signal)
    # Pitch: 74.29um | Gap: 14.29um
    #--------------------------------------------------------------------------
    (right
        (inst name="vss_pad1" offset=254.29)
        (inst name="pad_reset" offset=328.57)
        (inst name="pad_ch0_duty_1" offset=402.86)
        (inst name="pad_ch0_duty_5" offset=477.14)
        (inst name="pad_ch1_duty_1" offset=551.43)
        (inst name="pad_ch1_duty_5" offset=625.71)
        (inst name="pad_ch2_duty_1" offset=700.00)
        (inst name="pad_ch2_duty_5" offset=774.29)
        (inst name="pad_prescaler_1" offset=848.57)
        (inst name="pad_prescaler_5" offset=922.86)
        (inst name="pad_pwm_out_2" offset=997.14)
        (inst name="pad_period_complete" offset=1071.43)
        (inst name="pad_period_1" offset=1145.71)
    )

    #--------------------------------------------------------------------------
    # TOP EDGE - 14 pads total (2 power + 12 signal)
    # Pitch: 69.33um | Gap: 9.33um
    #--------------------------------------------------------------------------
    (top
        (inst name="vdd_pad0" offset=249.33)
        (inst name="vddio_pad0" offset=318.67)
        (inst name="pad_timer_enable" offset=388.00)
        (inst name="pad_ch0_duty_2" offset=457.33)
        (inst name="pad_ch0_duty_6" offset=526.67)
        (inst name="pad_ch1_duty_2" offset=596.00)
        (inst name="pad_ch1_duty_6" offset=665.33)
        (inst name="pad_ch2_duty_2" offset=734.67)
        (inst name="pad_ch2_duty_6" offset=804.00)
        (inst name="pad_prescaler_2" offset=873.33)
        (inst name="pad_prescaler_6" offset=942.67)
        (inst name="pad_pwm_out_0" offset=1012.00)
        (inst name="pad_period_0" offset=1081.33)
        (inst name="pad_period_5" offset=1150.67)
    )

    #--------------------------------------------------------------------------
    # LEFT EDGE - 15 pads total (1 power + 14 signal)
    # Pitch: 65.00um | Gap: 5.00um
    #--------------------------------------------------------------------------
    (left
        (inst name="vdd_pad1" offset=245.00)
        (inst name="pad_ch0_enable" offset=310.00)
        (inst name="pad_ch0_duty_3" offset=375.00)
        (inst name="pad_ch0_duty_7" offset=440.00)
        (inst name="pad_ch1_enable" offset=505.00)
        (inst name="pad_ch1_duty_3" offset=570.00)
        (inst name="pad_ch1_duty_7" offset=635.00)
        (inst name="pad_ch2_enable" offset=700.00)
        (inst name="pad_ch2_duty_3" offset=765.00)
        (inst name="pad_ch2_duty_7" offset=830.00)
        (inst name="pad_prescaler_3" offset=895.00)
        (inst name="pad_period_2" offset=960.00)
        (inst name="pad_period_3" offset=1025.00)
        (inst name="pad_period_6" offset=1090.00)
        (inst name="pad_period_7" offset=1155.00)
    )
)

#==============================================================================
# VERIFICATION SUMMARY
#==============================================================================
# ✓ Die size: 1460um × 1460um (square)
# ✓ Pad height (240um) < IO margin (250um) → 10um clearance
# ✓ All pads have minimum 5um gaps
# ✓ Distribution balanced: 13-15 pads per edge
# ✓ No overlaps with core or adjacent pads
#
# Usage:
#   loadIoFile ../input/pwm_controller_even.io
#   commitIoPlacement
#==============================================================================
