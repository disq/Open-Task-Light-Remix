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
| Light sensor | VEML7700-TR (side view) | VEML7700-TT (C1850416, top-view mounting), same spot on the back. It lies flat and looks straight up through the window in the lamp head's top surface. The -TR stands up and looks sideways at the window pocket's wall, so it only sees light scattered by the window floor. -TR and -TT use different land patterns, so don't swap them without changing the footprint |
| Touch | ESP32-S2 touch pins | 3x TTP223 (the ESP32-C6 has no touch peripheral) |
| Protection | SMF4L24A TVS, 1.1 A PTC | SMF24A TVS, 1.5 A PTC (1812) or 2 A chip fuse (1206) on a dual footprint |
| Passives | 1206 | 0603 jellybean, larger only where voltage, power or routing needs it |

Dimming resolution: CTRL is linear from 0.3 V (0%) to 2.5 V (100%). C11 (1 uF) on CTRL filters it with a 0.77 ms time constant (767 ohm divider x 1 uF), which also strips 3V3 ripple that reaches CTRL through the DAC, since the MCP4725 uses its supply as reference. With the divider, DAC full scale is 2.53 V, which
leaves about 3600 usable steps out of 4096, against roughly 90 on V2.

### Power-up behaviour

The MCP4725 ships with mid-scale (0x800) in its EEPROM, so on its own it would drive the LED to about half brightness at
power-up. Q1 prevents that:

1. At power-up the TMP1075 ALERT pin is active-low and idle, so it floats high through R6. Q1 turns on and holds CTRL at 0 V: the LED stays off, whatever the DAC outputs.
2. ESPHome switches ALERT to active-high. ALERT now sits low, Q1 turns off, and the DAC controls the LED.

   ESPHome's `tmp1075` driver (as of 2026.10) packs the config byte in reverse bit order, so its `polarity: active_high`
   option sets R0 instead of POL and ALERT stays active-low. The firmware works around this with an `on_boot` lambda
   that writes `0x64` to CFGR (220 ms conversions, 1 fault, POL=1, comparator) after the driver's own setup. Without it
   "Over temperature" reads on at room temperature and the lamp switches itself off about 2 s after turning on.
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
- `EasyEDA.pretty`, `EasyEDA.kicad_sym`, `EasyEDA.3dshapes`: manufacturer footprints, symbols and 3D models imported from EasyEDA/LCSC for C1, D1, D3, J1 and U6 (project-local, so the project opens on any machine). J1's pads are numbered the other way round from V2, but the 24V pad is still on the right ("24V" silkscreen), so the power cable polarity is unchanged
- `OTL-Control-Board-BOM.csv`: the BOM, one row per distinct part (grouped by LCSC number and footprint), in JLCPCB's column format (Comment / Designator / Footprint / LCSC Part #) plus MPN and Qty, so the same file uploads to JLC and works as a shopping list. DNP parts (C10, C16, C18, C20) and the bare test points TP4-TP8 are left out; per-part descriptions are in the schematic's `Description` field
- `OTL-Control-Board-CPL-JLC.csv`: JLCPCB placement file (Designator / Mid X / Mid Y / Layer / Rotation), parts with an LCSC number only. Coordinates are body centres in KiCad's absolute board coordinates (U6, J1 and J2 have their footprint origin off-centre, so they're corrected), so export Gerbers without "use drill/place file origin"
- `OTL-Control-Board-schematic.pdf`: the schematic
- `OTL-Control-Board.kicad_dru`: JLCPCB design-rule limits and per-netclass track widths
- `esphome/open-task-light.yaml`: the full firmware config (validated with ESPHome 2026.9.1; `ota: encryption: {}` needs ESPHome 2026.9 or later). Copy `secrets.example.yaml` to `secrets.yaml` and fill it in

## Layout notes

