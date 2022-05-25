    .arch armv8-a

    .data
    .align  2
n:
    .4byte  3 // Count of lines
m:
    .4byte  5 // Count of columns
matrix:
    .4byte  1, 2, 3, 4, 5
    .4byte  6, 7, 8, 9, 10
    .4byte  -1, -2, -3, -4, -5
maxs:
    .skip   12  // 4byte * n = 12byte

    .text
    .align  2
    .global _start
    .type   _start, %function
_start:
    adr x0, n
    ldr w0, [x0]    // w0 = n (Count of lines) CONST
    adr x1, m
    ldr w1, [x1]    // w1 = m (Count of columns) CONST
    adr x2, matrix  // x2 -> Address of matrix (first element) CONST
    adr x3, maxs    // x3 -> Address of maxs (first element) CONST
    bl  make_maxs
    bl  sort
    mov x0, #0  // Exit code 0
    mov x8, #93
    svc #0  // Exit
    .size   _start, .-_start
    // End of "_start"


    // Make array from max element of each line from matrix
    // Args:
    //  x0 - count of lines (for matrix)
    //  x1 - count of columns (for matrix)
    //  x2 - adress of matrix
    //  x3 - adress for maxs (Size should be equal 4byte * count of lines)
    // Notes:
    //  Func does not destroy the value in x0 - x3. Just modify x3.
    //  Value in x4 - x8 will be destroyed.
    .type   make_maxs, %function
make_maxs:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x4, #0  // Counter of lines (current line)

0:
    cmp x4, x0  // Compare current line and count of lines
    bge 3f // If current line >= count of lines
    mov x5, #0  // Counter of columns (current column)
    mul x6, x1, x4  // x6 = count of columns * current line
    add x6, x2, x6, lsl #2  // x6 -> Address of first element if current line
    ldr w7, [x6]    // w6 = max element, now first element in current line

1:
    cmp x5, x1 // Compare current column and count of columns
    bge 2f  // If current column >= count of columns
    ldr w8, [x6, x5, lsl #2]    // w8 = current element
    cmp w7, w8  // Compare max element and current element
    add x5, x5, #1  // w5 += 1
    bge 1b  // If max element >= current element
    mov w7, w8  // Else w7 = w8
    b   1b

2:
    str w7, [x3, x4, lsl #2]    // Save max element of current line
    add x4, x4, #1  // w4 += 1
    b   0b

3:
    ldp x29, x30, [sp], #16
    ret
    .size   make_maxs, .-make_maxs
    // End of "make_maxs"


    // Sort matrix according maxs
    // Args:
    //  x0 - count of lines (for matrix)
    //  x1 - count of columns (for matrix)
    //  x2 - adress of matrix
    //  x3 - adress of maxs (prepared)
    // Notes:
    //  Func does not destroy the value in x0 - x3. Just modify x2 and x3.
    //  Value in x4 - x13 will be destroyed.
    .type   sort, %function
sort:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x4, #0  // Counter of sorted part

0:
    add x4, x4, #1  // x4 += 1
    cmp x4, x0  // Compare count of sorted element and length of maxs
    bge 4f // If x4 >= x0
    ldr w7, [x3, x4, lsl #2]    // w7 = current unsorted element
    mov x5, x4  // We need to save x4, x5 will change

1:
    mov x6, x5  // x6 -> index of current unsorted element
    cbz x5, 3f  // If possible position is the first (x6 = 0)
    sub x5, x5, #1  // x5 -= 1. So x5 -> index of previous element for w7
    ldr w8, [x3, x5, lsl #2]    // w8 = previous element for w7
    cmp w7, w8  // Compare current and previous element
#ifdef REV
    ble 3f
#else
    bge 3f  // If w7 >= w8
#endif
    str w8, [x3, x6, lsl #2]    // Store w8 on place of current unsoted element

    // Swap lines
    mul x9, x6, x1  // Index of current unsorted * count of columns
    add x9, x2, x9, lsl #2  // x9 -> address of first element in curr. line
    mul x10, x5, x1 // Index of prev element * count of columns
    add x10, x2, x10, lsl #2    // x10 -> address of first elem. in prev. line
    mov x11, #0 // Counter for swap lines (index of curren column)
    b   2f

2:
    cmp x11, x1 // Compare swap counter and count of columns
    bge 1b
    ldr w12, [x9, x11, lsl #2]  // w12 = element from current  line
    ldr w13, [x10, x11, lsl #2] // w13 = element from prev. line
    str w12, [x10, x11, lsl #2] // Put elem. from curr. line in prev. line
    str w13, [x9, x11, lsl #2]  // Put elem. from prev. line in curr. line
    add x11, x11, #1    // x11 += 1
    b   2b

3:
    str w7, [x3, x6, lsl #2]    // Store w7 on its own place
    b   0b

4:
    ldp x29, x30, [sp], #16
    ret
    .size   sort, .-sort
    // End of "sort"

