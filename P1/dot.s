#You can change these values to test your solution.
.data
A:    .word 6, 1, 3, 9, 12, 4, 13, 153
B:    .word 6, 1, 3, 9, 12, 4, 13, 153
SIZE: .word 8

.text
main:
  la a1, A          # a1 = pointer to array A
  la a2, B          # a2 = pointer to array B
  lw a3, SIZE       # a3 = number of elements in each array
  jal ra, dot       # call dot function
exit:
  li a7, 93         # exit syscall code
  ecall             # terminate the program


#==========================================================================
#FUNCTION: dot
#This function computes the dot product of two integer arrays.
#Arguments:
#a1 = pointer to first array
#a2 = pointer to second array
#a3 = array length
#Returns:
#a0 = status code
#a1 = dot product result
#===========================================================================
dot:
    li x29, 0    #inic sum at 0
    li x28, 0    #inic acc at 0
    blez a3, codigo50    #if SIZE < 1, code 50
    li a0, 0    #else, lets go
    j loop    #jump to loop

loop:
    bge x28, a3, loop_end    #if end, loop_end
    lw x5, 0(a1)    #load index values
    lw x6, 0(a2)    #load index values
    mul x7, x5, x6    #multiply
    j mult_overflow    #check if overflow
  
mult_overflow:
    beqz x5, continue    #if one of values is 0, mul is zero
    beqz x6, continue    #therefore, sum is zero, continue
    div x30, x7, x6    #divide mult by one of the values
    bne x30, x5, codigo200    #if diff than other value, overflow
    j soma    #else, add to acc
    
soma:
    mv x30, x29    #move to new register for testing
    mv x31, x7
    srli x30, x30, 31    #shift 31 bits to the left (only msb left)
    srli x31, x31, 31
    add x29, x29, x7    #add first, then test
    beq x30, x31, sum_overflow    #only if msb equal (meaning num pos ir neg)
    j continue

sum_overflow:
    mv x5, x29    #move to new reg for testing       
    srli x5, x5, 31    #shift 31 bits (only msb)
    bne x30, x5, codigo200    #if mbs of sum diff than msb of elem, overflow
    j continue
    
continue:    #iterate values
    addi a1, a1, 4
    addi a2, a2, 4
    addi x28, x28, 1
    j loop    #back to loop
    
loop_end:
    mv a1, x29    #attribute variable
    j codigo0    #attribute sucess

codigo0:    #a0 = 0
    li a0, 0
    j dot_end

codigo50:    #a0 = 50
    li a0, 50
    j dot_end

codigo200:    #a0 = 200
    li a0, 200
    j dot_end

dot_end:    #end of function
  jr ra               # return to the caller