- **AL8860 (U3):** D3 sits beside U3, so the SW_LED node (U3 pins 5/6 -> D3 anode -> L2) is all on F.Cu with no vias. C9 (100 nF) is 2.1 mm from U3 VIN and C8 (10 uF) is 3.7 mm away, next to D3's cathode, with GND vias at their pads. U3 has GND vias in and around its exposed pad.
- **R1 (current sense):** U3 VIN reaches R1 through a trace that also carries the LED current, so the sense isn't Kelvin. Expect the LED current a few percent below 667 mA.
- **AP63205 (U2):** C21 (100 nF 0805) sits directly across VIN (pin 3) and GND (pin 4), with C3 (10 uF) close by. SW_5V is on F.Cu with no vias. FB is taken from L1's output pad on a short track. C5/C6 are 22 uF 25 V 1206 parts. The 5V output track from L1 to C5 passes under L1 between its pads; L1 is shielded, but routing it around would be cleaner.
- **Bulk capacitor:** C1 (47 uF Lelon VZT, 6.3 mm can, 5.8 mm tall) sits at the top of the head, on the 24V run near U3, as on V2. Its body ends about 1.3 mm from the XIAO's antenna end and overlaps `KEEPOUT_ANTENNA` by about 1 mm (only its pads are checked by DRC). The low-profile can keeps the RF impact small, but check Wi-Fi signal strength in the housing, and don't fit a taller can here.
- **Test points:** TP4 CTRL, TP5 +24V, TP6 +5V, TP7 +3V3, TP8 LED+ (1.5 mm pads). They're excluded from the BOM and the position files, so JLC leaves them bare.
- **3V3 bulk:** C22 (10 uF 0805) backs up the 3V3 rail that the DAC uses as its reference, together with C11 on CTRL.
- **LED cable:** J2 pin 2 (LED+) sits on the quiet sense-resistor side. LED- goes through L2, so neither wire to the LED carries the raw switching node.
- **Touch:** the PAD_* traces from the spring pins to the TTP223 inputs are 0.2 mm with 0.3 mm clearance. C16/C18/C20 are optional sensitivity trims (C0G, 0-50 pF). The TTP223 calibrates at power-up, so don't touch the pads while plugging in.
- **Ground and antenna:** one GND zone on F.Cu and B.Cu covering the whole outline, with stitching vias. `KEEPOUT_ANTENNA` (both layers) keeps tracks, vias and pour away from the XIAO's antenna end. Keep tall parts away from it too.
- **XIAO footprint:** the courtyard covers only the header rows, because the module sits on sockets. U7 and C15/C16 sit underneath it; with the low-profile CES sockets (see Ordering and assembly) there's room for 0603 and SOT-23 parts.
- **Design rules:** JLCPCB's standard 2-layer limits (no extra-cost options), with the extras in `OTL-Control-Board.kicad_dru`. No track thinner than 0.2 mm. Vias at least 0.45 mm across with a 0.3 mm drill. Clearance at least 0.127 mm, copper 0.3 mm from the board edge, through-hole pads keep at least a 0.18 mm ring, silkscreen text at least 1.0/0.15 mm.
- **Netclasses:** `HighCurrent` 0.8 mm (+24V, VIN_RAW, LED+, LED-, SW_LED). `Power` 0.5 mm (+5V, XIAO_5V, SW_5V, GND). `Power3V3` 0.3 mm (+3V3). `Touch` 0.2 mm with 0.3 mm clearance (PAD_*). `Default` 0.25 mm for everything else. The `.kicad_dru` rules set the router width (`opt`) and DRC minimum: HighCurrent 0.8 (min 0.5), Power 0.5 (min 0.3), Touch 0.2. Inside the U2/U3 footprints, power tracks can neck down to 0.2 mm to reach the fine-pitch pins.

## Parts and sourcing (checked against JLC/LCSC stock, 2026-10-08)

Every assembled part has an `LCSC Part` field (schematic and board). The parts without one (XIAO, Mill-Max 807 spring
pins, XIAO sockets, mounting hole) are bought separately or are mechanical.

Where a part was swapped for a better-stocked one, the board accepts both the original and the replacement:

| Ref | Original | Alternate | Footprint |
|---|---|---|---|
| U7-U9 | TTP223-BA6 (Tontek, out of stock) | TTP223-BA6-TD (TDSEMIC) | Same SOT-23-6 and the same pinout. Pins 4 (SLH = AHLB) and 6 (STG = TOG) must not float; both are tied to GND |
| L2 | SRN1060-470M (10x10) | FNR8040S470MT (8x8) | `OTL:L_SRN1060_FNR8040_Dual`: copper is the SRN1060 land, paste is the FNR8040 land, so either part fits |
| C1 | Lelon VZT470M1HTR-0606 (C688950, 6.3x5.8) | Any 47 uF 50 V 6.3 mm can up to ~6 mm tall | Same 6.3 mm can land. Avoid taller cans such as the 8 mm 50TZV47M6.3X8: C1 sits next to the XIAO's antenna end |
| F1 | SMD1812P150TF/33 (1812 PTC, 1.5 A hold, 33 V) | Littelfuse 0466002.NRHF (1206, 2 A one-time fuse) | `OTL:Fuse_1812_1206_Dual`: copper is the union of both lands, paste is on the 1812 lands only. JLC reflows the PTC; fit the 1206 fuse by hand |

