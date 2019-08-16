
obj/user/primes:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 d3 0f 00 00       	call   80101f <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 20 14 80 00       	push   $0x801420
  800060:	e8 c4 01 00 00       	call   800229 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 2b 0e 00 00       	call   800e95 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 2c 14 80 00       	push   $0x80142c
  800079:	6a 1a                	push   $0x1a
  80007b:	68 35 14 80 00       	push   $0x801435
  800080:	e8 cb 00 00 00       	call   800150 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 86 0f 00 00       	call   80101f <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 86 0f 00 00       	call   801036 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 d6 0d 00 00       	call   800e95 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 2c 14 80 00       	push   $0x80142c
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 35 14 80 00       	push   $0x801435
  8000d2:	e8 79 00 00 00       	call   800150 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 46 0f 00 00       	call   801036 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 b5 0a 00 00       	call   800bbd <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800144:	6a 00                	push   $0x0
  800146:	e8 31 0a 00 00       	call   800b7c <sys_env_destroy>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800155:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800158:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015e:	e8 5a 0a 00 00       	call   800bbd <sys_getenvid>
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	ff 75 0c             	pushl  0xc(%ebp)
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	56                   	push   %esi
  80016d:	50                   	push   %eax
  80016e:	68 50 14 80 00       	push   $0x801450
  800173:	e8 b1 00 00 00       	call   800229 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	83 c4 18             	add    $0x18,%esp
  80017b:	53                   	push   %ebx
  80017c:	ff 75 10             	pushl  0x10(%ebp)
  80017f:	e8 54 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  800184:	c7 04 24 62 17 80 00 	movl   $0x801762,(%esp)
  80018b:	e8 99 00 00 00       	call   800229 <cprintf>
  800190:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x43>

