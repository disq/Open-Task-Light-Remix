# Electronics

## ⚠️ USE AT YOUR OWN RISK

These boards run from 20-24 V and drive a high-power LED. Build and use them at your own risk, and check everything before you power them up.

Two KiCad 10 boards that share this folder's libraries:

| Board | What it does |
|---|---|
| [Control board](#control-board-otl-control-board) (`OTL-Control-Board.*`) | Replaces the V2 board in the lamp head: LED driver, touch buttons, light and temperature sensors, run by a Seeed XIAO ESP32-C6 with the [ESPHome firmware](../esphome/). |
| [USB-PD base board](#usb-pd-base-board-otl-base-pd) (`OTL-Base-PD.*`) | Sits in a pocket in the [freestanding base](../mechanical/README.md#freestanding-base-for-the-usb-pd-board) and powers the lamp at 20 V from a USB-C charger, instead of the 24 V power supply. |

| File | What it is |
|---|---|
| `*.kicad_pro`, `*.kicad_sch`, `*.kicad_pcb` | The KiCad projects |
| `*-schematic.pdf` | Schematics |
| `*-BOM.csv`, `*-CPL-JLC.csv` | BOM and placement file for JLCPCB assembly. The BOM doubles as a shopping list. |
| `fab/` | Gerbers and drill files, zipped for ordering |
| `bom/ibom.html`, `bompd/ibom.html` | Interactive BOMs, for hand assembly |
| `lib/`, `EasyEDA.*` | Symbols, footprints and 3D models the projects use |

## Control board (OTL-Control-Board)

The outline, mounting hole, connectors, touch spring pins, light sensor and module socket are where V2 has them, so it drops into the upstream head.

| | V2 | This board |
|---|---|---|
| Controller | Adafruit QT Py ESP32-S2, CircuitPython | Seeed XIAO ESP32-C6, ESPHome |
| LED driver | RECOM RCD-24 module | AL8860 buck, 667 mA max |
| 5 V supply | RECOM R-78K5.0 module | AP63205 buck |
| Dimming | 8-bit DAC, about 90 steps | MCP4725 12-bit DAC, about 3,600 steps |
| Temperature | TMP75 | TMP1075, which also cuts the LED in hardware |
| Light sensor | VEML7700, looking sideways | VEML7700, looking straight up through the window |
| Touch | ESP32-S2 touch pins | 3x TTP223 (the ESP32-C6 has no touch pins) |
| Input protection | 1.1 A PTC | 1.5 A PTC or 2 A fuse |

### Power-up behaviour

The LED stays off at power-up until the firmware has configured the board, so a board without firmware looks dead. It also goes off in hardware above 56 °C, even if the ESP32 has crashed, and comes back below 50 °C. If the temperature sensor is missing or can't be configured, the lamp stays off.

### Pin map (XIAO)

| XIAO | GPIO | Use |
|---|---|---|
| D1 | 1 | Touch up |
| D2 | 2 | Touch power |
| D3 | 21 | Touch down |
| D4 / D5 | 22 / 23 | I2C SDA / SCL: MCP4725 (0x60), TMP1075 (0x48), VEML7700 (0x10) |
| D10 | 18 | Over-temperature alert from the TMP1075 |
| D0, D6-D9 | 0, 16, 17, 19, 20 | Free. D6 is the boot log's serial output. |

### Ordering and assembly

- JLC can assemble everything except the XIAO, its sockets and the Mill-Max 807 spring pins. Buy those separately and solder them by hand.
- U6 (the light sensor) and C14 are on the back. Solder those two by hand unless you want to pay for double-sided assembly.
- J1 and J2 (Molex Micro-Lock) and the spring pins are through-hole: use JLC's through-hole assembly or solder them by hand. LCSC's Molex stock is low, so order early.
- F1 takes either the 1812 PTC, which can only be reflowed (let JLC fit it), or a Littelfuse 0466002 1206 fuse if you're soldering by hand. The fuse doesn't reset.
- The XIAO needs low-profile sockets: 2x Samtec CES-107-01-G-S, as V2 used. Solder the XIAO's headers, pull off the plastic spacer and trim the pins to about 4.6 mm. Standard sockets put the module about 6 mm too high for the head. Don't buy the XIAO with headers already soldered.
- Check JLC's rotation preview for the ICs, diodes and C1 before ordering.
- The footprints also take these alternates: TTP223-BA6-TD for U7-U9, an FNR8040 inductor for L2, and any 47 µF 50 V 6.3 mm can up to about 6 mm tall for C1. Don't fit a taller C1: it sits next to the antenna.
- If you'll use the PD board, check your LED runs from 20 V. The CXB1512 18 V class (17.2 V typical, 19 V max) does.

### Bring-up

Flash the [firmware](../esphome/README.md#flashing) first; the LED stays dark until it runs.

- With 24 V in, check 5 V at TP6 and 3.3 V at TP7.
- At full brightness, about 100 mV across R1 (TP5 to TP8) means the full 667 mA. Less means the supply voltage is too low for your LED.
- To test the hardware cut-off, set `limit_high` to about 35 °C in the firmware and warm the board. The LED should go out even with the ESP32 stopped.
- The touch chips calibrate at power-up, so don't touch the pads while plugging in.

## USB-PD base board (OTL-Base-PD)

USB-C in, 20 V out to the lamp's barrel jack through a short lead. It sits in a pocket in the [reworked freestanding base](../mechanical/README.md#freestanding-base-for-the-usb-pd-board).

- U1 (CH224A) asks the charger for 20 V. Q1 switches the output on only once the charger has agreed, so the lamp gets nothing during negotiation or from a charger without 20 V.
- The green LED next to the USB-C lights once the output is on. It shows through a hole in the top of the base.
- The input is fused (F1) and clamped (D1).
- The charger needs a 20 V profile: every charger over 45 W has one, and most 30 W ones do. The lamp draws about 0.75 A.

### Ordering and assembly

- Order it 1.6 mm thick: the pocket and the USB-C height assume it.
- F1 is the same dual footprint as on the control board: the PTC by reflow or hotplate only, or the 1206 fuse by hand.
- Q1 is an SQ2319CES; an AO3407A drops in. Don't use ±12 V-gate parts such as the AO3401A.
- J2 is two wire pads for the lead (square = +20 V, round = GND), for wire up to 0.5 mm². It isn't in the BOM.
- It's held by 4x M2 self-tapping screws into the pocket's bosses.
