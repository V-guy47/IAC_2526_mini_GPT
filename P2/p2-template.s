###########################################################################
# Upper bound constants for static memory reservation
###########################################################################
.equ CONST_DIMENSION 4
.equ CONST_BUFFER_SIZE 1024
.equ CONST_MAX_VOCAB_TOKENS 100
.equ CONST_MAX_INPUT_TOKENS 10

###########################################################################
# System call constants
###########################################################################
.equ CONST_SYSCALL_PRINT_INT 1
.equ CONST_SYSCALL_PRINT_STRING 4
.equ CONST_SYSCALL_PRINT_CHAR 11
.equ CONST_SYSCALL_EXIT 10
.equ CONST_SYSCALL_EXIT2 93
.equ CONST_SYSCALL_OPEN 1024
.equ CONST_SYSCALL_CLOSE 57
.equ CONST_SYSCALL_READ 63
.equ CONST_SYSCALL_WRITE 64

###########################################################################
# ASCII character constants
###########################################################################
.equ CONST_CHAR_EOF 0
.equ CONST_CHAR_SPACE 32
.equ CONST_CHAR_NEWLINE 10
.equ CONST_CHAR_HYPHEN 45
.equ CONST_CHAR_ZERO 48

.data
###########################################################################
# Data section with static memory reservations.
# Feel free to add more if needed.
###########################################################################
VOCABULARY_FILENAME:     .string "vocab.txt"
EMBEDDINGS_FILENAME:     .string "embeddings.txt"
INPUT_FILENAME:          .string "input.txt"

W_Q_FILENAME:            .string "W_Q.txt"
W_K_FILENAME:            .string "W_K.txt"
W_V_FILENAME:            .string "W_V.txt"

VOCAB_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the vocabulary file
INPUT_BUFFER:            .zero CONST_BUFFER_SIZE                              # Contents of the input file
MATRIX_BUFFER:           .zero CONST_BUFFER_SIZE                              # Contents of a matrix file (used for W_Q, W_K, W_V, and embeddings)