00800196 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	53                   	push   %ebx
  80019a:	83 ec 04             	sub    $0x4,%esp
  80019d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a0:	8b 13                	mov    (%ebx),%edx
  8001a2:	8d 42 01             	lea    0x1(%edx),%eax
  8001a5:	89 03                	mov    %eax,(%ebx)
  8001a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 1a                	jne    8001cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	68 ff 00 00 00       	push   $0xff
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 79 09 00 00       	call   800b3f <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	68 96 01 80 00       	push   $0x800196
  800207:	e8 54 01 00 00       	call   800360 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020c:	83 c4 08             	add    $0x8,%esp
  80020f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800215:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 1e 09 00 00       	call   800b3f <sys_cputs>

	return b.cnt;
}
  800221:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800232:	50                   	push   %eax
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 9d ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 1c             	sub    $0x1c,%esp
  800246:	89 c7                	mov    %eax,%edi
  800248:	89 d6                	mov    %edx,%esi
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800253:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800256:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800259:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800261:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800264:	39 d3                	cmp    %edx,%ebx
  800266:	72 05                	jb     80026d <printnum+0x30>
  800268:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026b:	77 45                	ja     8002b2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026d:	83 ec 0c             	sub    $0xc,%esp
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	8b 45 14             	mov    0x14(%ebp),%eax
  800276:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800279:	53                   	push   %ebx
  80027a:	ff 75 10             	pushl  0x10(%ebp)
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 ef 0e 00 00       	call   801180 <__udivdi3>
  800291:	83 c4 18             	add    $0x18,%esp
  800294:	52                   	push   %edx
  800295:	50                   	push   %eax
  800296:	89 f2                	mov    %esi,%edx
  800298:	89 f8                	mov    %edi,%eax
  80029a:	e8 9e ff ff ff       	call   80023d <printnum>
  80029f:	83 c4 20             	add    $0x20,%esp
  8002a2:	eb 18                	jmp    8002bc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	ff 75 18             	pushl  0x18(%ebp)
  8002ab:	ff d7                	call   *%edi
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	eb 03                	jmp    8002b5 <printnum+0x78>
  8002b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b5:	83 eb 01             	sub    $0x1,%ebx
  8002b8:	85 db                	test   %ebx,%ebx
  8002ba:	7f e8                	jg     8002a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	56                   	push   %esi
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 dc 0f 00 00       	call   8012b0 <__umoddi3>
  8002d4:	83 c4 14             	add    $0x14,%esp
  8002d7:	0f be 80 73 14 80 00 	movsbl 0x801473(%eax),%eax
  8002de:	50                   	push   %eax
  8002df:	ff d7                	call   *%edi
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ef:	83 fa 01             	cmp    $0x1,%edx
  8002f2:	7e 0e                	jle    800302 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	8b 52 04             	mov    0x4(%edx),%edx
  800300:	eb 22                	jmp    800324 <getuint+0x38>
	else if (lflag)
  800302:	85 d2                	test   %edx,%edx
  800304:	74 10                	je     800316 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 0e                	jmp    800324 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800330:	8b 10                	mov    (%eax),%edx
  800332:	3b 50 04             	cmp    0x4(%eax),%edx
  800335:	73 0a                	jae    800341 <sprintputch+0x1b>
		*b->buf++ = ch;
  800337:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033a:	89 08                	mov    %ecx,(%eax)
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	88 02                	mov    %al,(%edx)
}
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800349:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034c:	50                   	push   %eax
  80034d:	ff 75 10             	pushl  0x10(%ebp)
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 05 00 00 00       	call   800360 <vprintfmt>
	va_end(ap);
}
  80035b:	83 c4 10             	add    $0x10,%esp
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 2c             	sub    $0x2c,%esp
  800369:	8b 75 08             	mov    0x8(%ebp),%esi
  80036c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800372:	eb 12                	jmp    800386 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800374:	85 c0                	test   %eax,%eax
  800376:	0f 84 d3 03 00 00    	je     80074f <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	53                   	push   %ebx
  800380:	50                   	push   %eax
  800381:	ff d6                	call   *%esi
  800383:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800386:	83 c7 01             	add    $0x1,%edi
  800389:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e2                	jne    800374 <vprintfmt+0x14>
  800392:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800396:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003a4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 07                	jmp    8003b9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8d 47 01             	lea    0x1(%edi),%eax
  8003bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bf:	0f b6 07             	movzbl (%edi),%eax
  8003c2:	0f b6 c8             	movzbl %al,%ecx
  8003c5:	83 e8 23             	sub    $0x23,%eax
  8003c8:	3c 55                	cmp    $0x55,%al
  8003ca:	0f 87 64 03 00 00    	ja     800734 <vprintfmt+0x3d4>
  8003d0:	0f b6 c0             	movzbl %al,%eax
  8003d3:	ff 24 85 40 15 80 00 	jmp    *0x801540(,%eax,4)
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003dd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e1:	eb d6                	jmp    8003b9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003eb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ee:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003fb:	83 fa 09             	cmp    $0x9,%edx
  8003fe:	77 39                	ja     800439 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800400:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800403:	eb e9                	jmp    8003ee <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 48 04             	lea    0x4(%eax),%ecx
  80040b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800416:	eb 27                	jmp    80043f <vprintfmt+0xdf>
  800418:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041b:	85 c0                	test   %eax,%eax
  80041d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800422:	0f 49 c8             	cmovns %eax,%ecx
  800425:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042b:	eb 8c                	jmp    8003b9 <vprintfmt+0x59>
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800430:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800437:	eb 80                	jmp    8003b9 <vprintfmt+0x59>
  800439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043c:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	0f 89 70 ff ff ff    	jns    8003b9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800449:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800456:	e9 5e ff ff ff       	jmp    8003b9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800461:	e9 53 ff ff ff       	jmp    8003b9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	53                   	push   %ebx
  800473:	ff 30                	pushl  (%eax)
  800475:	ff d6                	call   *%esi
			break;
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047d:	e9 04 ff ff ff       	jmp    800386 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	89 55 14             	mov    %edx,0x14(%ebp)
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	99                   	cltd   
  80048e:	31 d0                	xor    %edx,%eax
  800490:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800492:	83 f8 08             	cmp    $0x8,%eax
  800495:	7f 0b                	jg     8004a2 <vprintfmt+0x142>
  800497:	8b 14 85 a0 16 80 00 	mov    0x8016a0(,%eax,4),%edx
  80049e:	85 d2                	test   %edx,%edx
  8004a0:	75 18                	jne    8004ba <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004a2:	50                   	push   %eax
  8004a3:	68 8b 14 80 00       	push   $0x80148b
  8004a8:	53                   	push   %ebx
  8004a9:	56                   	push   %esi
  8004aa:	e8 94 fe ff ff       	call   800343 <printfmt>
  8004af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b5:	e9 cc fe ff ff       	jmp    800386 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ba:	52                   	push   %edx
  8004bb:	68 94 14 80 00       	push   $0x801494
  8004c0:	53                   	push   %ebx
  8004c1:	56                   	push   %esi
  8004c2:	e8 7c fe ff ff       	call   800343 <printfmt>
  8004c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cd:	e9 b4 fe ff ff       	jmp    800386 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	b8 84 14 80 00       	mov    $0x801484,%eax
  8004e4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004eb:	0f 8e 94 00 00 00    	jle    800585 <vprintfmt+0x225>
  8004f1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f5:	0f 84 98 00 00 00    	je     800593 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 c8             	pushl  -0x38(%ebp)
  800501:	57                   	push   %edi
  800502:	e8 d0 02 00 00       	call   8007d7 <strnlen>
  800507:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80050f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800512:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800516:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800519:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051e:	eb 0f                	jmp    80052f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	ff 75 e0             	pushl  -0x20(%ebp)
  800527:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 ef 01             	sub    $0x1,%edi
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 ff                	test   %edi,%edi
  800531:	7f ed                	jg     800520 <vprintfmt+0x1c0>
  800533:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800536:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800539:	85 c9                	test   %ecx,%ecx
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	0f 49 c1             	cmovns %ecx,%eax
  800543:	29 c1                	sub    %eax,%ecx
  800545:	89 75 08             	mov    %esi,0x8(%ebp)
  800548:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80054b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054e:	89 cb                	mov    %ecx,%ebx
  800550:	eb 4d                	jmp    80059f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800556:	74 1b                	je     800573 <vprintfmt+0x213>
  800558:	0f be c0             	movsbl %al,%eax
  80055b:	83 e8 20             	sub    $0x20,%eax
  80055e:	83 f8 5e             	cmp    $0x5e,%eax
  800561:	76 10                	jbe    800573 <vprintfmt+0x213>
					putch('?', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	6a 3f                	push   $0x3f
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb 0d                	jmp    800580 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	ff 75 0c             	pushl  0xc(%ebp)
  800579:	52                   	push   %edx
  80057a:	ff 55 08             	call   *0x8(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	83 eb 01             	sub    $0x1,%ebx
  800583:	eb 1a                	jmp    80059f <vprintfmt+0x23f>
  800585:	89 75 08             	mov    %esi,0x8(%ebp)
  800588:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80058b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800591:	eb 0c                	jmp    80059f <vprintfmt+0x23f>
  800593:	89 75 08             	mov    %esi,0x8(%ebp)
  800596:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800599:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059f:	83 c7 01             	add    $0x1,%edi
  8005a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a6:	0f be d0             	movsbl %al,%edx
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	74 23                	je     8005d0 <vprintfmt+0x270>
  8005ad:	85 f6                	test   %esi,%esi
  8005af:	78 a1                	js     800552 <vprintfmt+0x1f2>
  8005b1:	83 ee 01             	sub    $0x1,%esi
  8005b4:	79 9c                	jns    800552 <vprintfmt+0x1f2>
  8005b6:	89 df                	mov    %ebx,%edi
  8005b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005be:	eb 18                	jmp    8005d8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	6a 20                	push   $0x20
  8005c6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c8:	83 ef 01             	sub    $0x1,%edi
  8005cb:	83 c4 10             	add    $0x10,%esp
  8005ce:	eb 08                	jmp    8005d8 <vprintfmt+0x278>
  8005d0:	89 df                	mov    %ebx,%edi
  8005d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	7f e4                	jg     8005c0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005df:	e9 a2 fd ff ff       	jmp    800386 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e4:	83 fa 01             	cmp    $0x1,%edx
  8005e7:	7e 16                	jle    8005ff <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 08             	lea    0x8(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 50 04             	mov    0x4(%eax),%edx
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005fa:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005fd:	eb 32                	jmp    800631 <vprintfmt+0x2d1>
	else if (lflag)
  8005ff:	85 d2                	test   %edx,%edx
  800601:	74 18                	je     80061b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800611:	89 c1                	mov    %eax,%ecx
  800613:	c1 f9 1f             	sar    $0x1f,%ecx
  800616:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800619:	eb 16                	jmp    800631 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800629:	89 c1                	mov    %eax,%ecx
  80062b:	c1 f9 1f             	sar    $0x1f,%ecx
  80062e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800631:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800634:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800637:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800642:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800646:	0f 89 b0 00 00 00    	jns    8006fc <vprintfmt+0x39c>
				putch('-', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 2d                	push   $0x2d
  800652:	ff d6                	call   *%esi
				num = -(long long) num;
  800654:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800657:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80065a:	f7 d8                	neg    %eax
  80065c:	83 d2 00             	adc    $0x0,%edx
  80065f:	f7 da                	neg    %edx
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800667:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066f:	e9 88 00 00 00       	jmp    8006fc <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 70 fc ff ff       	call   8002ec <getuint>
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800687:	eb 73                	jmp    8006fc <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  800689:	8d 45 14             	lea    0x14(%ebp),%eax
  80068c:	e8 5b fc ff ff       	call   8002ec <getuint>
  800691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	6a 58                	push   $0x58
  80069d:	ff d6                	call   *%esi
			putch('X', putdat);
  80069f:	83 c4 08             	add    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 58                	push   $0x58
  8006a5:	ff d6                	call   *%esi
			putch('X', putdat);
  8006a7:	83 c4 08             	add    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 58                	push   $0x58
  8006ad:	ff d6                	call   *%esi
			goto number;
  8006af:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8006b2:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8006b7:	eb 43                	jmp    8006fc <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 30                	push   $0x30
  8006bf:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c1:	83 c4 08             	add    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	6a 78                	push   $0x78
  8006c7:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 50 04             	lea    0x4(%eax),%edx
  8006cf:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006df:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e7:	eb 13                	jmp    8006fc <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ec:	e8 fb fb ff ff       	call   8002ec <getuint>
  8006f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	83 ec 0c             	sub    $0xc,%esp
  8006ff:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800703:	52                   	push   %edx
  800704:	ff 75 e0             	pushl  -0x20(%ebp)
  800707:	50                   	push   %eax
  800708:	ff 75 dc             	pushl  -0x24(%ebp)
  80070b:	ff 75 d8             	pushl  -0x28(%ebp)
  80070e:	89 da                	mov    %ebx,%edx
  800710:	89 f0                	mov    %esi,%eax
  800712:	e8 26 fb ff ff       	call   80023d <printnum>
			break;
  800717:	83 c4 20             	add    $0x20,%esp
  80071a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071d:	e9 64 fc ff ff       	jmp    800386 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	53                   	push   %ebx
  800726:	51                   	push   %ecx
  800727:	ff d6                	call   *%esi
			break;
  800729:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072f:	e9 52 fc ff ff       	jmp    800386 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 25                	push   $0x25
  80073a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb 03                	jmp    800744 <vprintfmt+0x3e4>
  800741:	83 ef 01             	sub    $0x1,%edi
  800744:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800748:	75 f7                	jne    800741 <vprintfmt+0x3e1>
  80074a:	e9 37 fc ff ff       	jmp    800386 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80074f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800752:	5b                   	pop    %ebx
  800753:	5e                   	pop    %esi
  800754:	5f                   	pop    %edi
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	83 ec 18             	sub    $0x18,%esp
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800763:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800766:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800774:	85 c0                	test   %eax,%eax
  800776:	74 26                	je     80079e <vsnprintf+0x47>
  800778:	85 d2                	test   %edx,%edx
  80077a:	7e 22                	jle    80079e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077c:	ff 75 14             	pushl  0x14(%ebp)
  80077f:	ff 75 10             	pushl  0x10(%ebp)
  800782:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800785:	50                   	push   %eax
  800786:	68 26 03 80 00       	push   $0x800326
  80078b:	e8 d0 fb ff ff       	call   800360 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800790:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800793:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800799:	83 c4 10             	add    $0x10,%esp
  80079c:	eb 05                	jmp    8007a3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ae:	50                   	push   %eax
  8007af:	ff 75 10             	pushl  0x10(%ebp)
  8007b2:	ff 75 0c             	pushl  0xc(%ebp)
  8007b5:	ff 75 08             	pushl  0x8(%ebp)
  8007b8:	e8 9a ff ff ff       	call   800757 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ca:	eb 03                	jmp    8007cf <strlen+0x10>
		n++;
  8007cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d3:	75 f7                	jne    8007cc <strlen+0xd>
		n++;
	return n;
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e5:	eb 03                	jmp    8007ea <strnlen+0x13>
		n++;
  8007e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ea:	39 c2                	cmp    %eax,%edx
  8007ec:	74 08                	je     8007f6 <strnlen+0x1f>
  8007ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f2:	75 f3                	jne    8007e7 <strnlen+0x10>
  8007f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800802:	89 c2                	mov    %eax,%edx
  800804:	83 c2 01             	add    $0x1,%edx
  800807:	83 c1 01             	add    $0x1,%ecx
  80080a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800811:	84 db                	test   %bl,%bl
  800813:	75 ef                	jne    800804 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081f:	53                   	push   %ebx
  800820:	e8 9a ff ff ff       	call   8007bf <strlen>
  800825:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800828:	ff 75 0c             	pushl  0xc(%ebp)
  80082b:	01 d8                	add    %ebx,%eax
  80082d:	50                   	push   %eax
  80082e:	e8 c5 ff ff ff       	call   8007f8 <strcpy>
	return dst;
}
  800833:	89 d8                	mov    %ebx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 75 08             	mov    0x8(%ebp),%esi
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800845:	89 f3                	mov    %esi,%ebx
  800847:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084a:	89 f2                	mov    %esi,%edx
  80084c:	eb 0f                	jmp    80085d <strncpy+0x23>
		*dst++ = *src;
  80084e:	83 c2 01             	add    $0x1,%edx
  800851:	0f b6 01             	movzbl (%ecx),%eax
  800854:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800857:	80 39 01             	cmpb   $0x1,(%ecx)
  80085a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085d:	39 da                	cmp    %ebx,%edx
  80085f:	75 ed                	jne    80084e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800861:	89 f0                	mov    %esi,%eax
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 75 08             	mov    0x8(%ebp),%esi
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800872:	8b 55 10             	mov    0x10(%ebp),%edx
  800875:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800877:	85 d2                	test   %edx,%edx
  800879:	74 21                	je     80089c <strlcpy+0x35>
  80087b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087f:	89 f2                	mov    %esi,%edx
  800881:	eb 09                	jmp    80088c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800883:	83 c2 01             	add    $0x1,%edx
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80088c:	39 c2                	cmp    %eax,%edx
  80088e:	74 09                	je     800899 <strlcpy+0x32>
  800890:	0f b6 19             	movzbl (%ecx),%ebx
  800893:	84 db                	test   %bl,%bl
  800895:	75 ec                	jne    800883 <strlcpy+0x1c>
  800897:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800899:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089c:	29 f0                	sub    %esi,%eax
}
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ab:	eb 06                	jmp    8008b3 <strcmp+0x11>
		p++, q++;
  8008ad:	83 c1 01             	add    $0x1,%ecx
  8008b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b3:	0f b6 01             	movzbl (%ecx),%eax
  8008b6:	84 c0                	test   %al,%al
  8008b8:	74 04                	je     8008be <strcmp+0x1c>
  8008ba:	3a 02                	cmp    (%edx),%al
  8008bc:	74 ef                	je     8008ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008be:	0f b6 c0             	movzbl %al,%eax
  8008c1:	0f b6 12             	movzbl (%edx),%edx
  8008c4:	29 d0                	sub    %edx,%eax
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	53                   	push   %ebx
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d2:	89 c3                	mov    %eax,%ebx
  8008d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d7:	eb 06                	jmp    8008df <strncmp+0x17>
		n--, p++, q++;
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008df:	39 d8                	cmp    %ebx,%eax
  8008e1:	74 15                	je     8008f8 <strncmp+0x30>
  8008e3:	0f b6 08             	movzbl (%eax),%ecx
  8008e6:	84 c9                	test   %cl,%cl
  8008e8:	74 04                	je     8008ee <strncmp+0x26>
  8008ea:	3a 0a                	cmp    (%edx),%cl
  8008ec:	74 eb                	je     8008d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ee:	0f b6 00             	movzbl (%eax),%eax
  8008f1:	0f b6 12             	movzbl (%edx),%edx
  8008f4:	29 d0                	sub    %edx,%eax
  8008f6:	eb 05                	jmp    8008fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fd:	5b                   	pop    %ebx
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090a:	eb 07                	jmp    800913 <strchr+0x13>
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 0f                	je     80091f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	0f b6 10             	movzbl (%eax),%edx
  800916:	84 d2                	test   %dl,%dl
  800918:	75 f2                	jne    80090c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80091a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092b:	eb 03                	jmp    800930 <strfind+0xf>
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800933:	38 ca                	cmp    %cl,%dl
  800935:	74 04                	je     80093b <strfind+0x1a>
  800937:	84 d2                	test   %dl,%dl
  800939:	75 f2                	jne    80092d <strfind+0xc>
			break;
	return (char *) s;
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 7d 08             	mov    0x8(%ebp),%edi
  800946:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800949:	85 c9                	test   %ecx,%ecx
  80094b:	74 36                	je     800983 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800953:	75 28                	jne    80097d <memset+0x40>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 23                	jne    80097d <memset+0x40>
		c &= 0xFF;
  80095a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095e:	89 d3                	mov    %edx,%ebx
  800960:	c1 e3 08             	shl    $0x8,%ebx
  800963:	89 d6                	mov    %edx,%esi
  800965:	c1 e6 18             	shl    $0x18,%esi
  800968:	89 d0                	mov    %edx,%eax
  80096a:	c1 e0 10             	shl    $0x10,%eax
  80096d:	09 f0                	or     %esi,%eax
  80096f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800971:	89 d8                	mov    %ebx,%eax
  800973:	09 d0                	or     %edx,%eax
  800975:	c1 e9 02             	shr    $0x2,%ecx
  800978:	fc                   	cld    
  800979:	f3 ab                	rep stos %eax,%es:(%edi)
  80097b:	eb 06                	jmp    800983 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	fc                   	cld    
  800981:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800983:	89 f8                	mov    %edi,%eax
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	57                   	push   %edi
  80098e:	56                   	push   %esi
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 75 0c             	mov    0xc(%ebp),%esi
  800995:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800998:	39 c6                	cmp    %eax,%esi
  80099a:	73 35                	jae    8009d1 <memmove+0x47>
  80099c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099f:	39 d0                	cmp    %edx,%eax
  8009a1:	73 2e                	jae    8009d1 <memmove+0x47>
		s += n;
		d += n;
  8009a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	89 d6                	mov    %edx,%esi
  8009a8:	09 fe                	or     %edi,%esi
  8009aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b0:	75 13                	jne    8009c5 <memmove+0x3b>
  8009b2:	f6 c1 03             	test   $0x3,%cl
  8009b5:	75 0e                	jne    8009c5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b7:	83 ef 04             	sub    $0x4,%edi
  8009ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bd:	c1 e9 02             	shr    $0x2,%ecx
  8009c0:	fd                   	std    
  8009c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c3:	eb 09                	jmp    8009ce <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c5:	83 ef 01             	sub    $0x1,%edi
  8009c8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009cb:	fd                   	std    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ce:	fc                   	cld    
  8009cf:	eb 1d                	jmp    8009ee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	89 f2                	mov    %esi,%edx
  8009d3:	09 c2                	or     %eax,%edx
  8009d5:	f6 c2 03             	test   $0x3,%dl
  8009d8:	75 0f                	jne    8009e9 <memmove+0x5f>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0a                	jne    8009e9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009df:	c1 e9 02             	shr    $0x2,%ecx
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 05                	jmp    8009ee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f5:	ff 75 10             	pushl  0x10(%ebp)
  8009f8:	ff 75 0c             	pushl  0xc(%ebp)
  8009fb:	ff 75 08             	pushl  0x8(%ebp)
  8009fe:	e8 87 ff ff ff       	call   80098a <memmove>
}
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a10:	89 c6                	mov    %eax,%esi
  800a12:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a15:	eb 1a                	jmp    800a31 <memcmp+0x2c>
		if (*s1 != *s2)
  800a17:	0f b6 08             	movzbl (%eax),%ecx
  800a1a:	0f b6 1a             	movzbl (%edx),%ebx
  800a1d:	38 d9                	cmp    %bl,%cl
  800a1f:	74 0a                	je     800a2b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a21:	0f b6 c1             	movzbl %cl,%eax
  800a24:	0f b6 db             	movzbl %bl,%ebx
  800a27:	29 d8                	sub    %ebx,%eax
  800a29:	eb 0f                	jmp    800a3a <memcmp+0x35>
		s1++, s2++;
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a31:	39 f0                	cmp    %esi,%eax
  800a33:	75 e2                	jne    800a17 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	53                   	push   %ebx
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a45:	89 c1                	mov    %eax,%ecx
  800a47:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4e:	eb 0a                	jmp    800a5a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a50:	0f b6 10             	movzbl (%eax),%edx
  800a53:	39 da                	cmp    %ebx,%edx
  800a55:	74 07                	je     800a5e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	39 c8                	cmp    %ecx,%eax
  800a5c:	72 f2                	jb     800a50 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6d:	eb 03                	jmp    800a72 <strtol+0x11>
		s++;
  800a6f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a72:	0f b6 01             	movzbl (%ecx),%eax
  800a75:	3c 20                	cmp    $0x20,%al
  800a77:	74 f6                	je     800a6f <strtol+0xe>
  800a79:	3c 09                	cmp    $0x9,%al
  800a7b:	74 f2                	je     800a6f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7d:	3c 2b                	cmp    $0x2b,%al
  800a7f:	75 0a                	jne    800a8b <strtol+0x2a>
		s++;
  800a81:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a84:	bf 00 00 00 00       	mov    $0x0,%edi
  800a89:	eb 11                	jmp    800a9c <strtol+0x3b>
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a90:	3c 2d                	cmp    $0x2d,%al
  800a92:	75 08                	jne    800a9c <strtol+0x3b>
		s++, neg = 1;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa2:	75 15                	jne    800ab9 <strtol+0x58>
  800aa4:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa7:	75 10                	jne    800ab9 <strtol+0x58>
  800aa9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aad:	75 7c                	jne    800b2b <strtol+0xca>
		s += 2, base = 16;
  800aaf:	83 c1 02             	add    $0x2,%ecx
  800ab2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab7:	eb 16                	jmp    800acf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 12                	jne    800acf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800abd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac5:	75 08                	jne    800acf <strtol+0x6e>
		s++, base = 8;
  800ac7:	83 c1 01             	add    $0x1,%ecx
  800aca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad7:	0f b6 11             	movzbl (%ecx),%edx
  800ada:	8d 72 d0             	lea    -0x30(%edx),%esi
  800add:	89 f3                	mov    %esi,%ebx
  800adf:	80 fb 09             	cmp    $0x9,%bl
  800ae2:	77 08                	ja     800aec <strtol+0x8b>
			dig = *s - '0';
  800ae4:	0f be d2             	movsbl %dl,%edx
  800ae7:	83 ea 30             	sub    $0x30,%edx
  800aea:	eb 22                	jmp    800b0e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aec:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aef:	89 f3                	mov    %esi,%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 08                	ja     800afe <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af6:	0f be d2             	movsbl %dl,%edx
  800af9:	83 ea 57             	sub    $0x57,%edx
  800afc:	eb 10                	jmp    800b0e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800afe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b01:	89 f3                	mov    %esi,%ebx
  800b03:	80 fb 19             	cmp    $0x19,%bl
  800b06:	77 16                	ja     800b1e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b08:	0f be d2             	movsbl %dl,%edx
  800b0b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b11:	7d 0b                	jge    800b1e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b13:	83 c1 01             	add    $0x1,%ecx
  800b16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b1c:	eb b9                	jmp    800ad7 <strtol+0x76>

	if (endptr)
  800b1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b22:	74 0d                	je     800b31 <strtol+0xd0>
		*endptr = (char *) s;
  800b24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b27:	89 0e                	mov    %ecx,(%esi)
  800b29:	eb 06                	jmp    800b31 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2b:	85 db                	test   %ebx,%ebx
  800b2d:	74 98                	je     800ac7 <strtol+0x66>
  800b2f:	eb 9e                	jmp    800acf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b31:	89 c2                	mov    %eax,%edx
  800b33:	f7 da                	neg    %edx
  800b35:	85 ff                	test   %edi,%edi
  800b37:	0f 45 c2             	cmovne %edx,%eax
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	89 c3                	mov    %eax,%ebx
  800b52:	89 c7                	mov    %eax,%edi
  800b54:	89 c6                	mov    %eax,%esi
  800b56:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800b85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	89 cb                	mov    %ecx,%ebx
  800b94:	89 cf                	mov    %ecx,%edi
  800b96:	89 ce                	mov    %ecx,%esi
  800b98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 17                	jle    800bb5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 03                	push   $0x3
  800ba4:	68 c4 16 80 00       	push   $0x8016c4
  800ba9:	6a 23                	push   $0x23
  800bab:	68 e1 16 80 00       	push   $0x8016e1
  800bb0:	e8 9b f5 ff ff       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcd:	89 d1                	mov    %edx,%ecx
  800bcf:	89 d3                	mov    %edx,%ebx
  800bd1:	89 d7                	mov    %edx,%edi
  800bd3:	89 d6                	mov    %edx,%esi
  800bd5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_yield>:

void
sys_yield(void)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800be2:	ba 00 00 00 00       	mov    $0x0,%edx
  800be7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bec:	89 d1                	mov    %edx,%ecx
  800bee:	89 d3                	mov    %edx,%ebx
  800bf0:	89 d7                	mov    %edx,%edi
  800bf2:	89 d6                	mov    %edx,%esi
  800bf4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c04:	be 00 00 00 00       	mov    $0x0,%esi
  800c09:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	89 f7                	mov    %esi,%edi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 04                	push   $0x4
  800c25:	68 c4 16 80 00       	push   $0x8016c4
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 e1 16 80 00       	push   $0x8016e1
  800c31:	e8 1a f5 ff ff       	call   800150 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c47:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c58:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 05                	push   $0x5
  800c67:	68 c4 16 80 00       	push   $0x8016c4
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 e1 16 80 00       	push   $0x8016e1
  800c73:	e8 d8 f4 ff ff       	call   800150 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800c89:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	8b 55 08             	mov    0x8(%ebp),%edx
  800c99:	89 df                	mov    %ebx,%edi
  800c9b:	89 de                	mov    %ebx,%esi
  800c9d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	7e 17                	jle    800cba <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 06                	push   $0x6
  800ca9:	68 c4 16 80 00       	push   $0x8016c4
  800cae:	6a 23                	push   $0x23
  800cb0:	68 e1 16 80 00       	push   $0x8016e1
  800cb5:	e8 96 f4 ff ff       	call   800150 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	57                   	push   %edi
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800ccb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	89 df                	mov    %ebx,%edi
  800cdd:	89 de                	mov    %ebx,%esi
  800cdf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7e 17                	jle    800cfc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 08                	push   $0x8
  800ceb:	68 c4 16 80 00       	push   $0x8016c4
  800cf0:	6a 23                	push   $0x23
  800cf2:	68 e1 16 80 00       	push   $0x8016e1
  800cf7:	e8 54 f4 ff ff       	call   800150 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	57                   	push   %edi
  800d08:	56                   	push   %esi
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d12:	b8 09 00 00 00       	mov    $0x9,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	89 df                	mov    %ebx,%edi
  800d1f:	89 de                	mov    %ebx,%esi
  800d21:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d23:	85 c0                	test   %eax,%eax
  800d25:	7e 17                	jle    800d3e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 09                	push   $0x9
  800d2d:	68 c4 16 80 00       	push   $0x8016c4
  800d32:	6a 23                	push   $0x23
  800d34:	68 e1 16 80 00       	push   $0x8016e1
  800d39:	e8 12 f4 ff ff       	call   800150 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	57                   	push   %edi
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d62:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800d72:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d77:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	89 cb                	mov    %ecx,%ebx
  800d81:	89 cf                	mov    %ecx,%edi
  800d83:	89 ce                	mov    %ecx,%esi
  800d85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800d87:	85 c0                	test   %eax,%eax
  800d89:	7e 17                	jle    800da2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0c                	push   $0xc
  800d91:	68 c4 16 80 00       	push   $0x8016c4
  800d96:	6a 23                	push   $0x23
  800d98:	68 e1 16 80 00       	push   $0x8016e1
  800d9d:	e8 ae f3 ff ff       	call   800150 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	53                   	push   %ebx
  800dae:	83 ec 04             	sub    $0x4,%esp
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800db6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dba:	74 2d                	je     800de9 <pgfault+0x3f>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800dbc:	89 d8                	mov    %ebx,%eax
  800dbe:	c1 e8 16             	shr    $0x16,%eax
  800dc1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
  800dc8:	a8 01                	test   $0x1,%al
  800dca:	74 1d                	je     800de9 <pgfault+0x3f>
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
  800dcc:	89 d8                	mov    %ebx,%eax
  800dce:	c1 e8 0c             	shr    $0xc,%eax
  800dd1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
  800dd8:	f6 c2 01             	test   $0x1,%dl
  800ddb:	74 0c                	je     800de9 <pgfault+0x3f>
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
  800ddd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(
  800de4:	f6 c4 08             	test   $0x8,%ah
  800de7:	75 14                	jne    800dfd <pgfault+0x53>
		(err&FEC_WR)&&
		(uvpd[PDX(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_P)&&
		(uvpt[PGNUM(addr)]&PTE_COW)	
	    )){
		panic("can't copy-on-write.\n");
  800de9:	83 ec 04             	sub    $0x4,%esp
  800dec:	68 ef 16 80 00       	push   $0x8016ef
  800df1:	6a 22                	push   $0x22
  800df3:	68 05 17 80 00       	push   $0x801705
  800df8:	e8 53 f3 ff ff       	call   800150 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.
	
	// LAB 4: Your code here.
	cprintf("in pgfault.\n");
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	68 10 17 80 00       	push   $0x801710
  800e05:	e8 1f f4 ff ff       	call   800229 <cprintf>
	int retv = 0;
	addr = ROUNDDOWN(addr, PGSIZE);
  800e0a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if(sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P)<0){
  800e10:	83 c4 0c             	add    $0xc,%esp
  800e13:	6a 07                	push   $0x7
  800e15:	68 00 f0 7f 00       	push   $0x7ff000
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 da fd ff ff       	call   800bfb <sys_page_alloc>
  800e21:	83 c4 10             	add    $0x10,%esp
  800e24:	85 c0                	test   %eax,%eax
  800e26:	79 14                	jns    800e3c <pgfault+0x92>
		panic("sys_page_alloc");
  800e28:	83 ec 04             	sub    $0x4,%esp
  800e2b:	68 1d 17 80 00       	push   $0x80171d
  800e30:	6a 30                	push   $0x30
  800e32:	68 05 17 80 00       	push   $0x801705
  800e37:	e8 14 f3 ff ff       	call   800150 <_panic>
	}
	memcpy(PFTEMP, addr, PGSIZE);
  800e3c:	83 ec 04             	sub    $0x4,%esp
  800e3f:	68 00 10 00 00       	push   $0x1000
  800e44:	53                   	push   %ebx
  800e45:	68 00 f0 7f 00       	push   $0x7ff000
  800e4a:	e8 a3 fb ff ff       	call   8009f2 <memcpy>
	
	retv = sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P);
  800e4f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e56:	53                   	push   %ebx
  800e57:	6a 00                	push   $0x0
  800e59:	68 00 f0 7f 00       	push   $0x7ff000
  800e5e:	6a 00                	push   $0x0
  800e60:	e8 d9 fd ff ff       	call   800c3e <sys_page_map>
	if(retv < 0){
  800e65:	83 c4 20             	add    $0x20,%esp
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	79 14                	jns    800e80 <pgfault+0xd6>
		panic("sys_page_map");
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	68 2c 17 80 00       	push   $0x80172c
  800e74:	6a 36                	push   $0x36
  800e76:	68 05 17 80 00       	push   $0x801705
  800e7b:	e8 d0 f2 ff ff       	call   800150 <_panic>
	}
	cprintf("out of pgfault.\n");
  800e80:	83 ec 0c             	sub    $0xc,%esp
  800e83:	68 39 17 80 00       	push   $0x801739
  800e88:	e8 9c f3 ff ff       	call   800229 <cprintf>
	return;
  800e8d:	83 c4 10             	add    $0x10,%esp
	panic("pgfault not implemented");
}
  800e90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	57                   	push   %edi
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	83 ec 18             	sub    $0x18,%esp
	cprintf("\t\t we are in the fork().\n");
  800e9e:	68 4a 17 80 00       	push   $0x80174a
  800ea3:	e8 81 f3 ff ff       	call   800229 <cprintf>
	// LAB 4: Your code here.
	envid_t child_envid = -1;	
	//first set up pgfault_handler
	set_pgfault_handler(pgfault);
  800ea8:	c7 04 24 aa 0d 80 00 	movl   $0x800daa,(%esp)
  800eaf:	e8 d2 01 00 00       	call   801086 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb4:	b8 07 00 00 00       	mov    $0x7,%eax
  800eb9:	cd 30                	int    $0x30
  800ebb:	89 c6                	mov    %eax,%esi
	//create a child
	child_envid = sys_exofork();
	if(child_envid < 0 ){
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	79 17                	jns    800ee0 <fork+0x4b>
		panic("sys_exofork failed.");
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	68 64 17 80 00       	push   $0x801764
  800ed1:	68 82 00 00 00       	push   $0x82
  800ed6:	68 05 17 80 00       	push   $0x801705
  800edb:	e8 70 f2 ff ff       	call   800150 <_panic>
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800ee0:	89 d8                	mov    %ebx,%eax
  800ee2:	c1 e8 16             	shr    $0x16,%eax
  800ee5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
  800eec:	a8 01                	test   $0x1,%al
  800eee:	0f 84 e8 00 00 00    	je     800fdc <fork+0x147>
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800ef4:	89 d8                	mov    %ebx,%eax
  800ef6:	c1 e8 0c             	shr    $0xc,%eax
  800ef9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
  800f00:	f6 c2 01             	test   $0x1,%dl
  800f03:	0f 84 d3 00 00 00    	je     800fdc <fork+0x147>
			(uvpt[PGNUM(addr)] & PTE_P)&& 
			(uvpt[PGNUM(addr)] & PTE_U)
  800f09:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
		if (
			(uvpd[PDX(addr)] & PTE_P) && 
			(uvpt[PGNUM(addr)] & PTE_P)&& 
  800f10:	f6 c2 04             	test   $0x4,%dl
  800f13:	0f 84 c3 00 00 00    	je     800fdc <fork+0x147>
duppage(envid_t envid, unsigned pn)
{
	int r = 0;

	// LAB 4: Your code here.
	void *addr = (void*)(pn*PGSIZE);
  800f19:	89 c7                	mov    %eax,%edi
  800f1b:	c1 e7 0c             	shl    $0xc,%edi
	if( (uvpt[pn] & PTE_W)||(uvpt[pn]) & PTE_COW ){
  800f1e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f25:	f6 c2 02             	test   $0x2,%dl
  800f28:	75 10                	jne    800f3a <fork+0xa5>
  800f2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f31:	f6 c4 08             	test   $0x8,%ah
  800f34:	0f 84 90 00 00 00    	je     800fca <fork+0x135>
		cprintf("!!start page map.\n");	
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	68 78 17 80 00       	push   $0x801778
  800f42:	e8 e2 f2 ff ff       	call   800229 <cprintf>
		r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_P|PTE_U);
  800f47:	c7 04 24 05 08 00 00 	movl   $0x805,(%esp)
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	57                   	push   %edi
  800f51:	6a 00                	push   $0x0
  800f53:	e8 e6 fc ff ff       	call   800c3e <sys_page_map>
		if(r<0){
  800f58:	83 c4 20             	add    $0x20,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	79 22                	jns    800f81 <fork+0xec>
			cprintf("sys_page_map failed :%d\n",r);
  800f5f:	83 ec 08             	sub    $0x8,%esp
  800f62:	50                   	push   %eax
  800f63:	68 8b 17 80 00       	push   $0x80178b
  800f68:	e8 bc f2 ff ff       	call   800229 <cprintf>
			panic("map env id 0 to child_envid failed.");
  800f6d:	83 c4 0c             	add    $0xc,%esp
  800f70:	68 f4 17 80 00       	push   $0x8017f4
  800f75:	6a 54                	push   $0x54
  800f77:	68 05 17 80 00       	push   $0x801705
  800f7c:	e8 cf f1 ff ff       	call   800150 <_panic>
		
		}
		cprintf("mapping addr is:%x\n",addr);
  800f81:	83 ec 08             	sub    $0x8,%esp
  800f84:	57                   	push   %edi
  800f85:	68 a4 17 80 00       	push   $0x8017a4
  800f8a:	e8 9a f2 ff ff       	call   800229 <cprintf>
		r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_P|PTE_U);
  800f8f:	c7 04 24 05 08 00 00 	movl   $0x805,(%esp)
  800f96:	57                   	push   %edi
  800f97:	6a 00                	push   $0x0
  800f99:	57                   	push   %edi
  800f9a:	6a 00                	push   $0x0
  800f9c:	e8 9d fc ff ff       	call   800c3e <sys_page_map>
//		cprintf("!!end sys_page_map 0.\n");
		if(r<0){
  800fa1:	83 c4 20             	add    $0x20,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	79 34                	jns    800fdc <fork+0x147>
			cprintf("sys_page_map failed :%d\n",r);
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	50                   	push   %eax
  800fac:	68 8b 17 80 00       	push   $0x80178b
  800fb1:	e8 73 f2 ff ff       	call   800229 <cprintf>
			panic("map env id 0 to 0");
  800fb6:	83 c4 0c             	add    $0xc,%esp
  800fb9:	68 b8 17 80 00       	push   $0x8017b8
  800fbe:	6a 5c                	push   $0x5c
  800fc0:	68 05 17 80 00       	push   $0x801705
  800fc5:	e8 86 f1 ff ff       	call   800150 <_panic>
		}//?we should mark PTE_COW both to two id.
//		cprintf("!!end page map.\n");	
	}else{
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	6a 05                	push   $0x5
  800fcf:	57                   	push   %edi
  800fd0:	56                   	push   %esi
  800fd1:	57                   	push   %edi
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 65 fc ff ff       	call   800c3e <sys_page_map>
  800fd9:	83 c4 20             	add    $0x20,%esp
	if(child_envid < 0 ){
		panic("sys_exofork failed.");
	} 
	uint32_t addr = 0;	
	//copy address space and page fault handler to the child.
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE){
  800fdc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fe2:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fe8:	0f 85 f2 fe ff ff    	jne    800ee0 <fork+0x4b>
			(uvpt[PGNUM(addr)] & PTE_U)
		   ){
			duppage(child_envid, PGNUM(addr));
	 	    }	
	}
	panic("failed at duppage.");
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	68 ca 17 80 00       	push   $0x8017ca
  800ff6:	68 8f 00 00 00       	push   $0x8f
  800ffb:	68 05 17 80 00       	push   $0x801705
  801000:	e8 4b f1 ff ff       	call   800150 <_panic>

