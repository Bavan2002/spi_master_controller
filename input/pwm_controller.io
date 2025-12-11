#==============================================================================
# IO Placement File for PWM Controller Chip - DEPRECATED
# This file uses UNEVEN distribution (grouped by function)
# For EVEN distribution across 4 edges, use pwm_controller_even.io instead
# 
# NOTE: The automated script ignores this file by default and uses
#       automatic round-robin distribution for better balance
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
    # Layout: Power, System, Timer config
    #--------------------------------------------------------------------------
    (left
        (inst name="vss_pad0" offset=100)
        (inst name="pad_clk" offset=200)
        (inst name="pad_reset" offset=300)
        (inst name="pad_timer_enable" offset=400)
        (inst name="pad_period_0" offset=500)
        (inst name="pad_period_1" offset=600)
        (inst name="pad_period_2" offset=700)
        (inst name="pad_period_3" offset=800)
        (inst name="pad_period_4" offset=900)
        (inst name="pad_period_5" offset=1000)
        (inst name="pad_period_6" offset=1100)
        (inst name="pad_period_7" offset=1200)
    )

    #--------------------------------------------------------------------------
    # BOTTOM SIDE PADS (left to right)
    # Layout: Prescaler configuration
    #--------------------------------------------------------------------------
    (bottom
        (inst name="pad_prescaler_0" offset=100)
        (inst name="pad_prescaler_1" offset=200)
        (inst name="pad_prescaler_2" offset=300)
        (inst name="pad_prescaler_3" offset=400)
        (inst name="pad_prescaler_4" offset=500)
        (inst name="pad_prescaler_5" offset=600)
        (inst name="pad_prescaler_6" offset=700)
        (inst name="pad_prescaler_7" offset=800)
        (inst name="pad_ch0_enable" offset=900)
        (inst name="pad_ch0_duty_0" offset=1000)
        (inst name="pad_ch0_duty_1" offset=1100)
    )

    #--------------------------------------------------------------------------
    # RIGHT SIDE PADS (bottom to top)
    # Layout: Channel 0 and Channel 1 duty cycles
    #--------------------------------------------------------------------------
    (right
        (inst name="pad_ch0_duty_2" offset=100)
        (inst name="pad_ch0_duty_3" offset=200)
        (inst name="pad_ch0_duty_4" offset=300)
        (inst name="pad_ch0_duty_5" offset=400)
        (inst name="pad_ch0_duty_6" offset=500)
        (inst name="pad_ch0_duty_7" offset=600)
        (inst name="pad_ch1_enable" offset=700)
        (inst name="pad_ch1_duty_0" offset=800)
        (inst name="pad_ch1_duty_1" offset=900)
        (inst name="pad_ch1_duty_2" offset=1000)
        (inst name="pad_ch1_duty_3" offset=1100)
        (inst name="pad_ch1_duty_4" offset=1200)
    )

    #--------------------------------------------------------------------------
    # TOP SIDE PADS (left to right)
    # Layout: Channel 1/2 duty cycles, PWM outputs, Status, Power
    #--------------------------------------------------------------------------
    (top
        (inst name="pad_ch1_duty_5" offset=100)
        (inst name="pad_ch1_duty_6" offset=200)
        (inst name="pad_ch1_duty_7" offset=300)
        (inst name="pad_ch2_enable" offset=400)
        (inst name="pad_ch2_duty_0" offset=500)
        (inst name="pad_ch2_duty_1" offset=600)
        (inst name="pad_ch2_duty_2" offset=700)
        (inst name="pad_ch2_duty_3" offset=800)
        (inst name="pad_ch2_duty_4" offset=900)
        (inst name="pad_ch2_duty_5" offset=1000)
        (inst name="pad_ch2_duty_6" offset=1100)
        (inst name="pad_ch2_duty_7" offset=1200)
        (inst name="pad_pwm_out_0" offset=1300)
        (inst name="pad_pwm_out_1" offset=1400)
        (inst name="pad_pwm_out_2" offset=1500)
        (inst name="pad_period_complete" offset=1600)
        (inst name="pad_timer_overflow" offset=1700)
        (inst name="vdd_pad0" offset=1900)
        (inst name="vdd_pad1" offset=2100)
        (inst name="vss_pad1" offset=2300)
        (inst name="vddio_pad0" offset=2500)
        (inst name="vssio_pad0" offset=2700)
    )
)

#==============================================================================
# NOTES:
#==============================================================================
# Total pads: 50 (38 inputs + 5 outputs + 6 power + 4 corners)
# Offset values are in microns from the corner of each side
# Pad cell size: 60um x 240um (from giolib045.lef)
# Load this file in Innovus with: loadIoFile pwm_controller.io
# Then commit placement with: commitIoPlacement
#==============================================================================