INPUT_INDICES_VECTOR:    .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of input token indices (#inputs x 4 bytes)
SCORES_VECTOR:           .zero (CONST_MAX_INPUT_TOKENS * 4)                   # Vector of scores (#tokens x 4 bytes)

INPUT_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the input
VOCAB_TOTAL_TOKENS:      .word 0                                              # Number of tokens in the vocabulary

VOCAB_EMBEDDINGS_MATRIX: .zero (CONST_MAX_VOCAB_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
INPUT_EMBEDDINGS_MATRIX: .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Embedding matrix (#tokens x dimension x 4 bytes)
W_Q_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_Q matrix (dimension x dimension x 4 bytes)
W_K_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_K matrix (dimension x dimension x 4 bytes)
W_V_MATRIX:              .zero (CONST_DIMENSION * CONST_DIMENSION * 4)        # W_V matrix (dimension x dimension x 4 bytes)
Q_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # Q matrix (#tokens x dimension x 4 bytes)
K_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # K matrix (#tokens x dimension x 4 bytes)
V_MATRIX:                .zero (CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4) # V matrix (#tokens x dimension x 4 bytes)

.text
main:
    ###########################################################################
    # Read vocabulary
    ###########################################################################
    la a0, VOCABULARY_FILENAME
    la a1, VOCAB_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file
    mv s11, a1  # s11 is pointer to vocab.txt


    ###########################################################################
    # Read input
    ###########################################################################
    la a0, INPUT_FILENAME
    la a1, INPUT_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file
    mv s10, a1  # s10 is pointer to input.txt

    ###########################################################################
    # Read W_Q matrix
    ###########################################################################
    la a0, W_Q_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file
    mv s9, a1  # s11 is pointer to W_Q.txt

    ###########################################################################
    # Parse W_Q matrix
    ###########################################################################
    la a0, W_Q_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer #turns matrix into 1D vector (repeat as needed)
    la s8, W_Q_MATRIX   #s8 is pointer to #BEGINNING# W_Q_MATRIX (bcs we were putting a0 and it was getting only word "the")

    ###########################################################################
    # Read W_K matrix
    ###########################################################################
    la a0, W_K_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file   #read parse read parse read parse read parse im going insane
    mv s9, a1   #s9 is pointer to W_K.txt

    ###########################################################################
    # Parse W_K matrix from buffer
    ###########################################################################
    la a0, W_K_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer
    la s7, W_K_MATRIX   #s7 is pointer to #BEGINNING# W_K_MATRIX

    ###########################################################################
    # Read W_V matrix
    ###########################################################################
    la a0, W_V_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file
    mv s9, a1    #s9 is pointer to W_V.txt

    ###########################################################################
    # Parse W_V matrix from buffer
    ###########################################################################
    la a0, W_V_MATRIX
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer
    la s6, W_V_MATRIX    #s6 is pointer to #BEGINNING# W_V_MATRIX

    ###########################################################################
    # Read embeddings matrix
    ###########################################################################  
    la a0, EMBEDDINGS_FILENAME
    la a1, MATRIX_BUFFER
    li a2, CONST_BUFFER_SIZE
    jal ra, read_file
    mv s9, a1   #s9 is for storing pointers of txt

    ###########################################################################
    # Parse vocabulary embeddings matrix from buffer
    ###########################################################################
    la a0, VOCAB_EMBEDDINGS_MATRIX  
    la a1, MATRIX_BUFFER
    jal ra, parse_matrix_buffer
    la s5, VOCAB_EMBEDDINGS_MATRIX    #s5 is pointer to #BEGINNING# VOCAB EMBEDDINGS MATRIX
    mv s2, a1

    ###########################################################################
    # Convert input tokens to indices
    ###########################################################################
    la a0, INPUT_INDICES_VECTOR
    mv a2, s10
    mv a3, s11
    jal ra, tokens_to_indices
    mv s10, a0  #pointer to input
    mv s4, a1   #s4 IS NOW the number of tokens
    
    ###########################################################################
    # Build input embeddings matrix
    ###########################################################################
    la a0, INPUT_EMBEDDINGS_MATRIX  #preparing callers for new function (basically what we do at main)
    mv a1, s5
    la a2, INPUT_INDICES_VECTOR
    mv a3, s4
    jal ra, build_input_embeddings_matrix
    la s3, INPUT_EMBEDDINGS_MATRIX   #s3 is NOW the #BEGINNING# input emb matrix

    ###########################################################################
    # Build matrix Q
    ###########################################################################
    la a0, Q_MATRIX
    mv a1, s3
    mv a2, s4
    li a3, CONST_DIMENSION
    mv a4, s8
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION
    jal ra, matrix_multiply
    mv s8, a0   #s8 is NEW POINTER to Q matrix (finished matrix)

    ###########################################################################
    # Build matrix K
    ###########################################################################
    la a0, K_MATRIX
    mv a1, s3
    mv a2, s4
    li a3, CONST_DIMENSION
    mv a4, s7
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION
    jal ra, matrix_multiply
    mv s7, a0   #s7 is NEW pointer to K matrix

    ###########################################################################
    # Build matrix V
    ###########################################################################
    la a0, V_MATRIX
    mv a1, s3
    mv a2, s4
    li a3, CONST_DIMENSION
    mv a4, s6
    li a5, CONST_DIMENSION
    li a6, CONST_DIMENSION
    jal ra, matrix_multiply
    mv s6, a0   #s6 is NEW pointer to V matrix

    ###########################################################################
    # Compute scores for the last input token
    ###########################################################################
    la a0, SCORES_VECTOR
    mv a1, s8
    mv a2, s7
    mv a3, s4
    li a4, CONST_DIMENSION
    li a5, 0
    addi a5, s4, -1
    jal ra, compute_scores
    mv s9, a0
    
    ###########################################################################
    # Get the highest score index using argmax
    ###########################################################################
    mv a1, s9   #this is basically just a main for loading variables
    mv a2, s4   #kinda like a crafting table
    jal ra, argmax
    mv s9, a1

    ###########################################################################
    # Select chosen vector in V using the index from argmax
    ###########################################################################
    mv a1, s6
    mv a2, s4
    li a3, CONST_DIMENSION
    mv a4, s9   #i love minecraft
    jal ra, select_vector_in_matrix
    mv s6, a0
    
    ###########################################################################
    # Pick the next token in the vocabulary with the highest score
    ###########################################################################
    mv a0, s6
    mv a1, s5
    mv a2, s2
    jal ra, decide_next_token
    ###########################################################################
    # Print the next token 
    ###########################################################################
    mv a1, s11
    jal ra, print_predicted_token
    
    ###########################################################################
    # Terminate program successfully
    ###########################################################################
    li a0, 0
    j exit_with_code                                # Exit with code 0

# Read from a text file into a buffer.
# (in)  a0: filename address (char*)
# (in)  a1: destination buffer
# (in)  a2: maximum number of bytes to read
read_file:
    mv t1, a1   #put values in temp registers
    mv t2, a2   #for retrieval later on
    li a1, 0    #flag for opening 
    li a7, CONST_SYSCALL_OPEN   #code for opening files
    ecall   #THE GATES ARE OPENED
    mv t0, a0   #move FD to temp. reg.
    mv a1, t1   #retrieve original buffer
    mv a2, t2   #put max num of bytes TO READ
    li a7, CONST_SYSCALL_READ   #code to read files
    ecall   #THE SCRIPTS ARE RED
    mv t3, a0   #move numb. of read bytes to temp reg
    mv a0, t0   #move FD back to caller
    li a7, CONST_SYSCALL_CLOSE  #code for closing files
    ecall   #THE PROPHECY HAS BEEN FULLFILED
    mv a0, t3   #numb of read bytes to a0 
    mv a1, t1   #pointer to beggining of file
    ret

# Assumes the matrix is stored in the buffer as space-separated integers.
# Assumes columns are separated by 1 space (' '), and rows by 1 newline ('\n').
# Assumes only signed integers are provided.
# (out) a0: address of the matrix to fill (int*)
# (out) a1: number of rows in the matrix (int)
# (in)  a1: address of the buffer containing the matrix data (char*)
parse_matrix_buffer:
    addi sp, sp, -20    #respecting conventions
    sw ra, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)
    li t1, 0    #begin variables at 0
    li t5, 0
    li t6, 1    #this ones the special kid (flag for pos or neg numb)
    li s1, CONST_CHAR_EOF   #list of special flags
    li s2, CONST_CHAR_NEWLINE
    li s3, CONST_CHAR_SPACE
    li s4, CONST_CHAR_HYPHEN
     
matrix_parsing_loop:
    lb t0, 0(a1)    #t0 is byte im reading
    addi a1, a1, 1    #move pointer immediately
    beq t0, s1, parsing_EOF    #flags: EOF, NEWLINE, SPACE && NEGNUM
    beq t0, s2, newline
    beq t0, s3, space
    beq t0, s4, neg_num
    addi t0, t0, -CONST_CHAR_ZERO    #ASCII -> INT
    li t2, 10    #t2 is 10 (for sum)
    mul t1, t1, t2    #make sum (to get whole number)
    add t1, t1, t0    #t1 is sum
    j matrix_parsing_loop
 
neg_num:
    li t6, -1    #flag for neg num
    j matrix_parsing_loop
    
newline:
    mul t1, t1, t6    #make/save last num
    sw t1, 0(a0)
    li t1, 0
    li t6, 1
    addi a0, a0, 4    
    addi t5, t5, 1    #if newline, one more row
    j matrix_parsing_loop
    
space:
    mul t1, t1, t6    #save num
    sw t1, 0(a0)
    li t1, 0    #reset sum and flag
    li t6, 1    
    addi a0, a0, 4    #move pointer
    j matrix_parsing_loop
    
parsing_EOF:    
    mv a1, t5    #move to a1 numb of rows
    lw ra, 16(sp)   #reset original save regisdter values
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 20    #<-- very important 
    ret

# Converts the input tokens into their corresponding indices in the vocabulary.
# (in)  a0: address of input indices vector to fill (int*)
# (in)  a2: address to input buffer
# (in)  a3: address to vocabulary buffer
# (out) a1: size of input indices vector (number of tokens in input)
tokens_to_indices:
    addi sp, sp, -12    #again, super respectful of conventions
    sw ra, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    mv t1, a2 #store inicial input buffer address value
    mv t6, a3 #store inicial vocab buffer address value
    li t4, 0    #ammount of words from input index vector into new vector
    li t5, 0    #start index at 0
    li s1, CONST_CHAR_EOF
    li s2, CONST_CHAR_NEWLINE
word_compare:
    lb t2, 0(a2)
    lb t3, 0(a3)
    beq t2, s1, tokens_EOF #test if input buffer ended
    beq t3, s1, vocab_EOF #test if vocab buffer ended
    beq t2, s2, newline1 #test if input char is \n
    beq t3, s2, newline2 #test if vocab char is \n
    beq t2, t3, continue #if input char and vocab char are equal it moves one byte
    bne t2, t3, next_word #if chars are not equal it changes to next word in vocab
next_word: 
    mv a2, t1  #reset input buffer address to the beginning
    addi a3, a3, 1 #move one byte on vocab word
    lb t3, 0(a3) #load vocab char
    beq t3, s2, newline2 #test if vocab char is \n 
    j next_word #stay in loop while vocab char is != \n
newline1:
    beq t3, s2, valid_input #if vocab char is \n it is a valid input
    j next_word 
newline2:
    mv a2, t1 #reset input buffer address to the beginning
    addi t5, t5, 1 #adds 1 to index counter
    addi a3, a3, 1 #move one byte on vocab word
    j word_compare
valid_input:
    mv a3, t6 #reset vocab buffer address to the beginning
    sw t5, 0(a0) #store the input word index on the new vector
    addi a0, a0, 4 #moves to next word on the vector
    addi t4, t4, 1 #adds 1 to the size of the input indices vector
    li t5, 0 #reset the index value to 0
    addi a2, a2, 1 #moves to the next word on the input buffer
    mv t1, a2 #puts the beginning of the input buffer address on the word we are comparing
    j word_compare
continue:
    addi a2, a2, 1 #same as before
    addi a3, a3, 1 #still the same
    j word_compare
vocab_EOF:
    lb t2, 0(a2) #loads input char
    beq t2, s1, tokens_EOF #test if input char is EOF 
    beq t2, s2, skip_word_done #test if input char is \n
    addi a2, a2, 1 #you know it
    j vocab_EOF #stays in cycle while input char is a letter
skip_word_done:
    addi a2, a2, 1 
    mv t1, a2 #input buffer address beginning on the next word we need to compare
    mv a3, t6 #reset the vocab buffer address
    li t5, 0 #another reset
    j word_compare
tokens_EOF:
    mv a1, t4 #puts the size of the input indices vector on a1
    lw ra, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 12 #good convetion as always
    ret
    
# (out) a0: address of the output matrix to fill (int*)
# (in)  a1: address of the vocabulary embeddings matrix (int*)
# (in)  a2: address of the input indices array (int*)
# (in)  a3: number of tokens in the input (int)
build_input_embeddings_matrix:
    beq a3, x0, embeddings_end  #if nothing to read, nothing to show
    lw t1, 0(a2)    #load to temp reg first index
    li t0, CONST_DIMENSION  #this case 4
    mul t4, t1, t0  #multiply it by 4 to get travel distance (THIS IS BYTES)
    slli t4, t4, 2  #multiply by 4 to get BITS
    add t3, a1, t4  #shift pointer to beginning of embedding
    mv t5, t0   #moving t0 to t5 so i can work without damaging memory (kinda useless since i go back to the beg. of build_...)

main_embeddings_loop:
    beq t5, x0, token_iterate   #if we're at the end of embedding, iterate index
    lw t6, 0(t3)    #load whats pointer pointing to
    sw t6, 0(a0)    #save it in final vector
    addi t3, t3, 4  #make iterations immediately (just to be sure we're actually doing it)
    addi a0, a0, 4  
    addi t5, t5, -1
    j main_embeddings_loop  

token_iterate:
    addi a2, a2, 4  #one byte foward
    addi a3, a3, -1 #one less token to read
    j build_input_embeddings_matrix #its not over yet

embeddings_end:
    ret #now its over
    
# (out) a0: address of the output matrix (int*)
# (in)  a1: address of the first matrix (int*)
# (in)  a2: #rows of the first matrix (int)
# (in)  a3: #columns of the first matrix (int)
# (in)  a4: address of the second matrix (int*)
# (in)  a5: #rows of the second matrix (int)
# (in)  a6: #columns of the second matrix (int)
matrix_multiply:
    li t0, 0    #starting row for mtx A
loop_rows_A:
    bge t0, a2, end     #if index at end, all lines are done, LEAVE
    li t1, 0    #else, starting col for mtx B
loop_cols_B:
    bge t1, a6, end_row_A     #if end of columm, row is finished
    li t2, 0    #
    li t3, 0    #accum for sum

inner_loop_k:
    bge t2, a3, store_result   #if t2 equal columms of matrix, keep result, sum is made
    mul t4, t0, a3  #how much to jump to get to line
    add t4, t4, t2  #adding offset
    slli t4, t4, 2  #multiply by 4 to get actual offset
    add t4, a1, t4  #adding actual offset
    lw t4, 0(t4)    #load whats in it

    mul t5, t2, a6  #how much to jump to get to columm
    add t5, t5, t1  #adding offset
    slli t5, t5, 2  #same thing as above
    add t5, a4, t5  #bla bla bla
    lw t5, 0(t5)    #you guessed we load

    mul t6, t4, t5  #now fun part: we multiply both
    add t3,t3,t6    #adding to total sum
    addi t2, t2, 1  #jump pointer
    j inner_loop_k

store_result:
    mul t4, t0, a6  #t4 = t0 * cols of B
    add t4, t4, t1  #gets position of element in final matrix
    slli t4, t4, 2  #multiply by 4 bytes
    add t4, a0, t4  #jump pointer to that position
    sw t3, 0(t4)    #saves value to that pointer position
    addi t1, t1, 1  #jump pointers
    j loop_cols_B

end_row_A:
    addi t0, t0, 1  #jump pointers
    j loop_rows_A
end: 
    ret

# (out) a0: address of the output scores vector (int*)
# (in)  a1: address of Q matrix (int*)
# (in)  a2: address of K matrix (int*)
# (in)  a3: #rows of Q and K (int)
# (in)  a4: #columns of Q and K (int)
# (in)  a5: target token index for which we want to compute the score (int)
compute_scores:
    addi sp, sp, -32    #calling conventions right
    sw ra, 28(sp)   #allocate 8 spaces for s0-s6 + ra
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)
    
    mv s0, a0   #just making sure everythings alright before proceeding
    mv s2, a2   #didnt use temp registers cuz dot already uses them
    mv s3, a4
    mv s4, a3
    
    mul t0, a5, a4  #how many numbers to skip
    slli t0, t0, 2  #multiply by 4
    add s1, a1, t0  #jump pointer
    li s5, 0    #preparing for cycle

    mv s6, a0   #keeps beginning of pointer 

loop_results:
    bge s5, s4, end_score   #if s5 equal token numb, LEAVE
    mv a1, s1   #pointer to Q vector
    mv a2, s2   #pointer to K vector 
    mv a3, s3   #a3 = number of columns 
    
    jal dot #jump to dot function
    sw a1, 0(s0)    #save return value
    
    addi s0, s0, 4  
    slli t0,  s3, 2 
    add s2, s2, t0  #move pointer
    addi s5, s5, 1 
    j loop_results

end_score: 
    mv a0, s6   #save value before return values
    lw ra, 28(sp)   #calling conventions are boring
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 32
    ret # Return to the caller


# (out) a0: address of the selected vector (int*)
# (in)  a1: address of matrix (int*)
# (in)  a2: #rows (int)
# (in)  a3: #cols (int)
# (in)  a4: target row
select_vector_in_matrix:
    bgt a4, a2, select_vector_end #test if target row is bigger than num of rows
    li t0, 4 #bytes in a word
    mul t0, t0, a3 #calculate the number of a full row
    mul t0, t0, a4 #calculate the number of bytes we have to jump
    add a0, a1, t0 #sums the jump to the original matrix and put it in a0
    ret

#doesnt make sense adding rows to the function if not for testing target row > numb. of rows   
select_vector_end:
    li a0, 0    #raise a0 = 0        
    ret

# (out) a0: index of the predicted token in the vocabulary (int)
# (in)  a0: address of target vector (int*)
# (in)  a1: vocabulary embeddings address (int*)
# (in)  a2: number of tokens in vocabulary (int)
decide_next_token:
    addi sp, sp, -32    #since dot uses t0 - t6, 
    sw ra, 28(sp)       #keep old values in stack
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)

    mv s0, a0   #target vector
    mv s1, a1   #pointer to vocab embeddings
    mv s2, a2   #s2 numb of tokens

    li s3, 0
    lui s3, 0x80000    #s3 is the biggest inner product

    li s4, 0    #indice do vocab embedding
    li s5, 0    #s5 is index of biggest inner product
    li s6, CONST_DIMENSION  #s6 is 4 * 4  (collums * bytes)
    slli s6, s6, 2
    
