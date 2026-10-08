#	Binary Game
#
#	Author: Oliver Perez
#
.include "SysCalls.asm"                         # syscall equates (SysPrintString, SysReadInt, ...)

.data
round_name_b2d: .asciiz "Binary -> Decimal"     # round name shown in header
prompt_dec:     .asciiz "Enter decimal (0..255): " # prompt asking for decimal
bits_buf:       .space  16                      # buffer to hold displayed 8-bit string
newline:        .asciiz "\n"                    # newline

.text
# Local helper: convert int(0..255) in a0 â†' 8-char '0'/'1' string at a1; returns v0 = dest
intToBin8String_local:
    move $t0, $a0                               # t0 = value to convert (will shift)
    move $t1, $a1                               # t1 = dest pointer for chars
    li   $t2, 7                                 # t2 = bit index (start at MSB=7)
ib_loop:
    srlv $t3, $t0, $t2                           # t3 = (value >> bit_index)
    andi $t3, $t3, 1                             # t3 = isolate lowest bit (0/1)
    li   $t4, '0'                                # default char = '0'
    beqz $t3, ib_store                           # if bit==0, keep '0'
    li   $t4, '1'                                # else set char to '1'
ib_store:
    sb   $t4, 0($t1)                             # store char at dest
    addiu $t1, $t1, 1                            # advance dest pointer
    addiu $t2, $t2, -1                           # i--
    bgez $t2, ib_loop                            # loop while i >= 0
    sb   $zero, 0($t1)                           # NUL-terminate the generated string
    move $v0, $a1                                # v0 = dest pointer
    jr   $ra                                     # return to caller

.globl bin2DecRound
# Returns in v0: 1 = correct, 0 = incorrect, -1 = invalid input
# Flow: Show bit pattern â†' read decimal â†' validate range â†' compare â†' message.
bin2DecRound:
    addiu $sp, $sp, -32                          # make a small stack frame
    sw   $ra, 28($sp)                            # save return address
    sw   $s0, 24($sp)                            # save s0 (targetInt)
    sw   $s1, 20($sp)                            # save s1 (ptr to bits_buf)

    jal  randomNum                               # v0 = random int in [0,255]
    move $s0, $v0                                # s0 = targetInt

    move $a0, $s0                                # a0 = value to convert
    la   $a1, bits_buf                           # a1 = destination buffer
    jal  intToBin8String_local                   # v0 = &bits_buf (C-string with 8 chars)
    move $s1, $v0                                # s1 = ptr to bits string for drawing

retry_input:
    jal  clearScreen                             # clear the console (Board.asm)

    la   $a0, round_name_b2d                     # a0 = "Binary -> Decimal"
    lw   $a1, level                              # a1 = current level from game state
    lw   $a2, current_line                       # a2 = current line from game state
    lw   $a3, lines_per_level                    # a3 = total lines from game state
    jal  drawBoardHeader                         # draw header

    move $a0, $s1                                # a0 = pointer to bits string
    jal  drawBitBoxes                            # draw 8 boxes with the bits in them

    li   $v0, SysPrintString                     # print_string
    la   $a0, prompt_dec                         # a0 = "Enter decimal (0..255): "
    syscall                                      # print prompt

    li   $v0, SysReadInt                         # read_int
    syscall                                      # v0 = user-entered integer (parsed)
    move $t1, $v0                                # t1 = userInt

    move $a0, $t1                                # a0 = userInt to validate
    jal  validateDec                             # v0 = 1 if 0..255, else 0
    beqz $v0, b2d_invalid                        # if invalid, show msg and retry

    bne  $t1, $s0, b2d_incorrect                 # if userInt != targetInt â†' incorrect
    jal  showCorrectMsg                          # else correct â†' show message
    li   $v0, 1                                  # return code = 1
    j    b2d_done                                # jump to epilogue

b2d_incorrect:
    jal  showIncorrectMsg                        # show "Incorrect."
    li   $v0, 0                                  # return code = 0
    j    b2d_done                                # go to epilogue

b2d_invalid:
    jal  showInvalidMsg                          # show "Invalid input."
    j    retry_input                             # ask again with SAME target number

b2d_done:
    lw   $s1, 20($sp)                            # restore s1
    lw   $s0, 24($sp)                            # restore s0
    lw   $ra, 28($sp)                            # restore ra
    addiu $sp, $sp, 32                           # pop frame
    jr   $ra                                     # return to caller