00801005 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80100b:	68 dd 17 80 00       	push   $0x8017dd
  801010:	68 a4 00 00 00       	push   $0xa4
  801015:	68 05 17 80 00       	push   $0x801705
  80101a:	e8 31 f1 ff ff       	call   800150 <_panic>

0080101f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801025:	68 18 18 80 00       	push   $0x801818
  80102a:	6a 1a                	push   $0x1a
  80102c:	68 31 18 80 00       	push   $0x801831
  801031:	e8 1a f1 ff ff       	call   800150 <_panic>

00801036 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  80103c:	68 3b 18 80 00       	push   $0x80183b
  801041:	6a 2a                	push   $0x2a
  801043:	68 31 18 80 00       	push   $0x801831
  801048:	e8 03 f1 ff ff       	call   800150 <_panic>

0080104d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801053:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801058:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80105b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801061:	8b 52 50             	mov    0x50(%edx),%edx
  801064:	39 ca                	cmp    %ecx,%edx
  801066:	75 0d                	jne    801075 <ipc_find_env+0x28>
			return envs[i].env_id;
  801068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80106b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801070:	8b 40 48             	mov    0x48(%eax),%eax
  801073:	eb 0f                	jmp    801084 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801075:	83 c0 01             	add    $0x1,%eax
  801078:	3d 00 04 00 00       	cmp    $0x400,%eax
  80107d:	75 d9                	jne    801058 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80107f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	83 ec 14             	sub    $0x14,%esp
	int r;
	cprintf("\twe enter set_pgfault_handler.\n");	
  80108c:	68 54 18 80 00       	push   $0x801854
  801091:	e8 93 f1 ff ff       	call   800229 <cprintf>