next_emb_loop:
    beq s4, s2, next_emb_end    #if no more tokens, LEAVE
    mv a1, s0   #prepare dot function
    mv a2, s1   #prepare dot function
    li a3, CONST_DIMENSION  #yep still there
    jal ra, dot     #okay now its called
    bne a0, x0, next_emb_iterate    #if dot function doesnt give code 0
    bgt a1, s3, change_index    #if passes through (so word accepted) and greater than inner product memorized, change
    j next_emb_iterate
    
change_index:
    mv s3, a1   #just changing values
    mv s5, s4
    j next_emb_iterate

next_emb_iterate:
    addi s4, s4, 1  #adding one to total tokens
    add s1, s1, s6  #we did s6 for easier jumps here
    j next_emb_loop

next_emb_end:
    mv a0, s5   #save it before you lose it
    lw ra, 28(sp)   #returning original values to stack
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 32
    ret
#############################################################################################################
# Dot product and argmax helper functions.
#############################################################################################################

# (in)  a1: address of first vector (int*)
# (in)  a2: address of second vector (int*)
# (in)  a3: length of the vectors (int)
# (out) a0: status code (0 for success, non-zero for error)
# (out) a1: dot product result (int)
dot:
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the result and the loop index.
    mv t0, zero                                     # t0 will hold the result (dot product)
    mv t1, zero                                     # t1 will be our loop index
    # Let's see first if SIZE < 1, and jump to dot_end if that's the case.
    slti t2, a3, 1                                  # t2 = (SIZE < 1)
    beq t2, zero, dot_loop                          # If SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # Set a0 to 50 to indicate an error (invalid size)
    j dot_end                                       # If SIZE < 1, jump to dot_end
