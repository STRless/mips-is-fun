.data
prompt: .asciiz "Enter command (0 for options): "
options: .asciiz "1:\tPop\n2:\tPush\n3:\tSize\n4:\tPeek\n"
error_msg: .asciiz "-----\tUnknown Input\t-----\n"
enter_num: .asciiz "Enter an integer: "
peek_msg: .asciiz "Peeked value: "
size_msg: .asciiz "Size: "
exlaim_nl: .asciiz "\n"

.text
main:
    move $s0, $0                            # $s0 = tail
    move $s1, $0                            # $s1 = size

    jal init_node                           # create a dummy node

    move $s0, $v0                           # $s0 points to dummy node

loop:
    li $v0, 4                               # print initial prompt
    la $a0, prompt
    syscall

    li $v0, 5                               # get input
    syscall

    seq $t0, $v0, 0
    bne $t0, $0, zero
    seq $t0, $v0, 1
    bne $t0, $0, one
    seq $t0, $v0, 2
    bne $t0, $0, two
    seq $t0, $v0, 3
    bne $t0, $0, three
    seq $t0, $v0, 4
    bne $t0, $0, four
    j error

zero:
    li $v0, 4                               # print options
    la $a0, options
    syscall

    j loop
one:
    move $a0, $s0
    move $a1, $s1

    jal pop

    beq $s0, $v0, loop

    move $s0, $v0
    addi $s1, $s1, -1

    j loop
two:
    li $v0, 4
    la $a0, enter_num
    syscall

    li $v0, 5
    syscall

    move $a0, $v0
    move $a1, $s0

    jal push

    move $s0, $v0
    addi $s1, $s1, 1
    j loop
three:
    move $a0, $s1

    jal size

    j loop
four:
    move $a0, $s0

    jal peek

    j loop
error:
    li $v0, 4                               # print error message
    la $a0, error_msg 
    syscall

    j loop

    li $v0, 10                              # program end
    syscall

########################################################
# Create dummy node                                    #
########################################################
init_node:
    li $v0, 9                               # allocate 12 byte struct (0:int, 4:next, 8:prev)
    li $a0, 12
    syscall

    sw $0, 0($v0)                           # node->int = 0
    sw $0, 4($v0)                           # node->next = NULL
    sw $0, 8($v0)                           # node->prev = NULL

    jr $ra

########################################################
# Push integer onto the stack                          #
########################################################
pop:
    move $v0, $a0
    ble $a1, $0, empty

    lw $t0, 8($a0)

    sw $0, 4($t0)

    move $v0, $t0

    jr $ra

empty:
    jr $ra


########################################################
# Push integer onto the stack                          #
########################################################
push:
    move $t0, $a0

    li $v0, 9
    li $a0, 12
    syscall

    sw $t0, 0($v0)                          # node->int = $a0
    sw $0, 4($v0)                           # node->next = NULL
    sw $a1, 8($v0)                          # node->prev = TAIL

    sw $v0, 4($a1)                          # tail->next = new_node

    jr $ra                                  # return new_node

########################################################
# Get size of the stack                                #
########################################################
size:
    move $t0, $a0

    li $v0, 4
    la $a0, size_msg
    syscall

    li $v0, 1
    move $a0, $t0
    syscall

    li $v0, 4
    la $a0, exlaim_nl
    syscall

    jr $ra

########################################################
# Peek integer on top of stack                         #
########################################################
peek:
    lw $t0, 0($a0)

    li $v0, 4
    la $a0, peek_msg
    syscall

    li $v0, 1
    move $a0, $t0
    syscall

    li $v0, 4
    la $a0, exlaim_nl
    syscall

    jr $ra