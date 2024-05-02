# Crkbd ZMK config

## Packages

This flake contains the following packages:

- `crosstool-ng` -> cross-toolchain generator used by Zephyr
    - Takes about 20 minutes to build*
- `zephyr-sdk` -> RTOS for multiple hardware architectures
    - Takes about 1h15m to build*
- `corne_left`, `corne_right`, `zmk_reset`:
    - ZMK firmware for the left & right halves of my wireless Corne, built with the config in `config/`
    - `zmk_reset` -> `settings_reset` shield, see https://zmk.dev/docs/troubleshooting#split-keyboard-halves-unable-to-pair for more info

Note: these packages are configured for the `arm-cortex_a15-linux-gnueabihf` architecture and the `arm-zephyr-eabi` toolchain, as specified by two variables at the top of the flake.

\* Build times are measured on a laptop with an AMD Ryzen 7 5800H (16 cores @ 4.46GHz)

## Repo structure

```
.
├── config
├── corne-ultralight-pcb
└── zmk-zephyr
```

`config/` contains my personal ZMK config files.

All the Kicad files in `corne-ultralight-pcb` were originally copied from [petejohanson's fork of foostan's crkbd repo](https://github.com/petejohanson/crkbd/tree/board/corne-ultralight/corne-ultralight/pcb), more specifically the `corne-ultralight` branch. This branch added support for the `nice!view` display, I then modded the PCB to support Cherry Hotswap sockets.

The `zmk-zephyr/` directory contains the minimal files necessary to run `west manifest --resolve`. The bash script in that directory can be used to parse the repos & revisions from `west manifest --resolve` to the `builtins.fetchTarball` format that Nix can use.