dot_loop:
    beq t1, a3, dot_end_loop                        # If t1 == SIZE, we are done
    lw t2, 0(a1)                                    # Load A[t1] into t2
    lw t3, 0(a2)                                    # Load B[t1] into t3
    mul t4, t2, t3                                  # t4 = A[t1] * B[t1]
    # Check if the multiplication of A[t1] and B[t1] overflows
    mulh t5, t2, t3                                 # t5 = high 32 bits of A[t1] * B[t1] (signed)
    srai t6, t4, 31                                 # t6 = sign extension of low 32 bits (0 or -1)
    bne t5, t6, overflow                            # Overflow if high bits != sign extension of low bits
    mv t6, t0                                       # Store the current result in t6 for overflow checking
    add t0, t0, t4                                  # t0 += A[t1] * B[t1]
    # Check if the previous addition caused an overflow
    # Careful: adding negative numbers will correctly result in a negative number, so we need to check for overflow in both directions.
    bgt t6, zero, check_positive_overflow           # If previous result was positive, check for positive overflow
    blt t6, zero, check_negative_overflow           # If previous result was negative, check for negative overflow
    j dot_continue_loop
check_positive_overflow:
    blt t4, zero, dot_continue_loop                 # If we added a negative number, we can't have a positive overflow
    blt t0, zero, overflow                          # If t0 < 0 after adding a positive number, we have an overflow
    j dot_continue_loop
