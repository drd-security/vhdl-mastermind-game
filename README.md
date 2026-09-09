# VHDL Mastermind Game

Digital-electronics project implementing a hardware **Mastermind** game as a VHDL finite-state machine.

## What it demonstrates

- Finite-state-machine design in VHDL.
- Synchronous input handling and edge detection.
- Multi-position colour encoding.
- Guess evaluation with exact/partial-match feedback.
- RGB LED output control.
- Button-driven user interaction.
- Buzzer and reset/recharge-style state behavior.
- Clock division for human-scale timing.

## Design overview

The design moves through answer setup, active play, win, and reset states. Four encoded colour positions represent the secret and current guess, while feedback outputs expose exact and partial matches through LEDs.

## Source

```text
src/mastermind_game.vhd
```

A VHDL simulator/synthesis toolchain such as GHDL or the board vendor's FPGA/CPLD tools can be used to analyze the design. Pin constraints and the original laboratory board environment are not included in the surviving submission package.

## Academic context

Digital Electronics project, academic year **2024-2025**, completed by a **team of four students**. The original report identifies Dave Ronic DONKENG and three teammates.

The report itself is excluded from the portfolio copy; its technical content is summarized here in English. See [NOTICE.md](NOTICE.md).
