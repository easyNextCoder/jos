/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(t_divide, T_DIVIDE);    // 0
TRAPHANDLER_NOEC(t_debug, T_DEBUG);        // 1
TRAPHANDLER_NOEC(t_nmi, T_NMI);            // 2
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)        // 3
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)        // 4
TRAPHANDLER_NOEC(t_bound, T_BOUND)        // 5
TRAPHANDLER_NOEC(t_illop, T_ILLOP)        // 6
TRAPHANDLER_NOEC(t_device, T_DEVICE)    // 7
TRAPHANDLER(t_dblflt, T_DBLFLT)            // 8
                                        // 9
TRAPHANDLER(t_tss, T_TSS)                // 10
TRAPHANDLER(t_segnp, T_SEGNP)            // 11
TRAPHANDLER(t_stack, T_STACK)            // 12
TRAPHANDLER(t_gpflt, T_GPFLT)            // 13
TRAPHANDLER(t_pgflt, T_PGFLT)            // 14
                                        // 15
TRAPHANDLER_NOEC(t_fperr, T_FPERR)        // 16
TRAPHANDLER(t_align, T_ALIGN)            // 17
TRAPHANDLER_NOEC(t_mchk, T_MCHK)        // 18
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)    // 19

TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)

/*registe iqr function to handle interrupt.*/
TRAPHANDLER_NOEC(iqr0, 32) 
TRAPHANDLER_NOEC(iqr1, 33) 
TRAPHANDLER_NOEC(iqr2, 34) 
TRAPHANDLER_NOEC(iqr3, 35) 
TRAPHANDLER_NOEC(iqr4, 36) 
TRAPHANDLER_NOEC(iqr5, 37) 
TRAPHANDLER_NOEC(iqr6, 38) 
TRAPHANDLER_NOEC(iqr7, 39) 
TRAPHANDLER_NOEC(iqr8, 40) 
TRAPHANDLER_NOEC(iqr9, 41) 
TRAPHANDLER_NOEC(iqr10, 42) 
TRAPHANDLER_NOEC(iqr11, 43) 
TRAPHANDLER_NOEC(iqr12, 44) 
TRAPHANDLER_NOEC(iqr13, 45) 
TRAPHANDLER_NOEC(iqr14, 46) 
TRAPHANDLER_NOEC(iqr15, 47)


/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
	pushl %es
	pushal

	movw $GD_KD,%eax
	movw %ax,%ds
	movw %ax,%es

	pushl %esp
	call trap
