# You can change these values to test your solution.
.data
ARRAY: .word -6 -1 6 1
SIZE:  .word 4

.text
main:
  la a1, ARRAY        # a1 = pointer to array
  lw a2, SIZE         # a2 = number of elements in the array
  jal ra, argmax      # call argmax function
exit:
  li a7, 93           # exit syscall code
  ecall               # terminate the program

# ==========================================================================
# FUNCTION: argmax
#   Takes an array of integers and returns the index of the largest element.
#   If there are multiple elements with the same maximum value, 
#   it should return the smallest index among them.
# Arguments:
#   a1 = pointer to int array
#   a2 = array length
# Returns:
#   a0 = status code
#   a1 = index of the largest element
# ===========================================================================
argmax:
    blez a2, codigo50    #if len < 1, code 50
    li a0, 0    #else, there's at least one num in array
    lw x18, 0(a1)    #start at first
    li x20, 0    #start at value 0
    li x21, 0    #start at value 0
    j loop    #jump to loop
    
loop:
    beq x20, a2, loop_end    #if end of array, jump to end of loop
    lw x19, 0(a1)    #read value in array pointer
    ble x19, x18, True    #if not bigger iterate
    mv x18, x19    #else digit is bigger
    mv x21, x20    #move pointer too
    j True #jump to Iterate

True:    #iterates values
    addi a1, a1, 4
    addi x20, x20, 1
    j loop
   
codigo50:    #code 50 error
    li a0, 50
    j argmax_end
    
loop_end:    #moves values and ends
    mv a1, x21
    j argmax_end

argmax_end:
    jr ra               # return to the caller