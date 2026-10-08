#	Binary Game
#
#	Author: Oliver Perez
#
.include "SysCalls.asm"

.text
.globl randomNum
randomNum:
    # generate a random number within a range
    li $v0, SysRandIntRange     # Syscall code for Random Int Range
    li $a1, 256                 # Upper bound is 256 (0-255)
    syscall                     # Number is in $a0

    move $v0, $a0       # move random number to return register
    jr $ra              # Return back to where called

 #Will generate 0 or 1 when option 3 is chosen will give a random gamemode question everytime   
.globl randomMode
randomMode:
    li $v0, SysRandIntRange     #Sycall code for raandom int range
    li $a1, 2                   #Upper bound is 2 (0-1)
    syscall

    move $v0, $a0               #moves number to return register
    jr $ra                      #Return to where called