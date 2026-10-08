#	Binary Game
#
#	Author: Oliver Perez
#
.include "SysCalls.asm"
.data
    #String for menu options
    menuTitle: .asciiz   "==================  BINARY GAME MENU  ==================\n"
    menuOption1: .asciiz "1. Binary to Decimal\n"
    menuOption2: .asciiz "2. Decimal to Binary\n"
    menuOption3: .asciiz "3. Both Bin2Dec and Dec2Bin\n"
    menuPrompt: .asciiz  "Enter your choice(1, 2, or 3): "

.text
#procedure asks what gamemode the user chooses to play
.globl menu
menu:
    #Display each option
    li $v0, SysPrintString  #syscall for print string
    la $a0, menuTitle       #load adress of string into $a0
    syscall                 #calls syscall
                            #Repeat for rest of options
    li $v0, SysPrintString
    la $a0, menuOption1
    syscall

    li $v0, SysPrintString
    la $a0, menuOption2
    syscall

    li $v0, SysPrintString
    la $a0, menuOption3
    syscall

    #ask for user answer and store
    li $v0, SysPrintString  #syscall for print string
    la $a0, menuPrompt      #load adress of prompt intp $a0
    syscall                 #syscall

    li $v0, SysReadInt      #syscall to read integer
    syscall                 #calls syscall

    jr $ra                  #return with user input in $v0