check_negative_overflow:
    bgt t4, zero, dot_continue_loop                 # If we added a positive number, we can't have a negative overflow
    bgt t0, zero, overflow                          # If t0 > 0 after adding a negative number, we have an overflow
    j dot_continue_loop
dot_continue_loop:
    addi a1, a1, 4                                  # Move to the next element in A
    addi a2, a2, 4                                  # Move to the next element in B
    addi t1, t1, 1                                  # t1++
    j dot_loop                                      # Repeat the loop
dot_end_loop:
    li a0, 0                                        # Set a0 to 0 to indicate success
    mv a1, t0                                       # Move the result into a1 for return
    j dot_end                                       # Jump to the end of the function
overflow:
    li a0, 200                                      # Set a0 to 200 to indicate an overflow error
    j dot_end                                       # Jump to the end of the function
dot_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # Return to the caller

# (in)  a1: pointer to int array
# (in)  a2: array length
# (out) a0: status code
# (out) a1: index of the largest element
argmax:
    # Get the index of the maximum value in A, which is of size SIZE.
    # The result will be stored in a0.
    # If here's a draw, return the smallest index among the maximum values.
    addi sp, sp, -4
    sw ra, 0(sp)                                    # Save return address on the stack
    # Initialize the max value and the index of the max value.
    lw t0, 0(a1)                                    # t0 will hold the max value
    mv t1, zero                                     # t1 will hold the index of the max value
    mv t2, zero                                     # t2 will be our loop index
    # Error checking first: if SIZE < 1, we should return 50 to indicate an error.
    slti t3, a2, 1                                  # t3 = (SIZE < 1)
    beq t3, zero, argmax_loop                       # if SIZE >= 1, we can proceed to the loop
    li a0, 50                                       # set a0 to 50 to indicate an error (invalid size)
    j argmax_end                                    # if SIZE < 1, jump to argmax_end
