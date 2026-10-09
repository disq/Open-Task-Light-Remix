# Open Task Light Control Board: XIAO ESP32-C6 / ESPHome rev

A KiCad 10 rework of the Open Task Light V2 Control Board (Steven Bennett). The board outline, mounting hole,
XIAO/QT Py socket position, LED and power connectors, the three touch spring pins and the light sensor all stay
where they were on V2. The electronics are redesigned around jellybean parts and Home Assistant via ESPHome.

**Status:** fully routed. GND pours on both layers, antenna keepout under the XIAO. ERC and DRC are clean (0 violations, 0 unconnected, board matches schematic).

## What changed vs V2

| Function | V2 | This rev |
|---|---|---|
| MCU | Adafruit QT Py ESP32-S2 (CircuitPython) | Seeed XIAO ESP32-C6 (ESPHome, Wi-Fi/Thread/Zigbee capable), same socket footprint |
| LED driver | RECOM RCD-24-0.70/VREF module | AL8860 (MSOP-8EP) hysteretic buck, R1 = 0.15R -> 667 mA max |
| 5V rail | RECOM R-78K5.0-1.0 module | AP63205 synchronous buck, fixed 5V |
| Dimming | ESP32-S2 8-bit DAC -> diode -> RCD Vref | MCP4725 12-bit I2C DAC -> 1k/3.3k divider -> AL8860 CTRL |
| Boot / thermal gate | TS12A4515 analog switch | Q1 AO3400A on CTRL, gate on the TMP1075 ALERT pin. Holds the LED off until ESPHome has configured the board, and cuts it in hardware above 56 C |
| Temperature | TMP75-Q1 | TMP1075 (same SOIC-8 pinout, native ESPHome), ALERT on D10 and Q1 |
| Light sensor | VEML7700 | VEML7700 (unchanged, same spot on the back) |
| Touch | ESP32-S2 touch pins | 3x TTP223 (the ESP32-C6 has no touch peripheral) |
| Protection | SMF4L24A TVS, 1.1 A PTC | SMF24A TVS, 1.5 A PTC (1812) or 2 A chip fuse (1206) on a dual footprint |
| Passives | 1206 | 0603 jellybean, larger only where voltage, power or routing needs it |

Dimming resolution: CTRL is linear from 0.3 V (0%) to 2.5 V (100%). With the divider, DAC full scale is 2.53 V, which
leaves about 3600 usable steps out of 4096, against roughly 90 on V2.

### Power-up behaviour

The MCP4725 ships with mid-scale (0x800) in its EEPROM, so on its own it would drive the LED to about half brightness at
power-up. Q1 prevents that:

1. At power-up the TMP1075 ALERT pin is active-low and idle, so it floats high through R6. Q1 turns on and holds CTRL at 0 V: the LED stays off, whatever the DAC outputs.
2. ESPHome switches ALERT to active-high. ALERT now sits low, Q1 turns off, and the DAC controls the LED.
3. Above 56 C ALERT releases, Q1 turns on and the LED goes off in hardware, even if the ESP has crashed. It comes back below 50 C.

If the TMP1075 is missing or can't be configured, the lamp stays off. An OTA reboot doesn't reset the TMP1075, so the
LED keeps its level through the reboot.

## Pin map (XIAO)

Checked against the arduino-esp32 `XIAO_ESP32C6` board variant.

| XIAO | GPIO | Net |
|---|---|---|
| D0 | 0 | free (kept off GPIO0 on purpose) |
| D1 | 1 | TOUCH_UP (U9 / BTN+ spring pin) |
| D2 | 2 | TOUCH_PWR (U7 / POWER spring pin) |
| D3 | 21 | TOUCH_DOWN (U8 / BTN- spring pin) |
| D4 / D5 | 22 / 23 | I2C SDA / SCL (MCP4725 0x60, TMP1075 0x48, VEML7700 0x10) |
| D6 | 16 | free. UART0 TX: the ROM prints on it at boot, so don't put a push-pull input here |
| D7-D9 | 17, 19, 20 | free |
| D10 | 18 | TEMP_ALERT (TMP1075 ALERT, open-drain, R6 10k pull-up, Q1 gate) |