//	_pgfault_handler = handler;
	if (_pgfault_handler == 0) {
  801096:	83 c4 10             	add    $0x10,%esp
  801099:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8010a0:	0f 85 8d 00 00 00    	jne    801133 <set_pgfault_handler+0xad>
		cprintf("\t we are setting _pgfault_handler.\n");
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	68 74 18 80 00       	push   $0x801874
  8010ae:	e8 76 f1 ff ff       	call   800229 <cprintf>
		// First time through!
		// LAB 4: Your code here.
		//panic("set_pgfault_handler not implemented");
		/*copy the idea and code from net.*/
		void *user_ex_stack = (void *)(UXSTACKTOP - PGSIZE);
		int retv = sys_page_alloc(thisenv->env_id, user_ex_stack, PTE_P|PTE_U|PTE_W);
  8010b3:	a1 04 20 80 00       	mov    0x802004,%eax
  8010b8:	8b 40 48             	mov    0x48(%eax),%eax
  8010bb:	83 c4 0c             	add    $0xc,%esp
  8010be:	6a 07                	push   $0x7
  8010c0:	68 00 f0 bf ee       	push   $0xeebff000
  8010c5:	50                   	push   %eax
  8010c6:	e8 30 fb ff ff       	call   800bfb <sys_page_alloc>
		if(retv != 0){
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	74 14                	je     8010e6 <set_pgfault_handler+0x60>
			panic("can't alloc page for user exception stack.\n");
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	68 98 18 80 00       	push   $0x801898
  8010da:	6a 27                	push   $0x27
  8010dc:	68 ec 18 80 00       	push   $0x8018ec
  8010e1:	e8 6a f0 ff ff       	call   800150 <_panic>
		}
		cprintf("the _pgfault_upcall is:%d\n",_pgfault_upcall);
  8010e6:	83 ec 08             	sub    $0x8,%esp
  8010e9:	68 4d 11 80 00       	push   $0x80114d
  8010ee:	68 fa 18 80 00       	push   $0x8018fa
  8010f3:	e8 31 f1 ff ff       	call   800229 <cprintf>
		cprintf("thisenv->env_id is:%d\n",thisenv->env_id);
  8010f8:	a1 04 20 80 00       	mov    0x802004,%eax
  8010fd:	8b 40 48             	mov    0x48(%eax),%eax
  801100:	83 c4 08             	add    $0x8,%esp
  801103:	50                   	push   %eax
  801104:	68 15 19 80 00       	push   $0x801915
  801109:	e8 1b f1 ff ff       	call   800229 <cprintf>
		sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  80110e:	a1 04 20 80 00       	mov    0x802004,%eax
  801113:	8b 40 48             	mov    0x48(%eax),%eax
  801116:	83 c4 08             	add    $0x8,%esp
  801119:	68 4d 11 80 00       	push   $0x80114d
  80111e:	50                   	push   %eax
  80111f:	e8 e0 fb ff ff       	call   800d04 <sys_env_set_pgfault_upcall>
		cprintf("\twe set_pgfault_upcall done.\n");			
  801124:	c7 04 24 2c 19 80 00 	movl   $0x80192c,(%esp)
  80112b:	e8 f9 f0 ff ff       	call   800229 <cprintf>
  801130:	83 c4 10             	add    $0x10,%esp
	
	}
	cprintf("\twe set _pgfault_handler after this.\n");
  801133:	83 ec 0c             	sub    $0xc,%esp
  801136:	68 c4 18 80 00       	push   $0x8018c4
  80113b:	e8 e9 f0 ff ff       	call   800229 <cprintf>
	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	a3 08 20 80 00       	mov    %eax,0x802008

}
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	c9                   	leave  
  80114c:	c3                   	ret    

