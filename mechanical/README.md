# Mechanical

## ⚠️ NOT FINISHED YET

This is a work in progress: parts are still being printed, tested and changed.

Printed parts that replace or add to the upstream Open Task Light v1.1 parts. Everything not listed here is the upstream part, printed as the upstream guide says. Print at 100% scale.

| Folder | What it's for |
|---|---|
| `freestanding-base-usbpd/` | The freestanding base, reworked to hold the [USB-PD base board](../electronics/README.md#usb-pd-base-board-otl-base-pd) |
| `electronics-housing/` | Button sockets the kit buttons fit into |
| `counterweight/` | A lid that fits the lead counterweight enclosure |

## Freestanding base for the USB-PD board

![Top view of the base with the PD board, jack and lead](freestanding-base-usbpd/base-top-view-overlay.png)

### Parts

All in `freestanding-base-usbpd/`:

- `freestanding-base-outer-shell_v1.1-usbpd.stl`: the outer shell with a walled-off pocket for the board, an opening for the USB-C, and a small hole over the board's power-good LED.
- `freestanding-base-outer-shell_v1.1-usbpd-split.stl` + `freestanding-base-outer-shell-collar_v1.1-usbpd.stl`: or the same shell in two parts, which print without supports.
- `freestanding-base-outer-shell-lid_v1.1-usbpd.stl`: a lid with a notch for the lead, for the half with the pocket. The other lid is upstream's.
- `freestanding-base-bottom-shell_v1.1-usbpd.stl` + `freestanding-base-cable-cover_v1.1-usbpd.stl`: a bottom shell with a wider pass-through for the lead, and a cover that slides in from the rim to close it and hold the lead.
- `freestanding-base-power-jack-plate_v1.0-usbpd.stl` + `freestanding-base-power-cable-cap_v1.0-usbpd.stl` (optional): for a front-mount panel jack instead of upstream's PJ-005A, with a 9.7 mm head, a 7.3 mm thread with flats 6.5 mm apart and a 10.6 mm nut, like option NO.3 on [this AliExpress listing](https://www.aliexpress.com/item/1005012757423489.html). The cap covers the pins and doubles as a spanner for the nut. Needs the modified bottom shell.
- `freestanding-base-bracket-cover_v1.1-usbpd.stl` (optional): upstream's bracket cover with a wider channel, because the L brackets jam in the original. Taking the set screws out of the brackets works too.

### Printing

- Split shell and collar: as they load, top face down, no supports, at the upstream shell settings.
- One-piece shell: "support on build plate only" reaches the pocket's ceiling through its open bottom. Clear the support out before assembly.
- Everything else: upstream's orientations, no supports. The cable cover prints flat, desk face down; the cable cap closed end down.

### Assembly

1. Split shell only: glue the collar onto the shell with CA glue, keeping glue out of the bore so the bracket cover can turn.
2. Solder the lead to the board's J2 pads, with the wires going in from the back of the board: centre pin to the square pad (+20 V), sleeve to the round pad.
3. With the shell upside down, start the board into the pocket USB-C end first, tilted about 10° and shifted about 3 mm towards the centre. Slide it outwards as it goes in and push it home, then slide it about 0.5 mm outwards so the USB-C steps into its opening. Screw it in from the back.
4. Check the notched lid sits flat on the pocket walls. Tape over the pocket, fill the shot a few mm below the pocket walls, peel the tape off and check for stray beads. Fit the notched lid with the lead through the notch.
5. Fit the bottom shell with its slot under the USB-C port. Slide the lead in along the slot from the rim, plug it into the jack, press it into the channel, and slide the cover in from the rim.

With the front-mount jack, in place of upstream's jack plate steps:

1. Push the jack into the new plate from the domed side, with its flats lined up, until its head sits down in the recess.
2. Run the nut on from the back and tighten it by turning the cable cap on it (snug: the body is plastic). Pull the cap off.
3. Shorten the pins by about 2 mm. Keep at least 3 mm to solder to. Solder the cable to the pins, + to the centre pin (check with a meter). Put heat-shrink on each joint.
4. Pass the Molex plug on the cable's other end in through the cap's hex end and out of its side slot, thin side first. The slot is wide enough for it, so the cap can come off and go back on without unsoldering.
5. Slide the cap down the cable onto the nut with its slot towards the channel on the back. If the cap does not sit fully on the nut, bend the pins in a little. Lay the lead in the channel and fit the plate as upstream.

### Weight

Use shot at least 1 mm across (S550 as upstream, or lead shot), not sand or grit, which can get past the lid into the board's pocket. M6 nuts poured in also work: about 610 g fits, against about 1,040 g of shot. A strip of thin foam on each lid stops them rattling.

### Also needed

- 4x M2x6 screws for the board. Cap-head machine screws (used here) cut their own thread in the pilot holes; self-tapping screws work too. 7 mm max.
- A right-angle DC plug with about 10 cm of lead (up to 4 mm thick, wire up to 0.5 mm²), cut from a right-angle extension that matches your jack. The one used here is the 5.5 x 2.1 mm one on [this AliExpress listing](https://www.aliexpress.com/item/1005013033782592.html); the front-mount jack plate holds it about 0.7 mm clear of the desk.
- A USB-C PD charger with a 20 V profile (most 30 W and up).

## Electronics housing

`electronics-housing/electronics-housing-button-sockets_v1.0-wide.stl`: upstream's button sockets with slightly bigger pockets, because upstream's pockets print too small for the kit buttons. The buttons are held in by friction. Print with the Arachne wall generator if your slicer has it, since the walls between the pockets are thin.

## Counterweight

`counterweight/counterweight-lid-lead_v1.0-clearance.stl`: a replacement lid for upstream's unchanged `counterweight-enclosure-lead_v1.0`. Upstream's lid has almost no clearance and won't go in once printed. This one has a thinner tongue and more room all round, and has been printed and fitted. `lid-section.png` compares the two.

Print it inner face down, no supports. To fit it, hook the tongue into the slot under the lip, push the lid towards the lip, swing the screw end in and screw it down.

## Rebuilding from the SCAD files

The SCAD files (OpenSCAD 2021.01) rebuild the STLs if you change a setting. The base and button-socket files build from upstream's STLs and look for a clone of [upstream](https://github.com/stevenbennett/Open-Task-Light) in the same folder as this repo; set `src` if yours is elsewhere. The base file picks its part with `part` (`shell`, `shell_split`, `collar`, `lid`, `bottom`, `cover`, `jack_plate`, `cable_cap`, `bracket_cover`, or `assembly`, which shows the board from `OTL-Base-PD.stl` in place). From `freestanding-base-usbpd/`:

```bash
openscad -D 'part="shell"' -o shell.stl freestanding-base-usbpd.scad
```