Notes:
- The TTP223-BA6-TD caps a continuous touch at 6 s. Hold-to-dim stops after 6 s; lift your finger and touch again.
- The SMD1812 PTC datasheet forbids hand soldering and hot-air rework: let JLC reflow it, or use a hotplate. If you're hand-assembling, fit the Littelfuse 0466002 1206 fuse instead. It doesn't reset, so it only blows on a real fault.
- The Mill-Max 807 spring pins and the XIAO aren't available through JLC assembly; source them separately and hand-solder.
- The Molex Micro-Lock connectors are on LCSC, but stock is low (about 99 and 27 when checked). Order them early.

## Ordering and assembly

- **Bottom side:** U6 (VEML7700) and C14 are on the back. Having JLC place them means double-sided assembly, which costs noticeably more; hand-soldering those two is the cheap option.
- **Through-hole:** J1 and J2 (Molex) and the TP1-TP3 spring pins need JLC's THT assembly or hand soldering.
- **XIAO sockets (height matters):** use 2x Samtec **CES-107-01-G-S**, the 5.08 mm low-profile 1x7 sockets V2 used (DigiKey/Mouser; LCSC C3320114 has very little stock), or an equivalent low-profile socket. Solder the XIAO's male headers, then pull off the plastic header insulator (spacer) and trim the pins to about 4.6 mm, as V2 did with the QT Py. Generic 8.5 mm sockets plus the spacer lift the module about 6 mm higher than V2, which the head can't take: the LED assembly sits below it. Don't buy the pre-soldered XIAO.
- **Pick-and-place:** when you export the CPL file, check JLC's rotation preview for the SOT-23, TSOT-23-6, MSOP-8EP, SOIC-8, SMA and electrolytic parts and U6; these most often come out rotated.
- **Housing:** C1 is a 5.8 mm tall can at the top of the head, next to the XIAO's antenna end. Check that the printed housing clears it.

## Bring-up

### Flashing

1. Copy `esphome/secrets.example.yaml` to `esphome/secrets.yaml` (gitignored) and fill it in: a fresh API key (`openssl rand -base64 32`), your Wi-Fi, and a fallback AP password.
2. Plug the XIAO into USB (on or off the board). First flash goes over USB: `esphome run esphome/open-task-light.yaml` and pick the `/dev/cu.usbmodem…` port. If the port doesn't appear, hold BOOT while plugging it in.
3. If Wi-Fi isn't in `secrets.yaml`, set it over USB after flashing: open web.esphome.io in Chrome, Connect, then "Configure Wi-Fi" (`improv_serial`). Or join the fallback AP `open-task-light` and use the captive portal.
4. Adopt it in Home Assistant with the API key from `secrets.yaml`. Later updates go over Wi-Fi (`esphome run` picks the network target).
5. Check the "Wi-Fi signal" sensor in the housing; C1 sits near the antenna end, so below about -75 dBm is worth looking at.

### First power-up checks

- With 24 V in, check 5 V at TP6 and 3.3 V at TP7. TP4 (CTRL) should read 0 V before the firmware has configured the TMP1075.
- The LED stays dark until ESPHome is running (Q1 holds it off), so a bare board looks dead. Flash the firmware first, then test the LED.
- To test the hardware thermal cut-off, temporarily set `limit_high` low (e.g. 35 C) and warm the board. The LED should go out even with the ESP stopped.
- Minimum brightness: `min_power: 0.17` puts CTRL at about 0.43 V, so the dimmest setting is about 6% of full current (~40 mA). That keeps it inside the AL8860's recommended 5-100% analog range. With the MCP4725 offset and resistor and 3V3 tolerances, expect roughly 5-7% between boards. Check for flicker at minimum brightness; if you want it dimmer and it stays stable, you can lower `min_power`.
- Measured on the first board: CTRL 1.9 mV off, 0.429 V at 1%, 2.515 V at 100%. TEMP_ALERT (D10) reads about 0 V once configured.
- Before ordering, confirm the LED's forward voltage at 667 mA. Cree's datasheet gives the CXB1512 18 V class as 17.2 V typical and 19 V maximum at 700 mA (Tj 85 C), which is about 73% duty on 24 V and about 90% on the 20 V base board. To check the headroom, measure across R1 (TP5 to TP8) at full brightness: 100 mV is the full 667 mA, less means the input is too low for your LED.

## USB-PD base board (OTL-Base-PD)

A separate board for the pocket in the base: USB-C in, 20 V out to the centre barrel jack, in place of the external 24 V supply. The outline, mounting holes and USB-C position follow the OTL_PD24 concept (37 mm wide annular sector, outer arc R84.5 on the wall, inner arc R63, 4x M2, receptacle face 1.35 mm past the edge), so its pocket changes still apply. The boost from that concept is gone: the head runs straight from 20 V.