0080114d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80114d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80114e:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801153:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801155:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp,    %ebx
  801158:	89 e3                	mov    %esp,%ebx
	movl 40(%esp),%eax
  80115a:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp),%esp
  80115e:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax
  801162:	50                   	push   %eax
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx,   %esp
  801163:	89 dc                	mov    %ebx,%esp
	movl $4,     48(%esp)
  801165:	c7 44 24 30 04 00 00 	movl   $0x4,0x30(%esp)
  80116c:	00 
	popl %eax
  80116d:	58                   	pop    %eax
	popl %eax
  80116e:	58                   	pop    %eax
	popal
  80116f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4,   %esp
  801170:	83 c4 04             	add    $0x4,%esp
	popfl
  801173:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801174:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801175:	c3                   	ret    
  801176:	66 90                	xchg   %ax,%ax
  801178:	66 90                	xchg   %ax,%ax
  80117a:	66 90                	xchg   %ax,%ax
  80117c:	66 90                	xchg   %ax,%ax
  80117e:	66 90                	xchg   %ax,%ax

00801180 <__udivdi3>:
  801180:	55                   	push   %ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 1c             	sub    $0x1c,%esp
  801187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80118b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80118f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801197:	85 f6                	test   %esi,%esi
  801199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80119d:	89 ca                	mov    %ecx,%edx
  80119f:	89 f8                	mov    %edi,%eax
  8011a1:	75 3d                	jne    8011e0 <__udivdi3+0x60>
  8011a3:	39 cf                	cmp    %ecx,%edi
  8011a5:	0f 87 c5 00 00 00    	ja     801270 <__udivdi3+0xf0>
  8011ab:	85 ff                	test   %edi,%edi
  8011ad:	89 fd                	mov    %edi,%ebp
  8011af:	75 0b                	jne    8011bc <__udivdi3+0x3c>
  8011b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b6:	31 d2                	xor    %edx,%edx
  8011b8:	f7 f7                	div    %edi
  8011ba:	89 c5                	mov    %eax,%ebp
  8011bc:	89 c8                	mov    %ecx,%eax
  8011be:	31 d2                	xor    %edx,%edx
  8011c0:	f7 f5                	div    %ebp
  8011c2:	89 c1                	mov    %eax,%ecx
  8011c4:	89 d8                	mov    %ebx,%eax
  8011c6:	89 cf                	mov    %ecx,%edi
  8011c8:	f7 f5                	div    %ebp
  8011ca:	89 c3                	mov    %eax,%ebx
  8011cc:	89 d8                	mov    %ebx,%eax
  8011ce:	89 fa                	mov    %edi,%edx
  8011d0:	83 c4 1c             	add    $0x1c,%esp
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    
  8011d8:	90                   	nop
  8011d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	39 ce                	cmp    %ecx,%esi
  8011e2:	77 74                	ja     801258 <__udivdi3+0xd8>
  8011e4:	0f bd fe             	bsr    %esi,%edi
  8011e7:	83 f7 1f             	xor    $0x1f,%edi
  8011ea:	0f 84 98 00 00 00    	je     801288 <__udivdi3+0x108>
  8011f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8011f5:	89 f9                	mov    %edi,%ecx
  8011f7:	89 c5                	mov    %eax,%ebp
  8011f9:	29 fb                	sub    %edi,%ebx
  8011fb:	d3 e6                	shl    %cl,%esi
  8011fd:	89 d9                	mov    %ebx,%ecx
  8011ff:	d3 ed                	shr    %cl,%ebp
  801201:	89 f9                	mov    %edi,%ecx
  801203:	d3 e0                	shl    %cl,%eax
  801205:	09 ee                	or     %ebp,%esi
  801207:	89 d9                	mov    %ebx,%ecx
  801209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80120d:	89 d5                	mov    %edx,%ebp
  80120f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801213:	d3 ed                	shr    %cl,%ebp
  801215:	89 f9                	mov    %edi,%ecx
  801217:	d3 e2                	shl    %cl,%edx
  801219:	89 d9                	mov    %ebx,%ecx
  80121b:	d3 e8                	shr    %cl,%eax
  80121d:	09 c2                	or     %eax,%edx
  80121f:	89 d0                	mov    %edx,%eax
  801221:	89 ea                	mov    %ebp,%edx
  801223:	f7 f6                	div    %esi
  801225:	89 d5                	mov    %edx,%ebp
  801227:	89 c3                	mov    %eax,%ebx
  801229:	f7 64 24 0c          	mull   0xc(%esp)
  80122d:	39 d5                	cmp    %edx,%ebp
  80122f:	72 10                	jb     801241 <__udivdi3+0xc1>
  801231:	8b 74 24 08          	mov    0x8(%esp),%esi
  801235:	89 f9                	mov    %edi,%ecx
  801237:	d3 e6                	shl    %cl,%esi
  801239:	39 c6                	cmp    %eax,%esi
  80123b:	73 07                	jae    801244 <__udivdi3+0xc4>
  80123d:	39 d5                	cmp    %edx,%ebp
  80123f:	75 03                	jne    801244 <__udivdi3+0xc4>
  801241:	83 eb 01             	sub    $0x1,%ebx
  801244:	31 ff                	xor    %edi,%edi
  801246:	89 d8                	mov    %ebx,%eax
  801248:	89 fa                	mov    %edi,%edx
  80124a:	83 c4 1c             	add    $0x1c,%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5e                   	pop    %esi
  80124f:	5f                   	pop    %edi
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    
  801252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801258:	31 ff                	xor    %edi,%edi
  80125a:	31 db                	xor    %ebx,%ebx
  80125c:	89 d8                	mov    %ebx,%eax
  80125e:	89 fa                	mov    %edi,%edx
  801260:	83 c4 1c             	add    $0x1c,%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    
  801268:	90                   	nop
  801269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801270:	89 d8                	mov    %ebx,%eax
  801272:	f7 f7                	div    %edi
  801274:	31 ff                	xor    %edi,%edi
  801276:	89 c3                	mov    %eax,%ebx
  801278:	89 d8                	mov    %ebx,%eax
  80127a:	89 fa                	mov    %edi,%edx
  80127c:	83 c4 1c             	add    $0x1c,%esp
  80127f:	5b                   	pop    %ebx
  801280:	5e                   	pop    %esi
  801281:	5f                   	pop    %edi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	39 ce                	cmp    %ecx,%esi
  80128a:	72 0c                	jb     801298 <__udivdi3+0x118>
  80128c:	31 db                	xor    %ebx,%ebx
  80128e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801292:	0f 87 34 ff ff ff    	ja     8011cc <__udivdi3+0x4c>
  801298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80129d:	e9 2a ff ff ff       	jmp    8011cc <__udivdi3+0x4c>
  8012a2:	66 90                	xchg   %ax,%ax
  8012a4:	66 90                	xchg   %ax,%ax
  8012a6:	66 90                	xchg   %ax,%ax
  8012a8:	66 90                	xchg   %ax,%ax
  8012aa:	66 90                	xchg   %ax,%ax
  8012ac:	66 90                	xchg   %ax,%ax
  8012ae:	66 90                	xchg   %ax,%ax

