#	Binary Game
#
#	Author: Oliver Perez
#
.include "SysCalls.asm"                       

.data
title:           .asciiz "====================  BINARY GAME  ====================\n"  # banner line
round_lbl:       .asciiz "Round: "            # label before the round name
lvl_lbl:         .asciiz "     Level "        # label before the level number
comma_space:     .asciiz ", "                 # simple ", " separator
line_of_lbl:     .asciiz "Line "              # label before current line number
of_lbl:          .asciiz " of "               # label between current and total lines
newline:         .asciiz "\n"                 # newline string for convenience
target_dec_lbl:  .asciiz "Target Decimal: "   # label used in Dec→Bin
msg_correct:     .asciiz "\nCorrect!\n"       # message for correct answer
msg_incorrect:   .asciiz "\nIncorrect.\n"     # message for incorrect answer
msg_invalid:     .asciiz "\nInvalid input.\n" # message for invalid input/format
box_open:        .asciiz "[ "                 # left bracket of a bit “box”
box_close:       .asciiz " ] "                # right bracket of a bit “box”
box_gap:         .asciiz "   "                # extra spacing between nibbles (after 4 boxes)
underscore_cstr: .byte '_' , 0                # '_' as a C-string so we can print it with print_string

.text
.globl clearScreen
clearScreen:
    li   $t0, 30                              # t0 = how many newlines to print (pseudo clear)
cs_loop:
    li   $v0, SysPrintString                  # choose print_string syscall
    la   $a0, newline                         # a0 = address of "\n"
    syscall                                   # print one newline
    addiu $t0, $t0, -1                        # t0--
    bgtz $t0, cs_loop                         # if t0 > 0, loop
    jr   $ra                                  # return to caller

.globl drawBoardHeader
# a0 = ptr to round name (string), a1 = level, a2 = current line, a3 = total lines
drawBoardHeader:
    move $t0, $a0                             # t0 = saved round name pointer
    move $t1, $a1                             # t1 = saved level
    move $t2, $a2                             # t2 = saved current line
    move $t3, $a3                             # t3 = saved total lines

    li   $v0, SysPrintString                  # print_string
    la   $a0, title                           # a0 = banner text
    syscall                                   # print banner

    li   $v0, SysPrintString                  # print_string
    la   $a0, round_lbl                       # a0 = "Round: "
    syscall                                   # print label

    li   $v0, SysPrintString                  # print_string
    move $a0, $t0                             # a0 = round name (saved)
    syscall                                   # print round name

    li   $v0, SysPrintString                  # print_string
    la   $a0, lvl_lbl                         # a0 = "     Level "
    syscall                                   # print label

    li   $v0, SysPrintInt                     # print_int
    move $a0, $t1                             # a0 = level
    syscall                                   # print level number

    li   $v0, SysPrintString                  # print_string
    la   $a0, comma_space                     # a0 = ", "
    syscall                                   # print separator

    li   $v0, SysPrintString                  # print_string
    la   $a0, line_of_lbl                     # a0 = "Line "
    syscall                                   # print label

    li   $v0, SysPrintInt                     # print_int
    move $a0, $t2                             # a0 = current line number
    syscall                                   # print line number

    li   $v0, SysPrintString                  # print_string
    la   $a0, of_lbl                          # a0 = " of "
    syscall                                   # print separator

    li   $v0, SysPrintInt                     # print_int
    move $a0, $t3                             # a0 = total lines
    syscall                                   # print total lines

    li   $v0, SysPrintString                  # print_string
    la   $a0, newline                         # a0 = "\n"
    syscall                                   # newline
    jr   $ra                                  # return

.globl drawDecimal
# a0 = decimal value 0..255 to display under the header
drawDecimal:
    move $t0, $a0
    li   $v0, SysPrintString                  # print_string
    la   $a0, target_dec_lbl                  # a0 = "Target Decimal: "
    syscall                                   # print label

    li   $v0, SysPrintInt                     # print_int
    move $a0, $t0 
    syscall                                   # print decimal number

    li   $v0, SysPrintString                  # print_string
    la   $a0, newline                         # a0 = "\n"
    syscall                                   # newline
    jr   $ra                                  # return

.globl drawBitBoxes
# a0 = ptr to 8-char '0'/'1' string (if a0==0, draw placeholders "_")
drawBitBoxes:
    move $t0, $a0                             # t0 = saved pointer (or 0)
    li   $t1, 0                               # t1 = index i from 0..7
db_loop:
    li   $v0, SysPrintString                  # print_string
    la   $a0, box_open                        # a0 = "[ "
    syscall                                   # draw left bracket

    beq  $t0, $zero, db_print_blank           # if no string, draw underscore
    addu $t2, $t0, $t1                        # t2 = &bits[i]
    lbu  $a0, 0($t2)                          # a0 = bits[i] ('0' or '1', ASCII)
    li   $v0, SysPrintChar                    # print_char
    syscall                                   # print that single char
    j    db_after_char                        # skip blank branch

db_print_blank:
    li   $v0, SysPrintString                  # print_string
    la   $a0, underscore_cstr                 # a0 = "_" as C-string
    syscall                                   # print underscore

db_after_char:
    li   $v0, SysPrintString                  # print_string
    la   $a0, box_close                       # a0 = " ] "
    syscall                                   # draw right bracket

    addiu $t1, $t1, 1                         # i++
    beq  $t1, 4, db_gap                       # after 4 boxes, add extra spacing
    beq  $t1, 8, db_end                       # after 8 boxes, finish row
    j    db_loop                              # otherwise keep looping

db_gap:
    li   $v0, SysPrintString                  # print_string
    la   $a0, box_gap                         # a0 = spacing between nibbles
    syscall                                   # print gap
    j    db_loop                              # continue with next box

db_end:
    li   $v0, SysPrintString                  # print_string
    la   $a0, newline                         # a0 = "\n"
    syscall                                   # newline after all 8 boxes
    jr   $ra                                  # return

.globl showCorrectMsg
showCorrectMsg:
    li   $v0, SysPrintString                  # print_string
    la   $a0, msg_correct                     # a0 = "Correct!"
    syscall                                   # print message
    jr   $ra                                  # return

.globl showIncorrectMsg
showIncorrectMsg:
    li   $v0, SysPrintString                  # print_string
    la   $a0, msg_incorrect                   # a0 = "Incorrect."
    syscall                                   # print message
    jr   $ra                                  # return

.globl showInvalidMsg
showInvalidMsg:
    li   $v0, SysPrintString                  # print_string
    la   $a0, msg_invalid                     # a0 = "Invalid input."
    syscall                                   # print message
    jr   $ra                                  # return
