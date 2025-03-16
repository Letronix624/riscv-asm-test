.section .data

.align 16

buffer: .space 128

greeting: .asciz "Good morning, howsa goin?\nWhat is 9 + 10?\n"

wrong_answer: .asciz "Wrong. The answer is not \"\".\n"

lose_text: .asciz "That's incorrect, noob.\n"

fail: .asciz "Failed to read stdio.\n"

win_text: .asciz "That's right!\n"

correct_answer:
        .asciz 21\n"
        .space 1 # one extra byte to make 4 bytes, one double word.

newline: .asciz "\n"

.section .text
.global _start

_start:
        # Write message
        
        li a7, 64 # write
        li a0, 1  # stdout
        la a1, greeting
        li a2, 42 # 42 characters
        ecall

read:
        la t1, buffer # buffer address
        li t2, 128 # buffer size

        sw x0, 0(t1) # clear first 4 bytes

        read_loop:
                li a7, 63 # read
                li a0, 0  # stdin
                mv a1, t1
                li a2, 128 # buffer size
                ecall

                bltz a0, abort # fail in case read failed
                beqz a0, check # print when end of file

                sub t2, t2, a0 # sub bytes read

                # Check newline #

                # calculate bytes written to the buffer - 1
                li t3, 127
                sub t3, t3, t2 # buffer index
                add t3, t3, t1 # buffer offset

                lb t3, 0(t3) # latest character byte
                la t4, newline # newline offset
                lb t4, 0(t4) # newline byte

                beq t3, t4, check # if latest character = newline, branch

                li t3, 1
                blt t2, t3, check # branch when buffer full
                j read_loop

check:
        la t1, correct_answer
        lw t1, 0(t1) # correct answer double word

        la t3, buffer
        lw t3, 0(t3) # users answer

        beq t1, t3, win # If both are equal, WIN!

        # allocate aligned data to the stack
        li t1, 128
        sub t2, t1, t2 # get user written buffer size
        add a2, t2, 29 # already store size of all character bytes in a2
        li t4, 16
        add t1, a2, t4 # add wrong answer size + 16
        # calculate smallest allocation size
        div t1, t1, t4
        mul t4, t1, t4

        sub sp, sp, t4 # allocate

        li t3, 25 # bytes to copy

        mv t4, sp # stack pointer
        la t5, wrong_answer # text pointer
        loop1: 
                addi t3, t3, -1 # sub 1
                
                lb t1, 0(t5) # load from text
                sb t1, 0(t4) # store to stack

                addi t4, t4, 1 # procede byte at a time
                addi t5, t5, 1
                bgez t3, loop1 # loop until -1

        la t6, buffer # buffer text pointer
        addi t2, t2, -2 # remove last newline
        loop2:
                addi t2, t2, -1 # t2 is user buffer size

                lb t1, 0(t6)
                sb t1, 0(t4)

                addi t4, t4, 1 # procede byte at a time
                addi t6, t6, 1
                bgez t2, loop2
        lb t1, 0(t5) # load last 3 bytes
        sb t1, 0(t4) # store to stack
        lb t1, 1(t5) # load last 3 bytes
        sb t1, 1(t4) # store to stack
        lb t1, 2(t5) # load last 3 bytes
        sb t1, 2(t4) # store to stack

        li a7, 64 # write
        li a0, 1  # stdout
        mv a1, sp
        # a2 already defined
        ecall

        j lose # else lose

exit:
        li a7, 93 # exit
        li a0, 0  # success
        ecall
win:

        li a7, 64 # write
        li a0, 1  # stdout
        la a1, win_text
        li a2, 14
        ecall

        j exit
lose:
        li a7, 64 # write
        li a0, 1  # stdout
        la a1, lose_text
        li a2, 24
        ecall

        j exit
abort:
        li a7, 64 # write
        li a0, 1  # stdout
        la a1, fail
        li a2, 22
        ecall

        la t1, buffer # buffer address
        li t2, 128 # buffer size

        li a7, 93 # exit
        li a0, 1  # fail
        ecall
        
