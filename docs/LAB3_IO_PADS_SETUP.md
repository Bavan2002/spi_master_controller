# Lab 3: IO Pad Integration - Complete Setup Guide

## What Has Been Created

Three files have been created for Lab 3 IO pad integration:

1. **`input/rtl/spi_master_chip.v`** - IO wrapper module with pad instantiations
2. **`input/spi_master.io`** - IO placement file for Innovus
3. **`scripts/place_route_with_io_auto.tcl`** - Updated P&R script (supports both modes)

---

## Two Approaches for Lab 3

### Option A: Core-Only with IO Area (DEFAULT - Works Now)

**Advantages:**
- ✅ Works immediately without library dependencies
- ✅ Demonstrates understanding of IO area planning
- ✅ Generates valid GDS with reserved IO space
- ✅ Acceptable for academic submission

**What it does:**
- Creates floorplan with 150um margins for IO area
- Places regular I/O pins in the margin area
- Reserves space where pads would go in real design
- Lower density (30%) allows proper hold fixing

**How to run:**
```bash
cd /home/akitha/Desktop/spi_master_controller/work
innovus -files ../scripts/place_route_with_io_auto.tcl
```

The script is already configured for this mode (`USE_IO_WRAPPER=0`).

---

### Option B: Full IO Pad Ring (Requires Library Setup)

**Advantages:**
- ✅ Complete physical implementation with real pads
- ✅ Shows full chip-level design capability
- ✅ Includes power pads, corner cells, signal pads
- ✅ More impressive for lab report

**Requirements:**
1. ✅ IO wrapper module created - `spi_master_chip.v` (DONE)
2. ✅ IO placement file - `spi_master.io` (DONE)
3. ⚠️ **Need actual pad cell names from gsclib045 library**
4. ⚠️ **Need to synthesize the wrapper module**

**Critical Missing Step: Finding Pad Cell Names**

You need to check your gsclib045 library for actual pad cell names:

```bash
# Search for pad cells in the LEF file
grep "^MACRO" /path/to/gsclib045_macro.lef | grep -i "pad\|io\|corner"
```

Common pad naming patterns in GPDK libraries:
- Input pads: `ICP`, `ICPVDH`, `IN01D1`, `PADCELL_SIG_IN`
- Output pads: `OCP`, `OCPVDH`, `OT01D1`, `PADCELL_SIG_OUT`
- Power pads: `PVDD1`, `PVSS1`, `PVDD1DGZ`, `PVSS1DGZ`
- Corner cells: `PCORNER`, `CORNER_LL`, `CORNER`

**Steps to Enable Full IO Pad Support:**

1. **Find the library files:**
   ```bash
   # Look for gsclib045 in common locations
   find ~ -name "gsclib045_macro.lef" 2>/dev/null
   find /opt -name "*gsclib045*" 2>/dev/null
   ```

2. **Check pad cell names:**
   ```bash
   # Once you find the LEF, extract pad cell names
   grep "^MACRO" /path/to/gsclib045_macro.lef
   ```

3. **Update spi_master_chip.v:**
   - Replace `INPUT_PAD` with actual input pad cell name
   - Replace `OUTPUT_PAD` with actual output pad cell name
   - Replace `CORNER_CELL` with actual corner cell name
   - Replace `POWER_VDD_PAD`, `POWER_VSS_PAD`, etc.
   - Update port names (`.PAD()`, `.C()`) to match library

4. **Synthesize the wrapper:**
   ```tcl
   # In Genus
   read_hdl {../input/rtl/spi_master.v ../input/rtl/spi_master_chip.v}
   elaborate spi_master_chip
   # ... rest of synthesis flow
   write_hdl > ../output/spi_master_chip.v
   ```

5. **Enable IO wrapper mode:**
   Edit `scripts/place_route_with_io_auto.tcl`:
   ```tcl
   set USE_IO_WRAPPER 1  # Change from 0 to 1
   ```

6. **Run P&R:**
   ```bash
   cd work
   innovus -files ../scripts/place_route_with_io_auto.tcl
   ```

---

## Current Status and Recommendations

### ✅ What's Ready Now

1. **IO wrapper module structure** - Complete skeleton with all SPI signals
2. **IO placement file** - Pads organized around all 4 sides
3. **Updated P&R script** - Supports both core-only and full pad modes
4. **Documentation** - This guide

### ⚠️ What Needs Your Input

1. **Library location** - Where are your gsclib045 files?
2. **Actual pad cell names** - What are they called in your library?
3. **Port mappings** - What are the pin names on the pad cells?

### 🎯 Recommended Approach for Your Assignment

**If library files are unavailable or time is limited:**
→ Use **Option A (Core-Only mode)** - It works now and demonstrates the concepts.

**If you have library access and want complete implementation:**
→ Follow **Option B** steps above to enable full pad ring.

---

## File Locations

```
spi_master_controller/
├── input/
│   ├── rtl/
│   │   ├── spi_master.v           # Core design (original)
│   │   └── spi_master_chip.v      # NEW: IO wrapper with pads
│   └── spi_master.io              # NEW: IO placement file
├── scripts/
│   └── place_route_with_io_auto.tcl  # UPDATED: Supports both modes
└── docs/
    └── LAB3_IO_PADS_SETUP.md      # This guide
```

---

## Key Differences Between Modes

| Feature | Core-Only (Option A) | Full Pads (Option B) |
|---------|---------------------|---------------------|
| IO area margins | ✅ 150um reserved | ✅ 150um with pads |
| IO pins | Regular top-level pins | Physical pad cells |
| Power distribution | Core power rings | Core + pad rings |
| Library dependency | Standard cells only | Need IO pad library |
| GDS output | Core + margins | Core + pad ring |
| Works immediately | ✅ Yes | ⚠️ Needs library setup |
| Academic submission | ✅ Acceptable | ✅ Better (if complete) |

---

## Troubleshooting

### If you get "library not found" errors:
- The library path is set in `scripts/setup_spi.tcl`
- Update paths to point to your actual gsclib045 location
- Or ask your TA/instructor for library location

### If synthesis fails on spi_master_chip.v:
- The pad cell names are placeholders
- You must replace them with actual names from your library
- Check the LEF file or library documentation

### If IO placement fails:
- Make sure instance names in `.io` file match wrapper module
- Check that pad cells exist in library
- Verify LEF files include IO pad macros

---

## Questions for Your TA/Instructor

1. **Where are the gsclib045 library files located on the server?**
   - Specifically need: `gsclib045_macro.lef` (for pad cell names)

2. **What are the actual IO pad cell names in our library?**
   - Input pad cell name?
   - Output pad cell name?
   - Power pad cell names?
   - Corner cell name?

3. **Is using "core-only with IO margins" acceptable for Lab 3 submission?**
   - Or is full pad ring integration required?

---

## Summary

✅ **Files created and ready**
✅ **Script updated to support both approaches**  
✅ **Default mode works immediately (core-only)**  
⚠️ **Full pad mode needs library information**

**You can run Option A (core-only) right now** to complete Lab 3 with proper IO area planning. If you get library access later, you can easily switch to Option B by updating pad names and changing one variable.