008012b0 <__umoddi3>:
  8012b0:	55                   	push   %ebp
  8012b1:	57                   	push   %edi
  8012b2:	56                   	push   %esi
  8012b3:	53                   	push   %ebx
  8012b4:	83 ec 1c             	sub    $0x1c,%esp
  8012b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012c7:	85 d2                	test   %edx,%edx
  8012c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012d1:	89 f3                	mov    %esi,%ebx
  8012d3:	89 3c 24             	mov    %edi,(%esp)
  8012d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012da:	75 1c                	jne    8012f8 <__umoddi3+0x48>
  8012dc:	39 f7                	cmp    %esi,%edi
  8012de:	76 50                	jbe    801330 <__umoddi3+0x80>
  8012e0:	89 c8                	mov    %ecx,%eax
  8012e2:	89 f2                	mov    %esi,%edx
  8012e4:	f7 f7                	div    %edi
  8012e6:	89 d0                	mov    %edx,%eax
  8012e8:	31 d2                	xor    %edx,%edx
  8012ea:	83 c4 1c             	add    $0x1c,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    
  8012f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f8:	39 f2                	cmp    %esi,%edx
  8012fa:	89 d0                	mov    %edx,%eax
  8012fc:	77 52                	ja     801350 <__umoddi3+0xa0>
  8012fe:	0f bd ea             	bsr    %edx,%ebp
  801301:	83 f5 1f             	xor    $0x1f,%ebp
  801304:	75 5a                	jne    801360 <__umoddi3+0xb0>
  801306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80130a:	0f 82 e0 00 00 00    	jb     8013f0 <__umoddi3+0x140>
  801310:	39 0c 24             	cmp    %ecx,(%esp)
  801313:	0f 86 d7 00 00 00    	jbe    8013f0 <__umoddi3+0x140>
  801319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80131d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801321:	83 c4 1c             	add    $0x1c,%esp
  801324:	5b                   	pop    %ebx
  801325:	5e                   	pop    %esi
  801326:	5f                   	pop    %edi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    
  801329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801330:	85 ff                	test   %edi,%edi
  801332:	89 fd                	mov    %edi,%ebp
  801334:	75 0b                	jne    801341 <__umoddi3+0x91>
  801336:	b8 01 00 00 00       	mov    $0x1,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	f7 f7                	div    %edi
  80133f:	89 c5                	mov    %eax,%ebp
  801341:	89 f0                	mov    %esi,%eax
  801343:	31 d2                	xor    %edx,%edx
  801345:	f7 f5                	div    %ebp
  801347:	89 c8                	mov    %ecx,%eax
  801349:	f7 f5                	div    %ebp
  80134b:	89 d0                	mov    %edx,%eax
  80134d:	eb 99                	jmp    8012e8 <__umoddi3+0x38>
  80134f:	90                   	nop
  801350:	89 c8                	mov    %ecx,%eax
  801352:	89 f2                	mov    %esi,%edx
  801354:	83 c4 1c             	add    $0x1c,%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5f                   	pop    %edi
  80135a:	5d                   	pop    %ebp
  80135b:	c3                   	ret    
  80135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801360:	8b 34 24             	mov    (%esp),%esi
  801363:	bf 20 00 00 00       	mov    $0x20,%edi
  801368:	89 e9                	mov    %ebp,%ecx
  80136a:	29 ef                	sub    %ebp,%edi
  80136c:	d3 e0                	shl    %cl,%eax
  80136e:	89 f9                	mov    %edi,%ecx
  801370:	89 f2                	mov    %esi,%edx
  801372:	d3 ea                	shr    %cl,%edx
  801374:	89 e9                	mov    %ebp,%ecx
  801376:	09 c2                	or     %eax,%edx
  801378:	89 d8                	mov    %ebx,%eax
  80137a:	89 14 24             	mov    %edx,(%esp)
  80137d:	89 f2                	mov    %esi,%edx
  80137f:	d3 e2                	shl    %cl,%edx
  801381:	89 f9                	mov    %edi,%ecx
  801383:	89 54 24 04          	mov    %edx,0x4(%esp)
  801387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80138b:	d3 e8                	shr    %cl,%eax
  80138d:	89 e9                	mov    %ebp,%ecx
  80138f:	89 c6                	mov    %eax,%esi
  801391:	d3 e3                	shl    %cl,%ebx
  801393:	89 f9                	mov    %edi,%ecx
  801395:	89 d0                	mov    %edx,%eax
  801397:	d3 e8                	shr    %cl,%eax
  801399:	89 e9                	mov    %ebp,%ecx
  80139b:	09 d8                	or     %ebx,%eax
  80139d:	89 d3                	mov    %edx,%ebx
  80139f:	89 f2                	mov    %esi,%edx
  8013a1:	f7 34 24             	divl   (%esp)
  8013a4:	89 d6                	mov    %edx,%esi
  8013a6:	d3 e3                	shl    %cl,%ebx
  8013a8:	f7 64 24 04          	mull   0x4(%esp)
  8013ac:	39 d6                	cmp    %edx,%esi
  8013ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b2:	89 d1                	mov    %edx,%ecx
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	72 08                	jb     8013c0 <__umoddi3+0x110>
  8013b8:	75 11                	jne    8013cb <__umoddi3+0x11b>
  8013ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013be:	73 0b                	jae    8013cb <__umoddi3+0x11b>
  8013c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013c4:	1b 14 24             	sbb    (%esp),%edx
  8013c7:	89 d1                	mov    %edx,%ecx
  8013c9:	89 c3                	mov    %eax,%ebx
  8013cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013cf:	29 da                	sub    %ebx,%edx
  8013d1:	19 ce                	sbb    %ecx,%esi
  8013d3:	89 f9                	mov    %edi,%ecx
  8013d5:	89 f0                	mov    %esi,%eax
  8013d7:	d3 e0                	shl    %cl,%eax
  8013d9:	89 e9                	mov    %ebp,%ecx
  8013db:	d3 ea                	shr    %cl,%edx
  8013dd:	89 e9                	mov    %ebp,%ecx
  8013df:	d3 ee                	shr    %cl,%esi
  8013e1:	09 d0                	or     %edx,%eax
  8013e3:	89 f2                	mov    %esi,%edx
  8013e5:	83 c4 1c             	add    $0x1c,%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5f                   	pop    %edi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    
  8013ed:	8d 76 00             	lea    0x0(%esi),%esi
  8013f0:	29 f9                	sub    %edi,%ecx
  8013f2:	19 d6                	sbb    %edx,%esi
  8013f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013fc:	e9 18 ff ff ff       	jmp    801319 <__umoddi3+0x69>
