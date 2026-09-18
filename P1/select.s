# You can change these values to test your solution.
.data
ARRAY: .word -6 -1 6 1
SIZE:  .word 4
INDEX: .word 2

.text
main:
  la a1, ARRAY      # a1 = pointer to array
  lw a2, SIZE       # a2 = array length
  lw a3, INDEX      # a3 = element index
  jal ra, select    # call select function
exit:
  li a7, 93         # exit syscall code
  ecall             # terminate the program

# ==========================================================================
# FUNCTION: select
#   This function selects an element from an integer array.
# Arguments:
#   a1 = pointer to int array
#   a2 = array length
#   a3 = element index
# Returns:
#   a0 = status code
#   a1 = value of the selected element
# ===========================================================================
select:
    blez a2, codigo50    #if len < 1,  exit with code 50
    bge a3, a2, codigo100    #if INDEX bigger than SIZE, code 100
    li a0, 0    #else, INDEX is in reach
    li x20, 4    #length of a word
    mul x19, a3, x20    #mul INDEX by word len to get pos
    add a1, a1, x19    #add pos to pointer to get index pos
    lw a1, 0(a1)    #load pointer content to a1
    j select_end    #jump to end

codigo50:
    li a0, 50    #code 50 attribution
    j select_end    #jump to end
    
codigo100:
    li a0, 100    #code 100 attribution
    j select_end    #jump to end

select_end:
     jr ra               # return to the caller
