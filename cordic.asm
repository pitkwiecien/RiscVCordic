.data
atan_table: .word 0x20000000,                  # hex(floor(arctan(Power[2,-i]) * Divide[Power[2,31],pi]))
                  0x12e4051d,
                  0x9fb385b,
                  0x51111d4,
                  0x28b0d43,
                  0x145d7e1,
                  0xa2f61e,
                  0x517c55,
                  0x28be53,
                  0x145f2e,
                  0xa2f98,
                  0x517cc,
                  0x28be6,
                  0x145f3,
                  0xa2f9,
                  0x517c,
                  0x28be,
                  0x145f,
                  0xa2f,
                  0x517,
                  0x28b,
                  0x145,
                  0xa2,
                  0x51,
                  0x28,
                  0x14,
                  0xa,
                  0x5,
                  0x2,
                  0x1
iterations: .byte 30
k: .word 0x4dba76d7             # hex(floor(Product[1/Sqrt[1+2^-2i],{i,0,?}] * 2^31))
input_msg: .asciz "Enter the value of angle in degrees multiplied by 2^32/180 to calculate its sine and cosine using CORDIC: "
sin_msg: .asciz "sin: "
cos_msg: .asciz ", cos: "

.text
.globl main
main:
   li a7, 4
   la a0, input_msg
   ecall
   li a7, 5                    # Input in: round(Divide[Power[2,32],180]*<angle_in_degrees>)
   ecall
   srai a0, a0, 1

   call cordic
   mv t0, a0
   mv t1, a1

   li a7, 4                    # Output in: Divide[<result>,Power[2,31]]
   la a0, sin_msg
   ecall
   li a7, 1
   mv a0, t1
   ecall
   li a7, 4
   la a0, cos_msg
   ecall
   li a7, 1
   mv a0, t0
   ecall
   li a7, 10
   ecall

# CORDIC algorithm
cordic:           # a0 - input
   addi sp, sp, -16
   sw ra, 12(sp)
   sw s0, 8(sp)
   la s0, atan_table
   lw t0, k            # x = k
   li t1, 0            # y = 0
   mv t2, a0          # z = input angle
   li t3, 0
   lb t4, iterations

cordic_loop:
   sra t5, t0, t3
   sra t6, t1, t3
   bltz t2, cordic_lower

cordic_higher:
   sub t0, t0, t6
   add t1, t1, t5
   lw t5, (s0)
   sub t2, t2, t5
   addi s0, s0, 4
   addi t3, t3, 1
   blt t3, t4, cordic_loop
   b cordic_end

cordic_lower:
   add t0, t0, t6
   sub t1, t1, t5
   lw t5, (s0)
   add t2, t2, t5
   addi s0, s0, 4
   addi t3, t3, 1
   blt t3, t4, cordic_loop

cordic_end:
   mv a0, t0
   mv a1, t1
   lw s0, 8(sp)
   lw ra, 12(sp)
   addi sp, sp, 16
   ret
