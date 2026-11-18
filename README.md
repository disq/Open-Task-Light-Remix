# Open Task Light Remix

## ✅ Works

Built and working. The control board was built without its optional capacitors (C10, C16, C18, C20): see the [electronics notes](electronics/README.md#notes).

A remix of [Open Task Light](https://github.com/stevenbennett/Open-Task-Light) by Steven Bennett: a new control board for the head running ESPHome, a USB-C PD board in the freestanding base with the printed parts to hold it, and fixes for printed parts that don't fit. The rest of the lamp is built as upstream.

| Folder | What's in it |
|---|---|
| [`electronics/`](electronics/) | KiCad 10 projects, Gerbers, BOMs and JLC placement files for two boards: the head's control board, reworked around a Seeed XIAO ESP32-C6, and a USB-PD board that powers the lamp at 20 V from a USB-C charger. |
| [`esphome/`](esphome/) | ESPHome firmware for the control board, for Home Assistant. |
| [`mechanical/`](mechanical/) | Printed parts: the freestanding base reworked for the PD board, wider button sockets for the electronics housing, a lead counterweight lid that goes in, and a rail end cap and pulley mount that cannot turn. |

Each folder has its own README with the details.

## Licence

MIT, like upstream. See [LICENSE](LICENSE).