argmax_loop:
    # The actual loop logic.
    beq t2, a2, argmax_end_loop                     # if t2 == SIZE, we are done
    lw t3, 0(a1)                                    # load A[t2] into t3
    ble t3, t0, argmax_next                         # if A[t2] <= max_value, skip to next
    mv t0, t3                                       # max_value = A[t2]
    mv t1, t2                                       # index_of_max = t2
argmax_next:
    addi a1, a1, 4                                  # move to the next element in A
    addi t2, t2, 1                                  # t2++
    j argmax_loop                                   # repeat the loop
argmax_end_loop:
    mv a1, t1                                       # move the index of the max value into a1 for return
    li a0, 0                                        # set a0 to 0 to indicate success
argmax_end:
    lw ra, 0(sp)                                    # Restore return address
    addi sp, sp, 4                                  # Deallocate stack space
    ret                                             # return to the caller

exit_with_code:
    li a7, CONST_SYSCALL_EXIT2
    ecall

#############################################################################################################
# Helper functions for printing and debugging.
#############################################################################################################

.data
PRINT_HEADER_VOCABULARY:    .string "=== Vocabulary ==="
PRINT_HEADER_INPUT:         .string "=== Input ==="
PRINT_HEADER_INPUT_INDICES: .string "=== Input Indices ==="
PRINT_HEADER_MATRIX:        .string "=== Matrix ==="
PRINT_HEADER_SCORES:        .string "=== Scores ==="
PRINT_HEADER_NEXT_TOKEN:    .string "=== Decision ==="
PRINT_VECTOR_LB:            .string "[ "
PRINT_VECTOR_RB:            .string "]"

