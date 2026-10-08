#	Binary Game
#
#	Author: Oliver Perez
#
.include "SysCalls.asm"
.text
#Procedure returns 1 or 0(true or false) if binary is valid
#Binary string must only include 1's, 0's, and must be 8 char long no longer or shorter
.globl validateBin
validateBin:
    #Register $a0 holds binary number
    li $v0, 1           #initialize to true
    li $t2, 0           #initialize counter 

    loop:               #loop through char in string $a0
        lbu $t0, 0($a0)                 #load current char

        beqz $t0, ifEos                 #if char is nul end of string
        
        li $t1, 8
        beq $t1, $t2, ifInvalidBin         #If counter == 8 invalid input
        
        li $t3, '1'                     #Store val of '1'
        li $t4, '0'                     #store val of '0'
        beq $t0, $t3, ifValidContinue   #if char == '1' continue   
        beq $t0, $t4, ifValidContinue   #if char == '0' continue

        j ifInvalidBin                  #if char is not '0' or '1' invalid input

    ifEos:
        li $t1, 8                       #load 8 into $t1
        bne $t2, $t1, ifInvalidBin      #if counter is not 8 invalid
        jr $ra                          #return to where called
    ifInvalidBin:
        move $v0, $zero
        jr $ra                          #return to where called
    ifValidContinue:
        addiu $a0, $a0, 1               #next char in string
        addiu $t2, $t2, 1               #increment counter
        j loop                          #loop again

#Returns if decimal is valid meaning it is not < 0 and not > 255
.globl validateDec
validateDec:
    li $v0, 1                       #Assume decimal is valid
    blt $a0, $zero, ifInvalidDec    #if decimal < 0 jump invalid

    li $t0, 255                     #set 255 to $t0
    bgt $a0, $t0, ifInvalidDec      #if decimal > 255 jump invalid
    jr $ra                          #return to where called
    ifInvalidDec:
        move $v0, $zero         #set return to false
        jr $ra                  #return to where called

#Turns binary string into using a shifter
.globl binStrToDecimal
binStrToDecimal:
    li   $v0, 0         # accumulator = 0
    li   $t1, 8         # counter = 8

    b2d_loop:
        lbu  $t0, 0($a0)    # char = *a0
        sll  $v0, $v0, 1    # acc <<= 1
        addiu $a0, $a0, 1   # ++ptr

        li   $t2, '1'
        bne  $t0, $t2, b2d_next
        addiu $v0, $v0, 1   # if ch=='1' add 1

    b2d_next:
        addiu $t1, $t1, -1
        bgtz $t1, b2d_loop

        jr   $ra