- **Circuit:** F1 sits right after J1, so everything after it (TVS included) is fused: J1's VBUS pins are `VBUS_IN`, the rest is `VBUS`. U1 (CH224A) asks for 20 V (R1 = 120k on CFG1). Q1 (SQ2319CES, high-side P-FET, -40 V / ±20 V gate) passes VBUS to the output only once PG goes low, so the head sees nothing during negotiation or from a charger without 20 V. R2/C2 hold the gate at the source. C2 is 21x C3, so a 5 to 20 V VBUS step moves the gate by under 0.7 V, below Q1's 1 V minimum threshold. With PG low, R2/R3 give Vgs = -VBUS/2: -10 V at 20 V, and -19.5 V even at the SMF24A's 38.9 V maximum clamp. C3 (gate to drain) ramps the output at about 3 V/ms, about 0.2 A into the head's capacitors. D1 (SMF24A) clamps VBUS. D2 (green, R4 = 15k, about 1.1 mA) next to the USB-C hangs off the switched output, so it lights once PG has turned the output on and adds no load on PG. A PD charger only applies the voltage the sink asked for, so the output stays at 20 V +5%.
- **Q1 choice:** the SQ2319CES is rated -40 V, which covers the TVS's worst-case clamp (38.9 V); the AO3407A (-30 V, ±20 V, same pinout) drops in with the same R2/R3/C3. Avoid ±12 V-gate parts such as the AO3401A here unless R3 goes to 150k and C3 to 22 nF.
- **Why a P-FET:** the switch is in the +20 V line. An N-FET there (AO3400) would need its gate above 20 V. As a low-side switch it would switch the head's ground, which then floats when off and gets bypassed through the XIAO's USB ground. PG is also active-low, which suits a P-FET directly. A BSS138 is too small for the 0.75 A load.
- **CC and D+/D-:** J1 CC1/CC2 go straight to U1 CC1/CC2; CC1 crosses under CC2 on the bottom layer. D+/D- go to U1 pins 4/5 (A6/B6 and A7/B7 bridged, so both plug orientations work). PD itself only uses CC; D+/D- give U1 its BC1.2/QC fallback, and the datasheet's reference circuits connect them.
- **Charger:** it needs a 20 V PDO (mandatory above 45 W, offered by most 30 W chargers). The lamp draws about 0.75 A at 20 V.
- **Files:** `OTL-Base-PD.kicad_pro / .kicad_sch / .kicad_pcb` (shares this folder's library tables; the CH224A symbol is in `lib/OTL.kicad_sym`), `OTL-Base-PD.kicad_dru`, `OTL-Base-PD-BOM.csv`, `OTL-Base-PD-CPL-JLC.csv` (same formats as the head board), `OTL-Base-PD-schematic.pdf`, and the fab outputs in `fab/base-pd-gerbers/` zipped as `fab/OTL-Base-PD-gerbers.zip` (Protel extensions, X2 as comments, separate PTH/NPTH Excellon in mm, absolute origin, like the head board's).
- **Status:** routed. ERC and DRC are clean (0 violations, 0 unconnected), and the board matches the schematic. GND pours on both layers. Net classes: `Power` (/VBUS_IN, VBUS, /VOUT, GND) 0.5 mm, min 0.3 mm, neck-down to 0.25 mm inside J1/U1/Q1. `Default` 0.25 mm for CC, DP/DM, PG, GATE, CFG1 and LED_A.
- **Routing notes:** J1's two VBUS pads must be joined on the board (both are `VBUS_IN`, into F1 pin 1), and nothing else may connect before F1. U1 pin 8 (VBUS) and pin 1 (VHV) must both go to the fused VBUS (the datasheet says to short them). U1's GND is only the exposed pad, through its thermal vias.
- **Assembly:** F1 is the head board's dual footprint: the SMD1812P150TF/33 PTC (1.5 A hold, resettable) on the 1812 lands, or a Littelfuse 0466002.NRHF (1206, 2 A, one-time) on the inner 1206 lands. The PTC datasheet forbids iron and hot-air soldering, so fit it only with a hotplate or oven reflow; with hot air, use the 1206 fuse. J2 (two 0.9 mm wire pads for the 22 AWG pigtail: square = +20 V, round = GND) and the mounting holes are not in the BOM/CPL. KiCad's library has no 3D model for the HRO connector. The hole positions, (3, 5), (34, 5), (3, 21.2) and (34, 21.2) mm from the board's top-left corner, were read from the concept drawing: check them against the pocket bosses.