.text
# Prints a null-terminated string followed by a newline.
# (in) a0: buffer to print (char*)
println:
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    ret

# Prints the vocabulary buffer.
# (in) a0: address of the vocabulary buffer (char*)
print_vocabulary:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_VOCABULARY
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input buffer as a string.
# (in) a0: address of the input buffer (char*)
print_input:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    mv s0, a0
    la a0, PRINT_HEADER_INPUT
    jal println
    mv a0, s0
    jal println
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Prints the input indices vector.
# (in) a0: address of the input indices vector (int*)
# (in) a1: size of the input indices vector (int)
print_indices:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0
    mv s1, a1
    la a0, PRINT_HEADER_INPUT_INDICES
    jal println
    mv a0, s0
    mv a1, s1
    jal print_vector
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

print_scores:
    addi sp, sp, -4
    sw ra, 0(sp)
    la a0, PRINT_HEADER_SCORES
    jal println
    la a0, SCORES_VECTOR
    lw a1, INPUT_TOTAL_TOKENS
    jal print_vector
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# a0: address of matrix to print (int*)
# a1: number of rows
# a2: number of columns
print_matrix:
    addi sp, sp, -24
    sw ra, 0(sp)                                    # return address
    sw s0, 4(sp)                                    # matrix pointer
    sw s1, 8(sp)                                    # row index
    sw s2, 12(sp)                                   # col index
    sw s3, 16(sp)                                   # number of rows
    sw s4, 20(sp)                                   # number of columns
    mv s0, a0                                       # s0 = pointer to matrix
    mv s3, a1                                       # s3 = number of rows
    mv s4, a2                                       # s4 = number of columns
    li s1, 0                                        # s1 = current row index
    la a0, PRINT_HEADER_MATRIX
    jal println
