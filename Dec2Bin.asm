#	Binary Game
#
#	Author: Oliver Perez
#
.include "SysCalls.asm"                         # syscall equates (SysPrintString, SysReadString, ...)

.data
round_name_d2b: .asciiz "Decimal -> Binary"     # round name shown in header
prompt_bits:    .asciiz "Enter 8 bits (only 0/1): "  # prompt for user bitstring
buf_bits:       .space  32                      # input buffer for user bits (roomy)
newline:        .asciiz "\n"                    # newline

.text
.globl dec2BinRound
# Returns in v0: 1 = correct, 0 = incorrect, -1 = invalid input
dec2BinRound:
    addiu $sp, $sp, -32                         # make a small stack frame
    sw   $ra, 28($sp)                           # save return address
    sw   $s0, 24($sp)                           # save s0 (targetInt)
    sw   $s1, 20($sp)                           # save s1 (ptr to input buffer)

    jal  randomNum                              # v0 = random int in [0,255]
    move $s0, $v0                               # s0 = targetInt

retry_input:
    jal  clearScreen                            # clear the console (Board.asm helper)

    la   $a0, round_name_d2b                    # a0 = "Decimal -> Binary"
    lw   $a1, level                             # a1 = current level from game state
    lw   $a2, current_line                      # a2 = current line from game state
    lw   $a3, lines_per_level                   # a3 = total lines from game state
    jal  drawBoardHeader                        # print header with context

    move $a0, $s0                               # a0 = targetInt
    jal  drawDecimal                            # print "Target Decimal: N"

    move $a0, $zero                             # a0 = 0 → draw placeholders "_"
    jal  drawBitBoxes                           # draw 8 empty boxes

    li   $v0, SysPrintString                    # print_string
    la   $a0, prompt_bits                       # a0 = prompt for user bits
    syscall                                     # show prompt

    li   $v0, SysReadString                     # read_string
    la   $a0, buf_bits                          # a0 = input buffer
    li   $a1, 32                                # a1 = buffer size
    syscall                                     # read user line into buffer

    # --- NEW: strip trailing newline if present ---
    # removes '\n' so validateBin sees exactly 8 chars
    la   $t0, buf_bits                          # t0 = scan ptr
d2b_strip_loop:
    lbu  $t1, 0($t0)                            # t1 = *t0
    beqz $t1, d2b_strip_done                    # if NUL stop
    li   $t2, 10                                # ASCII '\n' = 10
    beq  $t1, $t2, d2b_strip_found              # if newline found
    addiu $t0, $t0, 1                           # advance
    j    d2b_strip_loop                         # keep scanning
d2b_strip_found:
    sb   $zero, 0($t0)                          # replace '\n' with NUL
d2b_strip_done:
    # --- end NEW ---

    la   $s1, buf_bits                          # s1 = &buf_bits[0] (NUL-terminated)

    move $a0, $s1                               # a0 = pointer to user bits
    jal  validateBin                            # v0 = 1 if exactly 8 chars of {'0','1'}
    beqz $v0, d2b_invalid                       # if invalid format → show msg and retry

    move $a0, $s1                               # a0 = pointer to user bits
    jal  binStrToDecimal                        # v0 = userInt (0..255)
    move $t1, $v0                               # t1 = userInt

    bne  $t1, $s0, d2b_incorrect                # if userInt != targetInt → incorrect
    jal  showCorrectMsg                         # print "Correct!"
    li   $v0, 1                                 # return code = 1 (correct)
    j    d2b_done                               # jump to epilogue

d2b_incorrect:
    jal  showIncorrectMsg                       # print "Incorrect."
    li   $v0, 0                                 # return code = 0 (incorrect)
    j    d2b_done                               # go to epilogue

d2b_invalid:
    jal  showInvalidMsg                         # print "Invalid input."
    j    retry_input                            # ask again with SAME target number

d2b_done:
    lw   $s1, 20($sp)                           # restore s1
    lw   $s0, 24($sp)                           # restore s0
    lw   $ra, 28($sp)                           # restore ra
    addiu $sp, $sp, 32                          # pop frame
    jr   $ra                                    # return to caller