None of the used pins are ESP32-C6 strapping pins (GPIO4/5/8/9/15). The XIAO's internal RF switch uses GPIO3 (low = on) and
GPIO14 (low = onboard antenna); the ESPHome config drives both low at boot.

## Files

- `OTL-Control-Board.kicad_pro / .kicad_sch / .kicad_pcb`: the KiCad 10 project. Every part has a `Description` field saying what it does (e.g. "Input capacitor for U2 (5V buck)")
- `lib/OTL.kicad_sym`, `lib/OTL.pretty`: custom symbols (XIAO, TTP223, VEML7700) and footprints, including the two dual footprints (L2, F1). The mechanical footprints were converted from the V2 Eagle board, so the positions match exactly
- `OTL-Control-Board-BOM.csv`: full BOM with description, MPN and LCSC part numbers
- `OTL-Control-Board-BOM-JLC.csv`: JLCPCB assembly BOM (Comment / Designator / Footprint / LCSC Part #, DNP parts left out)
- `OTL-Control-Board-schematic.pdf`: the schematic
- `OTL-Control-Board.kicad_dru`: JLCPCB design-rule limits and per-netclass track widths
- `esphome/open-task-light.yaml`: the full firmware config (validated with ESPHome 2026.9.1; `ota: encryption: {}` needs ESPHome 2026.9 or later). Copy `secrets.example.yaml` to `secrets.yaml` and fill it in

## Layout notes

- **AL8860 (U3):** D3 sits beside U3, so the SW_LED node (U3 pins 5/6 -> D3 anode -> L2) is all on F.Cu with no vias. C9 (100 nF) is 2.1 mm from U3 VIN and C8 (10 uF) is 3.7 mm away, next to D3's cathode, with GND vias at their pads. U3 has GND vias in and around its exposed pad.
- **R1 (current sense):** U3 VIN reaches R1 through a trace that also carries the LED current, so the sense isn't Kelvin. Expect the LED current a few percent below 667 mA.
- **AP63205 (U2):** C21 (100 nF 0805) sits directly across VIN (pin 3) and GND (pin 4), with C3 (10 uF) close by. SW_5V is on F.Cu with no vias. FB is taken from L1's output pad on a short track. C5/C6 are 22 uF 25 V 1206 parts. The 5V output track from L1 to C5 passes under L1 between its pads; L1 is shielded, but routing it around would be cleaner.
- **Bulk capacitor:** C1 (47 uF, 8 mm tall can) sits where the tail starts, on the 24V run between the input and the drivers, well away from the XIAO's antenna.
- **LED cable:** J2 pin 2 (LED+) sits on the quiet sense-resistor side. LED- goes through L2, so neither wire to the LED carries the raw switching node.
- **Touch:** the PAD_* traces from the spring pins to the TTP223 inputs are 0.2 mm with 0.3 mm clearance. C16/C18/C20 are optional sensitivity trims (C0G, 0-50 pF). The TTP223 calibrates at power-up, so don't touch the pads while plugging in.
- **Ground and antenna:** one GND zone on F.Cu and B.Cu covering the whole outline, with stitching vias. `KEEPOUT_ANTENNA` (both layers) keeps tracks, vias and pour away from the XIAO's antenna end. Keep tall parts away from it too.
- **XIAO footprint:** the courtyard covers only the header rows, because the module sits on sockets. U7 and C15/C16 sit underneath it, so use low-profile parts there and check the socket height.
- **Design rules:** JLCPCB's standard 2-layer limits (no extra-cost options), with the extras in `OTL-Control-Board.kicad_dru`. No track thinner than 0.2 mm. Vias at least 0.45 mm across with a 0.3 mm drill. Clearance at least 0.127 mm, copper 0.3 mm from the board edge, through-hole pads keep at least a 0.18 mm ring, silkscreen text at least 1.0/0.15 mm.
- **Netclasses:** `HighCurrent` 0.8 mm (+24V, VIN_RAW, LED+, LED-, SW_LED). `Power` 0.5 mm (+5V, XIAO_5V, SW_5V, GND). `Power3V3` 0.3 mm (+3V3). `Touch` 0.2 mm with 0.3 mm clearance (PAD_*). `Default` 0.25 mm for everything else. The `.kicad_dru` rules set the router width (`opt`) and DRC minimum: HighCurrent 0.8 (min 0.5), Power 0.5 (min 0.3), Touch 0.2. Inside the U2/U3 footprints, power tracks can neck down to 0.2 mm to reach the fine-pitch pins.

## Parts and sourcing (checked against JLC/LCSC stock, 2026-10-08)

Every assembled part has an `LCSC Part` field (schematic and board). The parts without one (XIAO, Mill-Max 807 spring
pins, 1x7 female headers, mounting hole) are bought separately or are mechanical.

Where a part was swapped for a better-stocked one, the board accepts both the original and the replacement:

| Ref | Original | Alternate | Footprint |
|---|---|---|---|
| U7-U9 | TTP223-BA6 (Tontek, out of stock) | TTP223-BA6-TD (TDSEMIC) | Same SOT-23-6 and the same pinout. Pins 4 (SLH = AHLB) and 6 (STG = TOG) must not float; both are tied to GND |
| L2 | SRN1060-470M (10x10) | FNR8040S470MT (8x8) | `OTL:L_SRN1060_FNR8040_Dual`: copper is the SRN1060 land, paste is the FNR8040 land, so either part fits |
| C1 | 47 uF 50 V 6.3x7.7 | 50TZV47M6.3X8 (6.3x8) | Same 6.3 mm can land, so no change |
| F1 | SMD1812P150TF/33 (1812 PTC, 1.5 A hold, 33 V) | Littelfuse 0466002.NRHF (1206, 2 A one-time fuse) | `OTL:Fuse_1812_1206_Dual`: copper is the union of both lands, paste is on the 1812 lands only. JLC reflows the PTC; fit the 1206 fuse by hand |

Notes:
- The TTP223-BA6-TD caps a continuous touch at 6 s. Hold-to-dim stops after 6 s; lift your finger and touch again.
- The SMD1812 PTC datasheet forbids hand soldering and hot-air rework: let JLC reflow it, or use a hotplate. If you're hand-assembling, fit the Littelfuse 0466002 1206 fuse instead. It doesn't reset, so it only blows on a real fault.
- The Mill-Max 807 spring pins and the XIAO aren't available through JLC assembly; source them separately and hand-solder.
- The Molex Micro-Lock connectors are on LCSC, but stock is low (about 99 and 27 when checked). Order them early.

## Ordering and assembly

- **Bottom side:** U6 (VEML7700) and C14 are on the back. Having JLC place them means double-sided assembly, which costs noticeably more; hand-soldering those two is the cheap option.
- **Through-hole:** J1 and J2 (Molex) and the TP1-TP3 spring pins need JLC's THT assembly or hand soldering.
- **Pick-and-place:** when you export the CPL file, check JLC's rotation preview for the SOT-23, TSOT-23-6, MSOP-8EP, SOIC-8, SMA and electrolytic parts; these most often come out rotated.
- **Housing:** C1 is an 8 mm tall can at the start of the tail. Check that the printed housing clears it there.

## Bring-up

- The LED stays dark until ESPHome is running (Q1 holds it off), so a bare board looks dead. Flash the firmware first, then test the LED.
- To test the hardware thermal cut-off, temporarily set `limit_high` low (e.g. 35 C) and warm the board. The LED should go out even with the ESP stopped.
- Check for flicker at minimum brightness. The floor is about 2.5% of full current and can vary 1-4% between boards (MCP4725 offset, resistor and 3V3 tolerances). If it flickers, raise `min_power` from 0.14 to about 0.16.
- Before ordering, confirm the LED's forward voltage at 667 mA. The CXB1512 18 V class sits around 19-20 V, which gives roughly 300 kHz and 80% duty on 24 V. If yours runs much higher, check the AL8860 duty and on-time limits.
