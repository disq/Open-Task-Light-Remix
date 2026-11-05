# ESPHome firmware

`open-task-light.yaml` is the firmware for the [control board](../electronics/README.md#control-board-otl-control-board): a Seeed XIAO ESP32-C6 on the ESP-IDF framework, for Home Assistant. It needs ESPHome 2026.9 or later (for `ota: encryption:` with no key) and was validated with 2026.9.1. The pin map is in the [electronics README](../electronics/README.md#pin-map-xiao).

## In Home Assistant

| Entity | What it is |
|---|---|
| Lamp | Dimmable light. The MCP4725 DAC drives the AL8860's CTRL pin, with gamma 2.2 and 400 ms transitions. After a reboot it goes back to its last state, or off if none was saved. |
| Board temperature | TMP1075, every 10 s |
| Over temperature | The TMP1075's ALERT pin: on above 56 C, off again below 50 C |
| Ambient light | VEML7700 under the window in the head's top surface, every 10 s |
| Touch power, Touch up, Touch down | The three touch pads |
| Wi-Fi signal, Uptime | Diagnostics; Wi-Fi signal every 60 s |
| Restart | Button |

## Touch controls

- **Power** toggles the lamp.
- **Up / down:** hold to change the brightness by 5% every 120 ms, down to 1% at the bottom. They do nothing while the lamp is off. The TTP223-BA6-TD touch chips cap a continuous touch at 6 s, so lift your finger and touch again to keep going.

## Over temperature

- Over temperature turns the lamp off. While it's on, anything that switches the lamp on (touch, Home Assistant, restoring after a reboot) is switched straight back off.
- It reports on only after ALERT has been high for 2 s, because ALERT reads high for a moment at power-up, before the TMP1075 is configured.
- ALERT also drives Q1, which holds the LED off in hardware above 56 C even if the ESP has crashed. See [Power-up behaviour](../electronics/README.md#power-up-behaviour).

## TMP1075 workaround

ESPHome's `tmp1075` driver (as of 2026.10) packs the config byte in reverse bit order, so its `polarity: active_high` option sets R0 instead of POL and ALERT stays active-low. An `on_boot` lambda at priority -100, after the driver's own setup, writes `0x64` to CFGR: 220 ms conversions, 1 fault, POL=1, comparator mode. Without it, Over temperature reads on at room temperature and the lamp switches itself off about 2 s after turning on. If the write fails, the lambda logs "Failed to set ALERT active-high" and the lamp stays off.

## Dimming range

`min_power: 0.17` puts CTRL at about 0.43 V at 1% brightness, about 6% of full current (~40 mA). That keeps it inside the AL8860's recommended 5-100% analog dimming range, with margin for the MCP4725's offset and the resistor and 3V3 tolerances. `zero_means_zero` sends 0 V when the lamp is off. If you want it dimmer, lower `min_power` and check for flicker at 1%.

## Antenna

ESP-IDF doesn't set up the XIAO ESP32-C6's RF switch the way the Arduino core does, so two internal switches drive GPIO3 low (RF switch powered) and GPIO14 low (onboard ceramic antenna). For an external antenna on the U.FL connector, change `rf_antenna_select`'s `restore_mode` to `ALWAYS_ON`.

## Flashing

1. Copy `secrets.example.yaml` to `secrets.yaml` (gitignored) and fill it in: a fresh API key (`openssl rand -base64 32`), your Wi-Fi, and a fallback AP password.
2. Plug the XIAO into USB (on or off the board). First flash goes over USB: `esphome run open-task-light.yaml` from this folder and pick the `/dev/cu.usbmodem…` port. If the port doesn't appear, hold BOOT while plugging it in.
3. If Wi-Fi isn't in `secrets.yaml`, set it over USB after flashing: open web.esphome.io in Chrome, Connect, then "Configure Wi-Fi" (`improv_serial`). Or join the fallback AP `open-task-light` and use the captive portal.
4. Adopt it in Home Assistant with the API key from `secrets.yaml`. Later updates go over Wi-Fi (`esphome run` picks the network target).
5. Check the "Wi-Fi signal" sensor in the housing; C1 sits near the antenna end, so below about -75 dBm is worth looking at.
