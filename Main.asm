#	Binary Game
#
#	Author: Oliver Perez
#
.include "SysCalls.asm"

.data
.globl score
score: .word 0
.globl level
level: .word 1
.globl current_line
current_line: .word 1
.globl lines_per_level
lines_per_level: .word 1
newline: .asciiz "\n"
press_enter: .asciiz "Press Enter to continue..."
final_score_msg: .asciiz "\nGame Over! Final Score: "
congrats_msg: .asciiz "\nCongratulations! You completed all 10 levels!\n"
    
.text
.globl main
main:
    jal menu                # v0 = user choice (1,2,3)
    move $s0, $v0           # s0 = choice (save it for game loop)
    
    # Initialize game state
    li $t0, 0
    sw $t0, score
    li $t0, 1
    sw $t0, level
    sw $t0, current_line
    sw $t0, lines_per_level

game_loop:
    # Check what mode we're in
    beq $s0, 1, do_b2d
    beq $s0, 2, do_d2b
    beq $s0, 3, do_both
    j exit_program          # shouldn't reach here

do_b2d:
    jal bin2DecRound        # v0 = 1(correct), 0(incorrect), -1(invalid)
    j check_result

do_d2b:
    jal dec2BinRound        # v0 = 1(correct), 0(incorrect), -1(invalid)
    j check_result

do_both:
    jal randomMode          # v0 = 0 or 1
    beqz $v0, both_b2d      # if 0 â†' Bin2Dec
    jal dec2BinRound        # else â†' Dec2Bin
    j check_result
both_b2d:
    jal bin2DecRound
    j check_result

check_result:
    move $t0, $v0           # t0 = result code
    
    # If invalid (-1), ask the SAME question again (don't generate new one)
    li $t9, -1
    beq $t0, $t9, game_loop
    
    # If incorrect (0), end game
    beqz $t0, game_over
    
    # If correct (1), continue
    # Increment score
    lw $t1, score
    addiu $t1, $t1, 1
    sw $t1, score
    
    # Increment current line
    lw $t2, current_line
    lw $t3, lines_per_level
    addiu $t2, $t2, 1
    sw $t2, current_line
    
    # Check if we completed the level
    bgt $t2, $t3, next_level
    
    # Continue with next line in same level
    jal wait_for_enter
    j game_loop

next_level:
    # Increment level
    lw $t4, level
    addiu $t4, $t4, 1
    sw $t4, level
    
    # Increment lines per level
    addiu $t3, $t3, 1
    sw $t3, lines_per_level
    
    # Reset current line to 1
    li $t2, 1
    sw $t2, current_line
    
    # Check if we completed all 10 levels
    li $t5, 10
    bgt $t4, $t5, win_game
    
    jal wait_for_enter
    j game_loop

win_game:
    li $v0, SysPrintString
    la $a0, congrats_msg
    syscall
    # Fall through to game_over to show final score

game_over:
    # Print final score
    li $v0, SysPrintString
    la $a0, final_score_msg
    syscall
    
    lw $a0, score
    li $v0, SysPrintInt
    syscall
    
    li $v0, SysPrintString
    la $a0, newline
    syscall
    j exit_program

wait_for_enter:
    # Save ra since we're calling syscalls
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $v0, SysPrintString
    la $a0, press_enter
    syscall
    
    li $v0, SysReadString
    la $a0, newline
    li $a1, 2
    syscall
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

exit_program:
    li $v0, SysExit
    syscall