print_matrix_row_loop:
    beq s1, s3, print_matrix_done
    li s2, 0
print_matrix_col_loop:
    beq s2, s4, print_matrix_next_row
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    addi s0, s0, 4
    addi s2, s2, 1
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    j print_matrix_col_loop
print_matrix_next_row:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s1, s1, 1
    j print_matrix_row_loop
print_matrix_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    ret

# a0: address of vector to print (int*)
# a1: number of elements (int)
print_vector:
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)
    mv s0, a0                                       # s0 = pointer to vector
    mv s1, a1                                       # s1 = number of elements
    la a0, PRINT_VECTOR_LB                          # Print "[ "
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
print_vector_loop:
    beq s1, zero, print_vector_done
    lw a0, 0(s0)
    li a7, CONST_SYSCALL_PRINT_INT
    ecall
    li a0, CONST_CHAR_SPACE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s0, s0, 4
    addi s1, s1, -1
    j print_vector_loop
print_vector_done:
    la a0, PRINT_VECTOR_RB                          # Print "]"
    li a7, CONST_SYSCALL_PRINT_STRING
    ecall
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    ret

# (in) a0: index of the predicted token in the vocabulary (int)
# (in) a1: address of vocabulary buffer (char*)
print_predicted_token:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    mv s0, a0                                       # s0 = countdown to target index
    mv s1, a1                                       # s1 = current position in vocab buffer
    la a0, PRINT_HEADER_NEXT_TOKEN
    jal println
print_predicted_token_skip:
    beq s0, zero, print_predicted_token_read
    lb t0, 0(s1)               # lê caracter atual
    addi s1, s1, 1             # avança ponteiro
    li t1, CONST_CHAR_NEWLINE
    bne t0, t1, print_predicted_token_skip  # não é \n → continua
    addi s0, s0, -1            # encontrou \n → uma palavra saltada
    j print_predicted_token_skip
print_predicted_token_read:
    # s1 = start of target token, print it char by char until newline or null
print_predicted_token_char:
    lb t0, 0(s1)
    beq t0, zero, print_predicted_token_nl          # null terminator
    li t1, CONST_CHAR_NEWLINE
    beq t0, t1, print_predicted_token_nl            # newline terminator
    mv a0, t0
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    addi s1, s1, 1
    j print_predicted_token_char
print_predicted_token_nl:
    li a0, CONST_CHAR_NEWLINE
    li a7, CONST_SYSCALL_PRINT_CHAR
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret
