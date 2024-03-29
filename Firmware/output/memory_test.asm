; C:\USERS\ADMIN\DESKTOP\ASSIGNMENT5\I2C_CONTROLLER_NO_CACHE\FIRMWARE\MEMORY_TEST.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J. Fondse
; #include <stdio.h>
; #include <string.h>
; #include <ctype.h>
; //IMPORTANT
; //
; // Uncomment one of the two #defines below
; // Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
; // 0B000000 for running programs from dram
; //
; // In your labs, you will initially start by designing a system with SRam and later move to
; // Dram, so these constants will need to be changed based on the version of the system you have
; // building
; //
; // The working 68k system SOF file posted on canvas that you can use for your pre-lab
; // is based around Dram so #define accordingly before building
; //define StartOfExceptionVectorTable 0x08030000
; #define StartOfExceptionVectorTable 0x0B000000
; /**********************************************************************************************
; **	Parallel port addresses
; **********************************************************************************************/
; #define PortA   *(volatile unsigned char *)(0x00400000)
; #define PortB   *(volatile unsigned char *)(0x00400002)
; #define PortC   *(volatile unsigned char *)(0x00400004)
; #define PortD   *(volatile unsigned char *)(0x00400006)
; #define PortE   *(volatile unsigned char *)(0x00400008)
; /*********************************************************************************************
; **	Hex 7 seg displays port addresses
; *********************************************************************************************/
; #define HEX_A        *(volatile unsigned char *)(0x00400010)
; #define HEX_B        *(volatile unsigned char *)(0x00400012)
; #define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
; #define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only
; /**********************************************************************************************
; **	LCD display port addresses
; **********************************************************************************************/
; #define LCDcommand   *(volatile unsigned char *)(0x00400020)
; #define LCDdata      *(volatile unsigned char *)(0x00400022)
; /********************************************************************************************
; **	Timer Port addresses
; *********************************************************************************************/
; #define Timer1Data      *(volatile unsigned char *)(0x00400030)
; #define Timer1Control   *(volatile unsigned char *)(0x00400032)
; #define Timer1Status    *(volatile unsigned char *)(0x00400032)
; #define Timer2Data      *(volatile unsigned char *)(0x00400034)
; #define Timer2Control   *(volatile unsigned char *)(0x00400036)
; #define Timer2Status    *(volatile unsigned char *)(0x00400036)
; #define Timer3Data      *(volatile unsigned char *)(0x00400038)
; #define Timer3Control   *(volatile unsigned char *)(0x0040003A)
; #define Timer3Status    *(volatile unsigned char *)(0x0040003A)
; #define Timer4Data      *(volatile unsigned char *)(0x0040003C)
; #define Timer4Control   *(volatile unsigned char *)(0x0040003E)
; #define Timer4Status    *(volatile unsigned char *)(0x0040003E)
; /*********************************************************************************************
; **	RS232 port addresses
; *********************************************************************************************/
; #define RS232_Control     *(volatile unsigned char *)(0x00400040)
; #define RS232_Status      *(volatile unsigned char *)(0x00400040)
; #define RS232_TxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_RxData      *(volatile unsigned char *)(0x00400042)
; #define RS232_Baud        *(volatile unsigned char *)(0x00400044)
; /*********************************************************************************************
; **	PIA 1 and 2 port addresses
; *********************************************************************************************/
; #define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
; #define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
; #define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
; #define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)
; #define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
; #define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
; #define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
; #define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)
; /*********************************************************************************************************************************
; (( DO NOT initialise global variables here, do it main even if you want 0
; (( it's a limitation of the compiler
; (( YOU HAVE BEEN WARNED
; *********************************************************************************************************************************/
; unsigned int i, x, y, z, PortA_Count;
; unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;
; /*******************************************************************************************
; ** Function Prototypes
; *******************************************************************************************/
; void Wait1ms(void);
; void Wait3ms(void);
; void Init_LCD(void) ;
; void LCDOutchar(int c);
; void LCDOutMess(char *theMessage);
; void LCDClearln(void);
; void LCDline1Message(char *theMessage);
; void LCDline2Message(char *theMessage);
; int sprintf(char *out, const char *format, ...) ;
; /*****************************************************************************************
; **	Interrupt service routine for Timers
; **
; **  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
; **  out which timer is producing the interrupt
; **
; *****************************************************************************************/
; void Timer_ISR()
; {
       section   code
       xdef      _Timer_ISR
_Timer_ISR:
; if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
       move.b    4194354,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_1
; Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194354
; PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
       move.b    _Timer1Count.L,D0
       addq.b    #1,_Timer1Count.L
       move.b    D0,4194304
Timer_ISR_1:
; }
; if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
       move.b    4194358,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_3
; Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194358
; PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
       move.b    _Timer2Count.L,D0
       addq.b    #1,_Timer2Count.L
       move.b    D0,4194308
Timer_ISR_3:
; }
; if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
       move.b    4194362,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_5
; Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194362
; HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
       move.b    _Timer3Count.L,D0
       addq.b    #1,_Timer3Count.L
       move.b    D0,4194320
Timer_ISR_5:
; }
; if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
       move.b    4194366,D0
       cmp.b     #1,D0
       bne.s     Timer_ISR_7
; Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
       move.b    #3,4194366
; HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
       move.b    _Timer4Count.L,D0
       addq.b    #1,_Timer4Count.L
       move.b    D0,4194322
Timer_ISR_7:
       rts
; }
; }
; /*****************************************************************************************
; **	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void ACIA_ISR()
; {}
       xdef      _ACIA_ISR
_ACIA_ISR:
       rts
; /***************************************************************************************
; **	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
; **  Add your code here to poll Status register and clear interrupt
; *****************************************************************************************/
; void PIA_ISR()
; {}
       xdef      _PIA_ISR
_PIA_ISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 2 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key2PressISR()
; {}
       xdef      _Key2PressISR
_Key2PressISR:
       rts
; /***********************************************************************************
; **	Interrupt service routine for Key 1 on DE1 board. Add your own response here
; ************************************************************************************/
; void Key1PressISR()
; {}
       xdef      _Key1PressISR
_Key1PressISR:
       rts
; /************************************************************************************
; **   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
; ************************************************************************************/
; void Wait1ms(void)
; {
       xdef      _Wait1ms
_Wait1ms:
       move.l    D2,-(A7)
; int  i ;
; for(i = 0; i < 1000; i ++)
       clr.l     D2
Wait1ms_1:
       cmp.l     #1000,D2
       bge.s     Wait1ms_3
       addq.l    #1,D2
       bra       Wait1ms_1
Wait1ms_3:
       move.l    (A7)+,D2
       rts
; ;
; }
; /************************************************************************************
; **  Subroutine to give the 68000 something useless to do to waste 3 mSec
; **************************************************************************************/
; void Wait3ms(void)
; {
       xdef      _Wait3ms
_Wait3ms:
       move.l    D2,-(A7)
; int i ;
; for(i = 0; i < 3; i++)
       clr.l     D2
Wait3ms_1:
       cmp.l     #3,D2
       bge.s     Wait3ms_3
; Wait1ms() ;
       jsr       _Wait1ms
       addq.l    #1,D2
       bra       Wait3ms_1
Wait3ms_3:
       move.l    (A7)+,D2
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
; **  Sets it for parallel port and 2 line display mode (if I recall correctly)
; *********************************************************************************************/
; void Init_LCD(void)
; {
       xdef      _Init_LCD
_Init_LCD:
; LCDcommand = 0x0c ;
       move.b    #12,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDcommand = 0x38 ;
       move.b    #56,4194336
; Wait3ms() ;
       jsr       _Wait3ms
       rts
; }
; /*********************************************************************************************
; **  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
; *********************************************************************************************/
; void Init_RS232(void)
; {
       xdef      _Init_RS232
_Init_RS232:
; RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
       move.b    #21,4194368
; RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
       move.b    #1,4194372
       rts
; }
; /*********************************************************************************************************
; **  Subroutine to provide a low level output function to 6850 ACIA
; **  This routine provides the basic functionality to output a single character to the serial Port
; **  to allow the board to communicate with HyperTerminal Program
; **
; **  NOTE you do not call this function directly, instead you call the normal putchar() function
; **  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
; **  call _putch() also
; *********************************************************************************************************/
; int _putch( int c)
; {
       xdef      __putch
__putch:
       link      A6,#0
; while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
_putch_1:
       move.b    4194368,D0
       and.b     #2,D0
       cmp.b     #2,D0
       beq.s     _putch_3
       bra       _putch_1
_putch_3:
; ;
; RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
       move.l    8(A6),D0
       and.l     #127,D0
       move.b    D0,4194370
; return c ;                                              // putchar() expects the character to be returned
       move.l    8(A6),D0
       unlk      A6
       rts
; }
; /*********************************************************************************************************
; **  Subroutine to provide a low level input function to 6850 ACIA
; **  This routine provides the basic functionality to input a single character from the serial Port
; **  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
; **
; **  NOTE you do not call this function directly, instead you call the normal getchar() function
; **  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
; **  call _getch() also
; *********************************************************************************************************/
; int _getch( void )
; {
       xdef      __getch
__getch:
       link      A6,#-4
; char c ;
; while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
_getch_1:
       move.b    4194368,D0
       and.b     #1,D0
       cmp.b     #1,D0
       beq.s     _getch_3
       bra       _getch_1
_getch_3:
; ;
; return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
       move.b    4194370,D0
       and.l     #255,D0
       and.l     #127,D0
       unlk      A6
       rts
; }
; /******************************************************************************
; **  Subroutine to output a single character to the 2 row LCD display
; **  It is assumed the character is an ASCII code and it will be displayed at the
; **  current cursor position
; *******************************************************************************/
; void LCDOutchar(int c)
; {
       xdef      _LCDOutchar
_LCDOutchar:
       link      A6,#0
; LCDdata = (char)(c);
       move.l    8(A6),D0
       move.b    D0,4194338
; Wait1ms() ;
       jsr       _Wait1ms
       unlk      A6
       rts
; }
; /**********************************************************************************
; *subroutine to output a message at the current cursor position of the LCD display
; ************************************************************************************/
; void LCDOutMessage(char *theMessage)
; {
       xdef      _LCDOutMessage
_LCDOutMessage:
       link      A6,#-4
; char c ;
; while((c = *theMessage++) != 0)     // output characters from the string until NULL
LCDOutMessage_1:
       move.l    8(A6),A0
       addq.l    #1,8(A6)
       move.b    (A0),-1(A6)
       move.b    (A0),D0
       beq.s     LCDOutMessage_3
; LCDOutchar(c) ;
       move.b    -1(A6),D1
       ext.w     D1
       ext.l     D1
       move.l    D1,-(A7)
       jsr       _LCDOutchar
       addq.w    #4,A7
       bra       LCDOutMessage_1
LCDOutMessage_3:
       unlk      A6
       rts
; }
; /******************************************************************************
; *subroutine to clear the line by issuing 24 space characters
; *******************************************************************************/
; void LCDClearln(void)
; {
       xdef      _LCDClearln
_LCDClearln:
       move.l    D2,-(A7)
; int i ;
; for(i = 0; i < 24; i ++)
       clr.l     D2
LCDClearln_1:
       cmp.l     #24,D2
       bge.s     LCDClearln_3
; LCDOutchar(' ') ;       // write a space char to the LCD display
       pea       32
       jsr       _LCDOutchar
       addq.w    #4,A7
       addq.l    #1,D2
       bra       LCDClearln_1
LCDClearln_3:
       move.l    (A7)+,D2
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 1 and clear that line
; *******************************************************************************/
; void LCDLine1Message(char *theMessage)
; {
       xdef      _LCDLine1Message
_LCDLine1Message:
       link      A6,#0
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0x80 ;
       move.b    #128,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /******************************************************************************
; **  Subroutine to move the LCD cursor to the start of line 2 and clear that line
; *******************************************************************************/
; void LCDLine2Message(char *theMessage)
; {
       xdef      _LCDLine2Message
_LCDLine2Message:
       link      A6,#0
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms();
       jsr       _Wait3ms
; LCDClearln() ;
       jsr       _LCDClearln
; LCDcommand = 0xC0 ;
       move.b    #192,4194336
; Wait3ms() ;
       jsr       _Wait3ms
; LCDOutMessage(theMessage) ;
       move.l    8(A6),-(A7)
       jsr       _LCDOutMessage
       addq.w    #4,A7
       unlk      A6
       rts
; }
; /*********************************************************************************************************************************
; **  IMPORTANT FUNCTION
; **  This function install an exception handler so you can capture and deal with any 68000 exception in your program
; **  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
; **  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
; **  Calling this function allows you to deal with Interrupts for example
; ***********************************************************************************************************************************/
; void InstallExceptionHandler( void (*function_ptr)(), int level)
; {
       xdef      _InstallExceptionHandler
_InstallExceptionHandler:
       link      A6,#-4
; volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor
       move.l    #184549376,-4(A6)
; RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
       move.l    -4(A6),A0
       move.l    12(A6),D0
       lsl.l     #2,D0
       move.l    8(A6),0(A0,D0.L)
       unlk      A6
       rts
; }
; char xtod(int c)
; {
       xdef      _xtod
_xtod:
       link      A6,#0
       move.l    D2,-(A7)
       move.l    8(A6),D2
; if ((char)(c) <= (char)('9'))
       cmp.b     #57,D2
       bgt.s     xtod_1
; return c - (char)(0x30);    // 0 - 9 = 0x30 - 0x39 so convert to number by sutracting 0x30
       move.b    D2,D0
       sub.b     #48,D0
       bra.s     xtod_3
xtod_1:
; else if((char)(c) > (char)('F'))    // assume lower case
       cmp.b     #70,D2
       ble.s     xtod_4
; return c - (char)(0x57);    // a-f = 0x61-66 so needs to be converted to 0x0A - 0x0F so subtract 0x57
       move.b    D2,D0
       sub.b     #87,D0
       bra.s     xtod_3
xtod_4:
; else
; return c - (char)(0x37);    // A-F = 0x41-46 so needs to be converted to 0x0A - 0x0F so subtract 0x37
       move.b    D2,D0
       sub.b     #55,D0
xtod_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; int Get2HexDigits(char *CheckSumPtr)
; {
       xdef      _Get2HexDigits
_Get2HexDigits:
       link      A6,#0
       move.l    D2,-(A7)
; register int i = (xtod(_getch()) << 4) | (xtod(_getch()));
       move.l    D0,-(A7)
       jsr       __getch
       move.l    D0,D1
       move.l    (A7)+,D0
       move.l    D1,-(A7)
       jsr       _xtod
       addq.w    #4,A7
       and.l     #255,D0
       asl.l     #4,D0
       move.l    D0,-(A7)
       move.l    D1,-(A7)
       jsr       __getch
       move.l    (A7)+,D1
       move.l    D0,-(A7)
       jsr       _xtod
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       and.l     #255,D1
       or.l      D1,D0
       move.l    D0,D2
; if(CheckSumPtr)
       tst.l     8(A6)
       beq.s     Get2HexDigits_1
; *CheckSumPtr += i ;
       move.l    8(A6),A0
       add.b     D2,(A0)
Get2HexDigits_1:
; return i ;
       move.l    D2,D0
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; int Get4HexDigits(char *CheckSumPtr)
; {
       xdef      _Get4HexDigits
_Get4HexDigits:
       link      A6,#0
; return (Get2HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; int Get6HexDigits(char *CheckSumPtr)
; {
       xdef      _Get6HexDigits
_Get6HexDigits:
       link      A6,#0
; return (Get4HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; int Get8HexDigits(char *CheckSumPtr)
; {
       xdef      _Get8HexDigits
_Get8HexDigits:
       link      A6,#0
; return (Get4HexDigits(CheckSumPtr) << 16) | (Get4HexDigits(CheckSumPtr));
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       asl.l     #8,D0
       asl.l     #8,D0
       move.l    D0,-(A7)
       move.l    8(A6),-(A7)
       jsr       _Get4HexDigits
       addq.w    #4,A7
       move.l    D0,D1
       move.l    (A7)+,D0
       or.l      D1,D0
       unlk      A6
       rts
; }
; /*******************************************************************
; ** I2C Initiallization
; ********************************************************************/
; /*************************************************************
; ** I2C Controller registers
; **************************************************************/
; // I2C Registers
; #define IIC_Prescale_lo        (*(volatile unsigned char *)(0x00408000))
; #define IIC_Prescale_hi        (*(volatile unsigned char *)(0x00408002))
; #define IIC_CTR                (*(volatile unsigned char *)(0x00408004))
; #define IIC_TXR                (*(volatile unsigned char *)(0x00408006))
; #define IIC_RXR                (*(volatile unsigned char *)(0x00408006))
; #define IIC_CR                 (*(volatile unsigned char *)(0x00408008))
; #define IIC_SR                 (*(volatile unsigned char *)(0x00408008))
; #define   Enable_IIC()         IIC_CTR = 0x80
; #define   Disable_IIC()        IIC_CTR = 0x00
; void IIC_init(){
       xdef      _IIC_init
_IIC_init:
; Enable_IIC();
       move.b    #128,4227076
; IIC_Prescale_lo = 0x31; //Set SCL to 100KHz
       move.b    #49,4227072
; IIC_Prescale_hi = 0x00;
       clr.b     4227074
       rts
; }
; int Check_TX_Complete(){
       xdef      _Check_TX_Complete
_Check_TX_Complete:
       link      A6,#-4
; //printf("\r\n Status Register: %x", (IIC_SR>>1) & 0x01);
; unsigned int status_reg;
; status_reg = IIC_SR;
       move.b    4227080,D0
       and.l     #255,D0
       move.l    D0,-4(A6)
; if((status_reg>>1) & 0x01){
       move.l    -4(A6),D0
       lsr.l     #1,D0
       and.l     #1,D0
       beq.s     Check_TX_Complete_1
; return 0; // transfer in progress
       clr.l     D0
       bra.s     Check_TX_Complete_3
Check_TX_Complete_1:
; }
; else{
; return 1; // transfer complete
       moveq     #1,D0
Check_TX_Complete_3:
       unlk      A6
       rts
; }
; }
; int Check_RX_Complete(){
       xdef      _Check_RX_Complete
_Check_RX_Complete:
       link      A6,#-4
; //printf("\r\nStatus Register received bit: %x", IIC_SR & 0x01);
; unsigned int status_reg;
; status_reg = IIC_SR;
       move.b    4227080,D0
       and.l     #255,D0
       move.l    D0,-4(A6)
; if(status_reg & 0x01){
       move.l    -4(A6),D0
       and.l     #1,D0
       beq.s     Check_RX_Complete_1
; return 1; // Receive Complete
       moveq     #1,D0
       bra.s     Check_RX_Complete_3
Check_RX_Complete_1:
; }
; else{
; return 0; // Receive not complete
       clr.l     D0
Check_RX_Complete_3:
       unlk      A6
       rts
; }
; }
; void generate_stop(){
       xdef      _generate_stop
_generate_stop:
; IIC_CR = 0x40;
       move.b    #64,4227080
       rts
; }
; int ACK_Received_from_Slave(){
       xdef      _ACK_Received_from_Slave
_ACK_Received_from_Slave:
       link      A6,#-8
; unsigned int status_reg;
; int ack_received;
; status_reg = IIC_SR;
       move.b    4227080,D0
       and.l     #255,D0
       move.l    D0,-8(A6)
; ack_received = ~((status_reg>>7) & 0x01);
       move.l    -8(A6),D0
       lsr.l     #7,D0
       and.l     #1,D0
       not.l     D0
       move.l    D0,-4(A6)
; return (ack_received%2);
       move.l    -4(A6),-(A7)
       pea       2
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       unlk      A6
       rts
; }
; void wait_tx_complete(){
       xdef      _wait_tx_complete
_wait_tx_complete:
; while(!Check_TX_Complete()){
wait_tx_complete_1:
       jsr       _Check_TX_Complete
       tst.l     D0
       bne.s     wait_tx_complete_3
; //printf("\r\nWaiting for previous transfer to complete");
; }
       bra       wait_tx_complete_1
wait_tx_complete_3:
       rts
; }
; void wait_rx_complete(){
       xdef      _wait_rx_complete
_wait_rx_complete:
; while(!Check_RX_Complete()){
wait_rx_complete_1:
       jsr       _Check_RX_Complete
       tst.l     D0
       bne.s     wait_rx_complete_3
; //printf("\r\nWaiting to receive data");
; }
       bra       wait_rx_complete_1
wait_rx_complete_3:
       rts
; }
; void Check_stop(){
       xdef      _Check_stop
_Check_stop:
       link      A6,#-4
; unsigned int status_reg;
; status_reg = IIC_SR;
       move.b    4227080,D0
       and.l     #255,D0
       move.l    D0,-4(A6)
; while(status_reg>>6%2){
Check_stop_1:
       move.l    -4(A6),D0
       beq.s     Check_stop_3
; printf("\r\nWaiting for stop signal");
       pea       @memory~1_1.L
       jsr       _printf
       addq.w    #4,A7
       bra       Check_stop_1
Check_stop_3:
       unlk      A6
       rts
; }
; }
; void send_write_control_code(int slave_addr, int block_select){ //sends write control code to slave
       xdef      _send_write_control_code
_send_write_control_code:
       link      A6,#0
       move.l    D2,-(A7)
; int ack_rec;
; ack_rec = 0;
       clr.l     D2
; while(!ack_rec){
send_write_control_code_1:
       tst.l     D2
       bne       send_write_control_code_3
; if(slave_addr == 0){ // Write to EEPROM
       move.l    8(A6),D0
       bne.s     send_write_control_code_4
; if(block_select){ //Write to upper 64k
       tst.l     12(A6)
       beq.s     send_write_control_code_6
; IIC_TXR = 0xA2;
       move.b    #162,4227078
       bra.s     send_write_control_code_7
send_write_control_code_6:
; }
; else{ //Write to lower 64k
; IIC_TXR = 0xA0;
       move.b    #160,4227078
send_write_control_code_7:
       bra.s     send_write_control_code_9
send_write_control_code_4:
; }
; }
; else if(slave_addr == 1){ //Write to DAC
       move.l    8(A6),D0
       cmp.l     #1,D0
       bne.s     send_write_control_code_8
; IIC_TXR = 0x92;
       move.b    #146,4227078
       bra.s     send_write_control_code_9
send_write_control_code_8:
; }
; else{
; printf("\r\nInvalid slave address");
       pea       @memory~1_2.L
       jsr       _printf
       addq.w    #4,A7
send_write_control_code_9:
; }
; IIC_CR = 0x91; //Set start condition and indicate write to slave
       move.b    #145,4227080
; //printf("\r\n Transmit Register: %x", IIC_TXR);
; //printf("\r\n Control Register: %x", IIC_CR);
; wait_tx_complete();
       jsr       _wait_tx_complete
; ack_rec = ACK_Received_from_Slave();
       jsr       _ACK_Received_from_Slave
       move.l    D0,D2
       bra       send_write_control_code_1
send_write_control_code_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; void send_read_control_code(int slave_addr, int block_select){ //sends read control code to slave
       xdef      _send_read_control_code
_send_read_control_code:
       link      A6,#0
       move.l    D2,-(A7)
; int ack_rec;
; ack_rec = 0;
       clr.l     D2
; while(!ack_rec){
send_read_control_code_1:
       tst.l     D2
       bne       send_read_control_code_3
; if(slave_addr == 0){ // Write to EEPROM
       move.l    8(A6),D0
       bne.s     send_read_control_code_4
; if(block_select){ //Write to upper 64k
       tst.l     12(A6)
       beq.s     send_read_control_code_6
; IIC_TXR = 0xA3;
       move.b    #163,4227078
       bra.s     send_read_control_code_7
send_read_control_code_6:
; }
; else{ //Write to lower 64k
; IIC_TXR = 0xA1;
       move.b    #161,4227078
send_read_control_code_7:
       bra.s     send_read_control_code_9
send_read_control_code_4:
; }
; }
; else if(slave_addr == 1){
       move.l    8(A6),D0
       cmp.l     #1,D0
       bne.s     send_read_control_code_8
; IIC_TXR = 0x93;
       move.b    #147,4227078
       bra.s     send_read_control_code_9
send_read_control_code_8:
; }
; else{
; printf("\r\nInvalid slave address");
       pea       @memory~1_3.L
       jsr       _printf
       addq.w    #4,A7
send_read_control_code_9:
; }
; IIC_CR = 0x91; //Set start condition and indicate write to slave
       move.b    #145,4227080
; //printf("\r\n Transmit Register: %x", IIC_TXR);
; //printf("\r\n Control Register: %x", IIC_CR);
; wait_tx_complete();
       jsr       _wait_tx_complete
; ack_rec = ACK_Received_from_Slave();
       jsr       _ACK_Received_from_Slave
       move.l    D0,D2
       bra       send_read_control_code_1
send_read_control_code_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; void WriteData_byte(unsigned int data, unsigned int command){ //sends write data
       xdef      _WriteData_byte
_WriteData_byte:
       link      A6,#0
       move.l    D2,-(A7)
; int ack_rec;
; ack_rec = 0;
       clr.l     D2
; while(!ack_rec){
WriteData_byte_1:
       tst.l     D2
       bne.s     WriteData_byte_3
; IIC_TXR = data;
       move.l    8(A6),D0
       move.b    D0,4227078
; IIC_CR  = command;
       move.l    12(A6),D0
       move.b    D0,4227080
; wait_tx_complete();
       jsr       _wait_tx_complete
; ack_rec = ACK_Received_from_Slave();
       jsr       _ACK_Received_from_Slave
       move.l    D0,D2
       bra       WriteData_byte_1
WriteData_byte_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; void WriteData_byte_EEPROM(){ //writes a data byte to specified location
       xdef      _WriteData_byte_EEPROM
_WriteData_byte_EEPROM:
       link      A6,#-12
       movem.l   D2/D3/A2/A3,-(A7)
       lea       _WriteData_byte.L,A2
       lea       _printf.L,A3
; unsigned int address;
; unsigned int address_low;
; unsigned int address_high;
; unsigned int data;
; int block_select;
; printf("\r\nEnter the address you want to write to: ");
       pea       @memory~1_4.L
       jsr       (A3)
       addq.w    #4,A7
; address = Get6HexDigits(0);
       clr.l     -(A7)
       jsr       _Get6HexDigits
       addq.w    #4,A7
       move.l    D0,D2
; block_select = (address >> 16)%2;
       move.l    D2,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,D3
; address_high = (address & 0x00FF00)>>8;
       move.l    D2,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D0,-8(A6)
; address_low = address & 0x0000FF;
       move.l    D2,D0
       and.l     #255,D0
       move.l    D0,-12(A6)
; printf("\r\nEnter a byte to write: ");
       pea       @memory~1_5.L
       jsr       (A3)
       addq.w    #4,A7
; data = Get2HexDigits(0);
       clr.l     -(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,-4(A6)
; //printf("\r\nYou entered address: %06x",address);
; //printf("\r\nData to write: %02x", data);
; send_write_control_code(0, block_select);
       move.l    D3,-(A7)
       clr.l     -(A7)
       jsr       _send_write_control_code
       addq.w    #8,A7
; //printf("\r\nWriting Address to slave");
; WriteData_byte(address_high, 0x11);
       pea       17
       move.l    -8(A6),-(A7)
       jsr       (A2)
       addq.w    #8,A7
; WriteData_byte(address_low, 0x11);
       pea       17
       move.l    -12(A6),-(A7)
       jsr       (A2)
       addq.w    #8,A7
; //printf("\r\nSending Data to slave");
; WriteData_byte(data, 0x51); // Write a byte and generate stop command
       pea       81
       move.l    -4(A6),-(A7)
       jsr       (A2)
       addq.w    #8,A7
; //Polling for write complete
; //printf("\r\nPolling for write completion....");
; send_write_control_code(0, block_select);
       move.l    D3,-(A7)
       clr.l     -(A7)
       jsr       _send_write_control_code
       addq.w    #8,A7
; generate_stop();
       jsr       _generate_stop
; printf("\r\n-----------Write completed-----------");
       pea       @memory~1_6.L
       jsr       (A3)
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/A2/A3
       unlk      A6
       rts
; }
; void ReadData_byte_EEPROM(){ //reads a byte from specified location
       xdef      _ReadData_byte_EEPROM
_ReadData_byte_EEPROM:
       link      A6,#-12
       movem.l   D2/D3,-(A7)
; unsigned int address;
; unsigned int address_low;
; unsigned int address_high;
; int block_select;
; unsigned int read_data;
; printf("\r\nEnter the address you want to write to: ");
       pea       @memory~1_7.L
       jsr       _printf
       addq.w    #4,A7
; address = Get6HexDigits(0);
       clr.l     -(A7)
       jsr       _Get6HexDigits
       addq.w    #4,A7
       move.l    D0,D2
; block_select = (address >> 16)%2;
       move.l    D2,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,D3
; address_high = (address & 0x00FF00)>>8;
       move.l    D2,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D0,-8(A6)
; address_low = address & 0x0000FF;
       move.l    D2,D0
       and.l     #255,D0
       move.l    D0,-12(A6)
; //printf("\r\nYou entered address: %06x",address);
; send_write_control_code(0, block_select);
       move.l    D3,-(A7)
       clr.l     -(A7)
       jsr       _send_write_control_code
       addq.w    #8,A7
; //printf("\r\nWriting Address to slave");
; WriteData_byte(address_high, 0x11);
       pea       17
       move.l    -8(A6),-(A7)
       jsr       _WriteData_byte
       addq.w    #8,A7
; WriteData_byte(address_low, 0x11);
       pea       17
       move.l    -12(A6),-(A7)
       jsr       _WriteData_byte
       addq.w    #8,A7
; send_read_control_code(0, block_select);
       move.l    D3,-(A7)
       clr.l     -(A7)
       jsr       _send_read_control_code
       addq.w    #8,A7
; IIC_CR = 0x69;
       move.b    #105,4227080
; //printf("\r\nReading data from slave");
; wait_rx_complete();
       jsr       _wait_rx_complete
; read_data = IIC_RXR;
       move.b    4227078,D0
       and.l     #255,D0
       move.l    D0,-4(A6)
; printf("\r\nRead Data: %02x", read_data);
       move.l    -4(A6),-(A7)
       pea       @memory~1_8.L
       jsr       _printf
       addq.w    #8,A7
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; void write_data_block(start_address, end_address, data){ //writes data between start and end address
       xdef      _write_data_block
_write_data_block:
       link      A6,#-12
       movem.l   D2/D3/D4/D5/A2,-(A7)
       lea       _WriteData_byte.L,A2
; unsigned int range;
; unsigned int address_high;
; unsigned int address_low;
; unsigned int limit;
; unsigned int i;
; unsigned int current_address;
; int block_select;
; block_select = (start_address >> 16)%2;
       move.l    8(A6),D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    D0,-(A7)
       pea       2
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,D5
; for(current_address = start_address; current_address <= end_address; current_address = current_address + 128){
       move.l    8(A6),D2
write_data_block_1:
       cmp.l     12(A6),D2
       bhi       write_data_block_3
; address_high = (current_address & 0x00FF00)>>8;
       move.l    D2,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D0,-12(A6)
; address_low = current_address & 0x0000FF;
       move.l    D2,D0
       and.l     #255,D0
       move.l    D0,-8(A6)
; range = end_address - current_address;
       move.l    12(A6),D0
       sub.l     D2,D0
       move.l    D0,D4
; send_write_control_code(0, block_select);
       move.l    D5,-(A7)
       clr.l     -(A7)
       jsr       _send_write_control_code
       addq.w    #8,A7
; WriteData_byte(address_high, 0x11);
       pea       17
       move.l    -12(A6),-(A7)
       jsr       (A2)
       addq.w    #8,A7
; WriteData_byte(address_low, 0x11);
       pea       17
       move.l    -8(A6),-(A7)
       jsr       (A2)
       addq.w    #8,A7
; i = 0;
       clr.l     D3
; limit = (range > 127)? 128: range;
       cmp.l     #127,D4
       bls.s     write_data_block_4
       move.w    #128,D0
       ext.l     D0
       bra.s     write_data_block_5
write_data_block_4:
       move.l    D4,D0
write_data_block_5:
       move.l    D0,-4(A6)
; while(i < limit){
write_data_block_6:
       cmp.l     -4(A6),D3
       bhs.s     write_data_block_8
; WriteData_byte(data, 0x11);
       pea       17
       move.l    16(A6),-(A7)
       jsr       (A2)
       addq.w    #8,A7
; i++;
       addq.l    #1,D3
       bra       write_data_block_6
write_data_block_8:
; }
; WriteData_byte(data, 0x51); // Write a byte and generate stop command
       pea       81
       move.l    16(A6),-(A7)
       jsr       (A2)
       addq.w    #8,A7
; send_write_control_code(0, block_select);
       move.l    D5,-(A7)
       clr.l     -(A7)
       jsr       _send_write_control_code
       addq.w    #8,A7
; generate_stop();
       jsr       _generate_stop
       add.l     #128,D2
       bra       write_data_block_1
write_data_block_3:
       movem.l   (A7)+,D2/D3/D4/D5/A2
       unlk      A6
       rts
; }
; }
; void read_data_block(start_address, end_address){
       xdef      _read_data_block
_read_data_block:
       link      A6,#-12
       movem.l   D2/D3,-(A7)
; unsigned int address_high;
; unsigned int address_low;
; unsigned int current_address;
; int block_select;
; unsigned int read_data;
; block_select = (start_address >> 16)%2;
       move.l    8(A6),D0
       asr.l     #8,D0
       asr.l     #8,D0
       move.l    D0,-(A7)
       pea       2
       jsr       LDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,D3
; address_high = (current_address & 0x00FF00)>>8;
       move.l    D2,D0
       and.l     #65280,D0
       lsr.l     #8,D0
       move.l    D0,-12(A6)
; address_low = current_address & 0x0000FF;
       move.l    D2,D0
       and.l     #255,D0
       move.l    D0,-8(A6)
; current_address = start_address;
       move.l    8(A6),D2
; send_write_control_code(0, block_select);
       move.l    D3,-(A7)
       clr.l     -(A7)
       jsr       _send_write_control_code
       addq.w    #8,A7
; WriteData_byte(address_high, 0x11);
       pea       17
       move.l    -12(A6),-(A7)
       jsr       _WriteData_byte
       addq.w    #8,A7
; WriteData_byte(address_low, 0x11);
       pea       17
       move.l    -8(A6),-(A7)
       jsr       _WriteData_byte
       addq.w    #8,A7
; send_read_control_code(0, block_select);
       move.l    D3,-(A7)
       clr.l     -(A7)
       jsr       _send_read_control_code
       addq.w    #8,A7
; IIC_CR = 0x29;//read from slave and provide acknowledge. Do not give stop condition
       move.b    #41,4227080
; while(current_address <= end_address){
read_data_block_1:
       cmp.l     12(A6),D2
       bhi.s     read_data_block_3
; wait_rx_complete();
       jsr       _wait_rx_complete
; read_data = IIC_RXR;
       move.b    4227078,D0
       and.l     #255,D0
       move.l    D0,-4(A6)
; printf("\r\nLocation %06x: %02x", current_address, read_data);
       move.l    -4(A6),-(A7)
       move.l    D2,-(A7)
       pea       @memory~1_9.L
       jsr       _printf
       add.w     #12,A7
; current_address++;
       addq.l    #1,D2
       bra       read_data_block_1
read_data_block_3:
; }
; generate_stop();
       jsr       _generate_stop
       movem.l   (A7)+,D2/D3
       unlk      A6
       rts
; }
; void sequential_write(){ //write data between start and end adress
       xdef      _sequential_write
_sequential_write:
       link      A6,#-8
       movem.l   D2/D3/D4/D5/A2/A3,-(A7)
       lea       _printf.L,A2
       lea       _write_data_block.L,A3
; unsigned int start_address;
; unsigned int end_address;
; int block_select_s;
; int block_select_e;
; unsigned int data;
; unsigned int boundary_address;
; printf("\r\nEnter the start address you want to write to: ");
       pea       @memory~1_10.L
       jsr       (A2)
       addq.w    #4,A7
; start_address = Get6HexDigits(0);
       clr.l     -(A7)
       jsr       _Get6HexDigits
       addq.w    #4,A7
       move.l    D0,D4
; printf("\r\nEnter the end address you want to write to: ");
       pea       @memory~1_11.L
       jsr       (A2)
       addq.w    #4,A7
; end_address = Get6HexDigits(0);
       clr.l     -(A7)
       jsr       _Get6HexDigits
       addq.w    #4,A7
       move.l    D0,D3
; printf("\r\nEnter the data you want to write: ");
       pea       @memory~1_12.L
       jsr       (A2)
       addq.w    #4,A7
; data = Get2HexDigits(0);
       clr.l     -(A7)
       jsr       _Get2HexDigits
       addq.w    #4,A7
       move.l    D0,D2
; block_select_s = (start_address >> 16)%2;
       move.l    D4,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,-8(A6)
; block_select_e = (end_address >> 16)%2;
       move.l    D3,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,-4(A6)
; printf("\r\nWriting data.......");
       pea       @memory~1_13.L
       jsr       (A2)
       addq.w    #4,A7
; if(block_select_s == block_select_e){ //belongs to same block therefore no need to worry about boundary condition
       move.l    -8(A6),D0
       cmp.l     -4(A6),D0
       bne.s     sequential_write_1
; write_data_block(start_address, end_address, data);
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       move.l    D4,-(A7)
       jsr       (A3)
       add.w     #12,A7
       bra.s     sequential_write_2
sequential_write_1:
; }
; else{
; boundary_address = 0xFFFF;
       move.l    #65535,D5
; write_data_block(start_address, boundary_address, data);
       move.l    D2,-(A7)
       move.l    D5,-(A7)
       move.l    D4,-(A7)
       jsr       (A3)
       add.w     #12,A7
; write_data_block(boundary_address + 1, end_address, data);
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       move.l    D5,D1
       addq.l    #1,D1
       move.l    D1,-(A7)
       jsr       (A3)
       add.w     #12,A7
sequential_write_2:
; }
; printf("\r\n-----------Write completed-----------");
       pea       @memory~1_14.L
       jsr       (A2)
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/D4/D5/A2/A3
       unlk      A6
       rts
; }
; void sequential_read(){
       xdef      _sequential_read
_sequential_read:
       link      A6,#-12
       movem.l   D2/D3/D4/A2/A3,-(A7)
       lea       _read_data_block.L,A2
       lea       _printf.L,A3
; unsigned int start_address;
; unsigned int end_address;
; int block_select_s;
; int block_select_e;
; unsigned int data;
; unsigned int boundary_address;
; printf("\r\nEnter the start address you want to write to: ");
       pea       @memory~1_15.L
       jsr       (A3)
       addq.w    #4,A7
; start_address = Get6HexDigits(0);
       clr.l     -(A7)
       jsr       _Get6HexDigits
       addq.w    #4,A7
       move.l    D0,D3
; printf("\r\nEnter the end address you want to write to: ");
       pea       @memory~1_16.L
       jsr       (A3)
       addq.w    #4,A7
; end_address = Get6HexDigits(0);
       clr.l     -(A7)
       jsr       _Get6HexDigits
       addq.w    #4,A7
       move.l    D0,D2
; block_select_s = (start_address >> 16)%2;
       move.l    D3,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,-12(A6)
; block_select_e = (end_address >> 16)%2;
       move.l    D2,D0
       lsr.l     #8,D0
       lsr.l     #8,D0
       move.l    D0,-(A7)
       pea       2
       jsr       ULDIV
       move.l    4(A7),D0
       addq.w    #8,A7
       move.l    D0,-8(A6)
; if(block_select_s == block_select_e){ //belongs to same block therefore no need to worry about boundary condition
       move.l    -12(A6),D0
       cmp.l     -8(A6),D0
       bne.s     sequential_read_1
; read_data_block(start_address, end_address);
       move.l    D2,-(A7)
       move.l    D3,-(A7)
       jsr       (A2)
       addq.w    #8,A7
       bra.s     sequential_read_2
sequential_read_1:
; }
; else{
; boundary_address = 0x00ffff;
       move.l    #65535,D4
; read_data_block(start_address, boundary_address);
       move.l    D4,-(A7)
       move.l    D3,-(A7)
       jsr       (A2)
       addq.w    #8,A7
; read_data_block(boundary_address + 1, end_address);
       move.l    D2,-(A7)
       move.l    D4,D1
       addq.l    #1,D1
       move.l    D1,-(A7)
       jsr       (A2)
       addq.w    #8,A7
sequential_read_2:
; }
; printf("\r\n-----------Read completed-----------");
       pea       @memory~1_17.L
       jsr       (A3)
       addq.w    #4,A7
       movem.l   (A7)+,D2/D3/D4/A2/A3
       unlk      A6
       rts
; }
; void inc_counter(){
       xdef      _inc_counter
_inc_counter:
       link      A6,#-4
       move.l    D2,-(A7)
; unsigned int counter;
; int i;
; //for(counter = 0; counter < 256; counter++){
; //    for(i = 0; i < 10; i++){
; //        WriteData_byte(counter, 0x11);
; //    }
; //}
; for(i = i; i < 100; i++){
inc_counter_1:
       cmp.l     #100,D2
       bge.s     inc_counter_3
; WriteData_byte(0xFF, 0x11);
       pea       17
       pea       255
       jsr       _WriteData_byte
       addq.w    #8,A7
       addq.l    #1,D2
       bra       inc_counter_1
inc_counter_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; void dec_counter(){
       xdef      _dec_counter
_dec_counter:
       movem.l   D2/D3,-(A7)
; unsigned int counter;
; int i;
; for(counter = 255; counter >= 0; counter--){
       move.l    #255,D2
dec_counter_1:
       cmp.l     #0,D2
       blo.s     dec_counter_3
; for(i = 0; i < 100; i++){
       clr.l     D3
dec_counter_4:
       cmp.l     #100,D3
       bge.s     dec_counter_6
; WriteData_byte(counter, 0x11);
       pea       17
       move.l    D2,-(A7)
       jsr       _WriteData_byte
       addq.w    #8,A7
       addq.l    #1,D3
       bra       dec_counter_4
dec_counter_6:
       subq.l    #1,D2
       bra       dec_counter_1
dec_counter_3:
       movem.l   (A7)+,D2/D3
       rts
; }
; }
; }
; void DAC_write(){
       xdef      _DAC_write
_DAC_write:
; printf("\r\n Running DAC...");
       pea       @memory~1_18.L
       jsr       _printf
       addq.w    #4,A7
; send_write_control_code(1,0); //initiate the i2c communication with DAC
       clr.l     -(A7)
       pea       1
       jsr       _send_write_control_code
       addq.w    #8,A7
; WriteData_byte(0x40, 0x11); //control byte
       pea       17
       pea       64
       jsr       _WriteData_byte
       addq.w    #8,A7
; while(1){
DAC_write_1:
; inc_counter();
       jsr       _inc_counter
; dec_counter();
       jsr       _dec_counter
       bra       DAC_write_1
; }
; }
; int read_adc_data(){
       xdef      _read_adc_data
_read_adc_data:
       link      A6,#-8
; int read_data;
; int i = 0;
       clr.l     -4(A6)
; //IIC_CR = 0x29;//read from slave and provide acknowledge. Do not give stop condition
; IIC_CR = 0x69;
       move.b    #105,4227080
; wait_rx_complete();
       jsr       _wait_rx_complete
; read_data = IIC_RXR;
       move.b    4227078,D0
       and.l     #255,D0
       move.l    D0,-8(A6)
; //generate_stop();
; return read_data;
       move.l    -8(A6),D0
       unlk      A6
       rts
; }
; void ADC_Read(){
       xdef      _ADC_Read
_ADC_Read:
       link      A6,#-4
       move.l    D2,-(A7)
; int read_data;
; int i;
; i = 1;
       moveq     #1,D2
; while(i < 4){
ADC_Read_1:
       cmp.l     #4,D2
       bge       ADC_Read_3
; send_write_control_code(1,0);
       clr.l     -(A7)
       pea       1
       jsr       _send_write_control_code
       addq.w    #8,A7
; WriteData_byte(i, 0x11); //control byte
       pea       17
       move.l    D2,-(A7)
       jsr       _WriteData_byte
       addq.w    #8,A7
; send_read_control_code(1,0);
       clr.l     -(A7)
       pea       1
       jsr       _send_read_control_code
       addq.w    #8,A7
; read_data = read_adc_data();
       jsr       _read_adc_data
       move.l    D0,-4(A6)
; printf("\r\nChannel %x: %02x", i, read_data);
       move.l    -4(A6),-(A7)
       move.l    D2,-(A7)
       pea       @memory~1_19.L
       jsr       _printf
       add.w     #12,A7
; i++;
       addq.l    #1,D2
       bra       ADC_Read_1
ADC_Read_3:
       move.l    (A7)+,D2
       unlk      A6
       rts
; }
; }
; void Options(){
       xdef      _Options
_Options:
       movem.l   D2/A2,-(A7)
       lea       _printf.L,A2
; int selection;
; printf("\r\n///////////////////////////////////////////////");
       pea       @memory~1_20.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n1: Read a byte from EEPROM");
       pea       @memory~1_21.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n2: Write a byte to EEPROM");
       pea       @memory~1_22.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n3: Sequential Read");
       pea       @memory~1_23.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n4: Sequential Write");
       pea       @memory~1_24.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n5: DAC Write");
       pea       @memory~1_25.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n6: ADC Read");
       pea       @memory~1_26.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\n//////////////////////////////////////////////");
       pea       @memory~1_27.L
       jsr       (A2)
       addq.w    #4,A7
; printf("\r\nEnter your choice: ");
       pea       @memory~1_28.L
       jsr       (A2)
       addq.w    #4,A7
; selection = getchar() - '0';
       jsr       _getch
       sub.l     #48,D0
       move.l    D0,D2
; if(selection == 1){
       cmp.l     #1,D2
       bne.s     Options_1
; ReadData_byte_EEPROM();
       jsr       _ReadData_byte_EEPROM
       bra       Options_12
Options_1:
; }
; else if(selection == 2){
       cmp.l     #2,D2
       bne.s     Options_3
; WriteData_byte_EEPROM();
       jsr       _WriteData_byte_EEPROM
       bra       Options_12
Options_3:
; }
; else if(selection == 3){
       cmp.l     #3,D2
       bne.s     Options_5
; sequential_read();
       jsr       _sequential_read
       bra.s     Options_12
Options_5:
; }
; else if(selection == 4){
       cmp.l     #4,D2
       bne.s     Options_7
; sequential_write();
       jsr       _sequential_write
       bra.s     Options_12
Options_7:
; }
; else if(selection == 5){
       cmp.l     #5,D2
       bne.s     Options_9
; DAC_write();
       jsr       _DAC_write
       bra.s     Options_12
Options_9:
; }
; else if(selection == 6){
       cmp.l     #6,D2
       bne.s     Options_11
; ADC_Read();
       jsr       _ADC_Read
       bra.s     Options_12
Options_11:
; }
; else{
; printf("\r\nPlease enter a valid choice");
       pea       @memory~1_29.L
       jsr       (A2)
       addq.w    #4,A7
Options_12:
       movem.l   (A7)+,D2/A2
       rts
; }
; }
; /******************************************************************************************************************************
; * Start of user program
; ******************************************************************************************************************************/
; unsigned char * RamWriter;
; unsigned char * start_address;
; unsigned char * end_address;
; unsigned int test_type;
; unsigned int user_data;
; unsigned char * current_address;
; unsigned char *  intermediate_address;
; int address_increment;
; int address_length_flag;
; unsigned int read_write_test;
; void main()
; {
       xdef      _main
_main:
; printf("\r\nRunning Demo Program");
       pea       @memory~1_30.L
       jsr       _printf
       addq.w    #4,A7
; //printf("\r\nInitializing I2C Controller");
; IIC_init();
       jsr       _IIC_init
; //printf("\r\nI2C Controller Initiallized Successfully");
; Options();
       jsr       _Options
       rts
; }
       section   const
@memory~1_1:
       dc.b      13,10,87,97,105,116,105,110,103,32,102,111,114
       dc.b      32,115,116,111,112,32,115,105,103,110,97,108
       dc.b      0
@memory~1_2:
       dc.b      13,10,73,110,118,97,108,105,100,32,115,108,97
       dc.b      118,101,32,97,100,100,114,101,115,115,0
@memory~1_3:
       dc.b      13,10,73,110,118,97,108,105,100,32,115,108,97
       dc.b      118,101,32,97,100,100,114,101,115,115,0
@memory~1_4:
       dc.b      13,10,69,110,116,101,114,32,116,104,101,32,97
       dc.b      100,100,114,101,115,115,32,121,111,117,32,119
       dc.b      97,110,116,32,116,111,32,119,114,105,116,101
       dc.b      32,116,111,58,32,0
@memory~1_5:
       dc.b      13,10,69,110,116,101,114,32,97,32,98,121,116
       dc.b      101,32,116,111,32,119,114,105,116,101,58,32
       dc.b      0
@memory~1_6:
       dc.b      13,10,45,45,45,45,45,45,45,45,45,45,45,87,114
       dc.b      105,116,101,32,99,111,109,112,108,101,116,101
       dc.b      100,45,45,45,45,45,45,45,45,45,45,45,0
@memory~1_7:
       dc.b      13,10,69,110,116,101,114,32,116,104,101,32,97
       dc.b      100,100,114,101,115,115,32,121,111,117,32,119
       dc.b      97,110,116,32,116,111,32,119,114,105,116,101
       dc.b      32,116,111,58,32,0
@memory~1_8:
       dc.b      13,10,82,101,97,100,32,68,97,116,97,58,32,37
       dc.b      48,50,120,0
@memory~1_9:
       dc.b      13,10,76,111,99,97,116,105,111,110,32,37,48
       dc.b      54,120,58,32,37,48,50,120,0
@memory~1_10:
       dc.b      13,10,69,110,116,101,114,32,116,104,101,32,115
       dc.b      116,97,114,116,32,97,100,100,114,101,115,115
       dc.b      32,121,111,117,32,119,97,110,116,32,116,111
       dc.b      32,119,114,105,116,101,32,116,111,58,32,0
@memory~1_11:
       dc.b      13,10,69,110,116,101,114,32,116,104,101,32,101
       dc.b      110,100,32,97,100,100,114,101,115,115,32,121
       dc.b      111,117,32,119,97,110,116,32,116,111,32,119
       dc.b      114,105,116,101,32,116,111,58,32,0
@memory~1_12:
       dc.b      13,10,69,110,116,101,114,32,116,104,101,32,100
       dc.b      97,116,97,32,121,111,117,32,119,97,110,116,32
       dc.b      116,111,32,119,114,105,116,101,58,32,0
@memory~1_13:
       dc.b      13,10,87,114,105,116,105,110,103,32,100,97,116
       dc.b      97,46,46,46,46,46,46,46,0
@memory~1_14:
       dc.b      13,10,45,45,45,45,45,45,45,45,45,45,45,87,114
       dc.b      105,116,101,32,99,111,109,112,108,101,116,101
       dc.b      100,45,45,45,45,45,45,45,45,45,45,45,0
@memory~1_15:
       dc.b      13,10,69,110,116,101,114,32,116,104,101,32,115
       dc.b      116,97,114,116,32,97,100,100,114,101,115,115
       dc.b      32,121,111,117,32,119,97,110,116,32,116,111
       dc.b      32,119,114,105,116,101,32,116,111,58,32,0
@memory~1_16:
       dc.b      13,10,69,110,116,101,114,32,116,104,101,32,101
       dc.b      110,100,32,97,100,100,114,101,115,115,32,121
       dc.b      111,117,32,119,97,110,116,32,116,111,32,119
       dc.b      114,105,116,101,32,116,111,58,32,0
@memory~1_17:
       dc.b      13,10,45,45,45,45,45,45,45,45,45,45,45,82,101
       dc.b      97,100,32,99,111,109,112,108,101,116,101,100
       dc.b      45,45,45,45,45,45,45,45,45,45,45,0
@memory~1_18:
       dc.b      13,10,32,82,117,110,110,105,110,103,32,68,65
       dc.b      67,46,46,46,0
@memory~1_19:
       dc.b      13,10,67,104,97,110,110,101,108,32,37,120,58
       dc.b      32,37,48,50,120,0
@memory~1_20:
       dc.b      13,10,47,47,47,47,47,47,47,47,47,47,47,47,47
       dc.b      47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
       dc.b      47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
       dc.b      47,47,47,47,0
@memory~1_21:
       dc.b      13,10,49,58,32,82,101,97,100,32,97,32,98,121
       dc.b      116,101,32,102,114,111,109,32,69,69,80,82,79
       dc.b      77,0
@memory~1_22:
       dc.b      13,10,50,58,32,87,114,105,116,101,32,97,32,98
       dc.b      121,116,101,32,116,111,32,69,69,80,82,79,77
       dc.b      0
@memory~1_23:
       dc.b      13,10,51,58,32,83,101,113,117,101,110,116,105
       dc.b      97,108,32,82,101,97,100,0
@memory~1_24:
       dc.b      13,10,52,58,32,83,101,113,117,101,110,116,105
       dc.b      97,108,32,87,114,105,116,101,0
@memory~1_25:
       dc.b      13,10,53,58,32,68,65,67,32,87,114,105,116,101
       dc.b      0
@memory~1_26:
       dc.b      13,10,54,58,32,65,68,67,32,82,101,97,100,0
@memory~1_27:
       dc.b      13,10,47,47,47,47,47,47,47,47,47,47,47,47,47
       dc.b      47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
       dc.b      47,47,47,47,47,47,47,47,47,47,47,47,47,47,47
       dc.b      47,47,47,0
@memory~1_28:
       dc.b      13,10,69,110,116,101,114,32,121,111,117,114
       dc.b      32,99,104,111,105,99,101,58,32,0
@memory~1_29:
       dc.b      13,10,80,108,101,97,115,101,32,101,110,116,101
       dc.b      114,32,97,32,118,97,108,105,100,32,99,104,111
       dc.b      105,99,101,0
@memory~1_30:
       dc.b      13,10,82,117,110,110,105,110,103,32,68,101,109
       dc.b      111,32,80,114,111,103,114,97,109,0
       section   bss
       xdef      _i
_i:
       ds.b      4
       xdef      _x
_x:
       ds.b      4
       xdef      _y
_y:
       ds.b      4
       xdef      _z
_z:
       ds.b      4
       xdef      _PortA_Count
_PortA_Count:
       ds.b      4
       xdef      _Timer1Count
_Timer1Count:
       ds.b      1
       xdef      _Timer2Count
_Timer2Count:
       ds.b      1
       xdef      _Timer3Count
_Timer3Count:
       ds.b      1
       xdef      _Timer4Count
_Timer4Count:
       ds.b      1
       xdef      _RamWriter
_RamWriter:
       ds.b      4
       xdef      _start_address
_start_address:
       ds.b      4
       xdef      _end_address
_end_address:
       ds.b      4
       xdef      _test_type
_test_type:
       ds.b      4
       xdef      _user_data
_user_data:
       ds.b      4
       xdef      _current_address
_current_address:
       ds.b      4
       xdef      _intermediate_address
_intermediate_address:
       ds.b      4
       xdef      _address_increment
_address_increment:
       ds.b      4
       xdef      _address_length_flag
_address_length_flag:
       ds.b      4
       xdef      _read_write_test
_read_write_test:
       ds.b      4
       xref      LDIV
       xref      _getch
       xref      ULDIV
       xref      _printf
