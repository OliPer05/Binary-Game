# Binary-Game

A number-conversion game written in **MIPS assembly** for the MARS simulator. You convert 8-bit binary numbers to decimal, decimal numbers to binary, or a random mix of both, across 10 levels of increasing length.

## Gameplay

When the game starts, choose a mode from the menu:

1. **Binary to Decimal** – you're shown an 8-bit binary number; type its decimal value (0–255).
2. **Decimal to Binary** – you're shown a decimal number and 8 empty bit boxes; type the 8-bit binary value using only `1`s and `0`s.
3. **Both** – each question is randomly one of the two modes above.

Rules:

- Level 1 has 1 question, level 2 has 2 questions, and so on up to level 10.
- Each correct answer adds 1 point.
- An **invalid** answer (out of range, not exactly 8 bits, or containing other characters) re-asks the same question.
- A valid but **incorrect** answer ends the game and shows your final score.
- Clear all 10 levels to win.

## How to run (MARS)

1. Put all the `.asm` files in the same folder.
2. In MARS, enable **Settings → Assemble all files in directory**.
3. Open `Main.asm`, assemble, and run.

## Files

| File | Description |
|------|-------------|
| `Main.asm` | Entry point; game loop, scoring, and level progression |
| `Menu.asm` | Mode-selection menu |
| `Board.asm` | Draws the game board, round/level/line info, and result messages |
| `Bin2Dec.asm` | Binary-to-decimal round |
| `Dec2Bin.asm` | Decimal-to-binary round |
| `Validate.asm` | Input validation for binary and decimal answers |
| `RandomNum.asm` | Random number (0–255) and random mode generation |
| `SysCalls.asm` | Named constants for MARS system calls (written by John Cole) |
| `Term Project User Manual.pdf` | User manual |
