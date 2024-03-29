#include <stdio.h>
#include <string.h>
#include <ctype.h>


//IMPORTANT
//
// Uncomment one of the two #defines below
// Define StartOfExceptionVectorTable as 08030000 if running programs from sram or
// 0B000000 for running programs from dram
//
// In your labs, you will initially start by designing a system with SRam and later move to
// Dram, so these constants will need to be changed based on the version of the system you have
// building
//
// The working 68k system SOF file posted on canvas that you can use for your pre-lab
// is based around Dram so #define accordingly before building

//define StartOfExceptionVectorTable 0x08030000
#define StartOfExceptionVectorTable 0x0B000000

/**********************************************************************************************
**	Parallel port addresses
**********************************************************************************************/

#define PortA   *(volatile unsigned char *)(0x00400000)
#define PortB   *(volatile unsigned char *)(0x00400002)
#define PortC   *(volatile unsigned char *)(0x00400004)
#define PortD   *(volatile unsigned char *)(0x00400006)
#define PortE   *(volatile unsigned char *)(0x00400008)

/*********************************************************************************************
**	Hex 7 seg displays port addresses
*********************************************************************************************/

#define HEX_A        *(volatile unsigned char *)(0x00400010)
#define HEX_B        *(volatile unsigned char *)(0x00400012)
#define HEX_C        *(volatile unsigned char *)(0x00400014)    // de2 only
#define HEX_D        *(volatile unsigned char *)(0x00400016)    // de2 only

/**********************************************************************************************
**	LCD display port addresses
**********************************************************************************************/

#define LCDcommand   *(volatile unsigned char *)(0x00400020)
#define LCDdata      *(volatile unsigned char *)(0x00400022)

/********************************************************************************************
**	Timer Port addresses
*********************************************************************************************/

#define Timer1Data      *(volatile unsigned char *)(0x00400030)
#define Timer1Control   *(volatile unsigned char *)(0x00400032)
#define Timer1Status    *(volatile unsigned char *)(0x00400032)

#define Timer2Data      *(volatile unsigned char *)(0x00400034)
#define Timer2Control   *(volatile unsigned char *)(0x00400036)
#define Timer2Status    *(volatile unsigned char *)(0x00400036)

#define Timer3Data      *(volatile unsigned char *)(0x00400038)
#define Timer3Control   *(volatile unsigned char *)(0x0040003A)
#define Timer3Status    *(volatile unsigned char *)(0x0040003A)

#define Timer4Data      *(volatile unsigned char *)(0x0040003C)
#define Timer4Control   *(volatile unsigned char *)(0x0040003E)
#define Timer4Status    *(volatile unsigned char *)(0x0040003E)

/*********************************************************************************************
**	RS232 port addresses
*********************************************************************************************/

#define RS232_Control     *(volatile unsigned char *)(0x00400040)
#define RS232_Status      *(volatile unsigned char *)(0x00400040)
#define RS232_TxData      *(volatile unsigned char *)(0x00400042)
#define RS232_RxData      *(volatile unsigned char *)(0x00400042)
#define RS232_Baud        *(volatile unsigned char *)(0x00400044)

/*********************************************************************************************
**	PIA 1 and 2 port addresses
*********************************************************************************************/

#define PIA1_PortA_Data     *(volatile unsigned char *)(0x00400050)         // combined data and data direction register share same address
#define PIA1_PortA_Control *(volatile unsigned char *)(0x00400052)
#define PIA1_PortB_Data     *(volatile unsigned char *)(0x00400054)         // combined data and data direction register share same address
#define PIA1_PortB_Control *(volatile unsigned char *)(0x00400056)

#define PIA2_PortA_Data     *(volatile unsigned char *)(0x00400060)         // combined data and data direction register share same address
#define PIA2_PortA_Control *(volatile unsigned char *)(0x00400062)
#define PIA2_PortB_data     *(volatile unsigned char *)(0x00400064)         // combined data and data direction register share same address
#define PIA2_PortB_Control *(volatile unsigned char *)(0x00400066)


/*********************************************************************************************************************************
(( DO NOT initialise global variables here, do it main even if you want 0
(( it's a limitation of the compiler
(( YOU HAVE BEEN WARNED
*********************************************************************************************************************************/

unsigned int i, x, y, z, PortA_Count;
unsigned char Timer1Count, Timer2Count, Timer3Count, Timer4Count ;

/*******************************************************************************************
** Function Prototypes
*******************************************************************************************/
void Wait1ms(void);
void Wait3ms(void);
void Init_LCD(void) ;
void LCDOutchar(int c);
void LCDOutMess(char *theMessage);
void LCDClearln(void);
void LCDline1Message(char *theMessage);
void LCDline2Message(char *theMessage);
int sprintf(char *out, const char *format, ...) ;

/*****************************************************************************************
**	Interrupt service routine for Timers
**
**  Timers 1 - 4 share a common IRQ on the CPU  so this function uses polling to figure
**  out which timer is producing the interrupt
**
*****************************************************************************************/

void Timer_ISR()
{
   	if(Timer1Status == 1) {         // Did Timer 1 produce the Interrupt?
   	    Timer1Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    PortA = Timer1Count++ ;     // increment an LED count on PortA with each tick of Timer 1
   	}

  	if(Timer2Status == 1) {         // Did Timer 2 produce the Interrupt?
   	    Timer2Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
   	    PortC = Timer2Count++ ;     // increment an LED count on PortC with each tick of Timer 2
   	}

   	if(Timer3Status == 1) {         // Did Timer 3 produce the Interrupt?
   	    Timer3Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_A = Timer3Count++ ;     // increment a HEX count on Port HEX_A with each tick of Timer 3
   	}

   	if(Timer4Status == 1) {         // Did Timer 4 produce the Interrupt?
   	    Timer4Control = 3;      	// reset the timer to clear the interrupt, enable interrupts and allow counter to run
        HEX_B = Timer4Count++ ;     // increment a HEX count on HEX_B with each tick of Timer 4
   	}
}

/*****************************************************************************************
**	Interrupt service routine for ACIA. This device has it's own dedicate IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void ACIA_ISR()
{}

/***************************************************************************************
**	Interrupt service routine for PIAs 1 and 2. These devices share an IRQ level
**  Add your code here to poll Status register and clear interrupt
*****************************************************************************************/

void PIA_ISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 2 on DE1 board. Add your own response here
************************************************************************************/
void Key2PressISR()
{}

/***********************************************************************************
**	Interrupt service routine for Key 1 on DE1 board. Add your own response here
************************************************************************************/
void Key1PressISR()
{}

/************************************************************************************
**   Delay Subroutine to give the 68000 something useless to do to waste 1 mSec
************************************************************************************/
void Wait1ms(void)
{
    int  i ;
    for(i = 0; i < 1000; i ++)
        ;
}

/************************************************************************************
**  Subroutine to give the 68000 something useless to do to waste 3 mSec
**************************************************************************************/
void Wait3ms(void)
{
    int i ;
    for(i = 0; i < 3; i++)
        Wait1ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the LCD display by writing some commands to the LCD internal registers
**  Sets it for parallel port and 2 line display mode (if I recall correctly)
*********************************************************************************************/
void Init_LCD(void)
{
    LCDcommand = 0x0c ;
    Wait3ms() ;
    LCDcommand = 0x38 ;
    Wait3ms() ;
}

/*********************************************************************************************
**  Subroutine to initialise the RS232 Port by writing some commands to the internal registers
*********************************************************************************************/
void Init_RS232(void)
{
    RS232_Control = 0x15 ; //  %00010101 set up 6850 uses divide by 16 clock, set RTS low, 8 bits no parity, 1 stop bit, transmitter interrupt disabled
    RS232_Baud = 0x1 ;      // program baud rate generator 001 = 115k, 010 = 57.6k, 011 = 38.4k, 100 = 19.2, all others = 9600
}

/*********************************************************************************************************
**  Subroutine to provide a low level output function to 6850 ACIA
**  This routine provides the basic functionality to output a single character to the serial Port
**  to allow the board to communicate with HyperTerminal Program
**
**  NOTE you do not call this function directly, instead you call the normal putchar() function
**  which in turn calls _putch() below). Other functions like puts(), printf() call putchar() so will
**  call _putch() also
*********************************************************************************************************/

int _putch( int c)
{
    while((RS232_Status & (char)(0x02)) != (char)(0x02))    // wait for Tx bit in status register or 6850 serial comms chip to be '1'
        ;

    RS232_TxData = (c & (char)(0x7f));                      // write to the data register to output the character (mask off bit 8 to keep it 7 bit ASCII)
    return c ;                                              // putchar() expects the character to be returned
}

/*********************************************************************************************************
**  Subroutine to provide a low level input function to 6850 ACIA
**  This routine provides the basic functionality to input a single character from the serial Port
**  to allow the board to communicate with HyperTerminal Program Keyboard (your PC)
**
**  NOTE you do not call this function directly, instead you call the normal getchar() function
**  which in turn calls _getch() below). Other functions like gets(), scanf() call getchar() so will
**  call _getch() also
*********************************************************************************************************/
int _getch( void )
{
    char c ;
    while((RS232_Status & (char)(0x01)) != (char)(0x01))    // wait for Rx bit in 6850 serial comms chip status register to be '1'
        ;

    return (RS232_RxData & (char)(0x7f));                   // read received character, mask off top bit and return as 7 bit ASCII character
}

/******************************************************************************
**  Subroutine to output a single character to the 2 row LCD display
**  It is assumed the character is an ASCII code and it will be displayed at the
**  current cursor position
*******************************************************************************/
void LCDOutchar(int c)
{
    LCDdata = (char)(c);
    Wait1ms() ;
}

/**********************************************************************************
*subroutine to output a message at the current cursor position of the LCD display
************************************************************************************/
void LCDOutMessage(char *theMessage)
{
    char c ;
    while((c = *theMessage++) != 0)     // output characters from the string until NULL
        LCDOutchar(c) ;
}

/******************************************************************************
*subroutine to clear the line by issuing 24 space characters
*******************************************************************************/
void LCDClearln(void)
{
    int i ;
    for(i = 0; i < 24; i ++)
        LCDOutchar(' ') ;       // write a space char to the LCD display
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 1 and clear that line
*******************************************************************************/
void LCDLine1Message(char *theMessage)
{
    LCDcommand = 0x80 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0x80 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/******************************************************************************
**  Subroutine to move the LCD cursor to the start of line 2 and clear that line
*******************************************************************************/
void LCDLine2Message(char *theMessage)
{
    LCDcommand = 0xC0 ;
    Wait3ms();
    LCDClearln() ;
    LCDcommand = 0xC0 ;
    Wait3ms() ;
    LCDOutMessage(theMessage) ;
}

/*********************************************************************************************************************************
**  IMPORTANT FUNCTION
**  This function install an exception handler so you can capture and deal with any 68000 exception in your program
**  You pass it the name of a function in your code that will get called in response to the exception (as the 1st parameter)
**  and in the 2nd parameter, you pass it the exception number that you want to take over (see 68000 exceptions for details)
**  Calling this function allows you to deal with Interrupts for example
***********************************************************************************************************************************/

void InstallExceptionHandler( void (*function_ptr)(), int level)
{
    volatile long int *RamVectorAddress = (volatile long int *)(StartOfExceptionVectorTable) ;   // pointer to the Ram based interrupt vector table created in Cstart in debug monitor

    RamVectorAddress[level] = (long int *)(function_ptr);                       // install the address of our function into the exception table
}

char xtod(int c)
{
    if ((char)(c) <= (char)('9'))
        return c - (char)(0x30);    // 0 - 9 = 0x30 - 0x39 so convert to number by sutracting 0x30
    else if((char)(c) > (char)('F'))    // assume lower case
        return c - (char)(0x57);    // a-f = 0x61-66 so needs to be converted to 0x0A - 0x0F so subtract 0x57
    else
        return c - (char)(0x37);    // A-F = 0x41-46 so needs to be converted to 0x0A - 0x0F so subtract 0x37
}

int Get2HexDigits(char *CheckSumPtr)
{
    register int i = (xtod(_getch()) << 4) | (xtod(_getch()));

    if(CheckSumPtr)
        *CheckSumPtr += i ;

    return i ;
}

int Get4HexDigits(char *CheckSumPtr)
{
    return (Get2HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
}

int Get6HexDigits(char *CheckSumPtr)
{
    return (Get4HexDigits(CheckSumPtr) << 8) | (Get2HexDigits(CheckSumPtr));
}

int Get8HexDigits(char *CheckSumPtr)
{
    return (Get4HexDigits(CheckSumPtr) << 16) | (Get4HexDigits(CheckSumPtr));
}
/*******************************************************************
** I2C Initiallization
********************************************************************/

/*************************************************************
** I2C Controller registers
**************************************************************/
// I2C Registers
#define IIC_Prescale_lo        (*(volatile unsigned char *)(0x00408000))
#define IIC_Prescale_hi        (*(volatile unsigned char *)(0x00408002))
#define IIC_CTR                (*(volatile unsigned char *)(0x00408004))
#define IIC_TXR                (*(volatile unsigned char *)(0x00408006))
#define IIC_RXR                (*(volatile unsigned char *)(0x00408006))
#define IIC_CR                 (*(volatile unsigned char *)(0x00408008))
#define IIC_SR                 (*(volatile unsigned char *)(0x00408008))

#define   Enable_IIC()         IIC_CTR = 0x80
#define   Disable_IIC()        IIC_CTR = 0x00

void IIC_init(){
    Enable_IIC();
    IIC_Prescale_lo = 0x31; //Set SCL to 100KHz
    IIC_Prescale_hi = 0x00;
}

int Check_TX_Complete(){
    //printf("\r\n Status Register: %x", (IIC_SR>>1) & 0x01);
    unsigned int status_reg;
    status_reg = IIC_SR;
    if((status_reg>>1) & 0x01){
        return 0; // transfer in progress
    }
    else{
        return 1; // transfer complete
    }
}

int Check_RX_Complete(){
    //printf("\r\nStatus Register received bit: %x", IIC_SR & 0x01);
    unsigned int status_reg;
    status_reg = IIC_SR;
    if(status_reg & 0x01){
        return 1; // Receive Complete
    }
    else{
        return 0; // Receive not complete
    }
}

void generate_stop(){
    IIC_CR = 0x40;
}

int ACK_Received_from_Slave(){
    unsigned int status_reg;
    int ack_received;
    status_reg = IIC_SR;
    ack_received = ~((status_reg>>7) & 0x01);
    return (ack_received%2);
}

void wait_tx_complete(){
    while(!Check_TX_Complete()){
        //printf("\r\nWaiting for previous transfer to complete");
    }
}

void wait_rx_complete(){
    while(!Check_RX_Complete()){
        //printf("\r\nWaiting to receive data");
    }
}

void Check_stop(){
    unsigned int status_reg;
    status_reg = IIC_SR;
    while(status_reg>>6%2){
        printf("\r\nWaiting for stop signal");
    }
}

void send_write_control_code(int slave_addr, int block_select){ //sends write control code to slave
    int ack_rec;
    ack_rec = 0;
    while(!ack_rec){
        if(slave_addr == 0){ // Write to EEPROM
            if(block_select){ //Write to upper 64k
                IIC_TXR = 0xA2;
            }
            else{ //Write to lower 64k
                IIC_TXR = 0xA0;
            }
        }
        else if(slave_addr == 1){ //Write to DAC
            IIC_TXR = 0x92;
        }
        else{
            printf("\r\nInvalid slave address");
        }
        IIC_CR = 0x91; //Set start condition and indicate write to slave
        //printf("\r\n Transmit Register: %x", IIC_TXR);
        //printf("\r\n Control Register: %x", IIC_CR);
        wait_tx_complete();
        ack_rec = ACK_Received_from_Slave();
    }
}

void send_read_control_code(int slave_addr, int block_select){ //sends read control code to slave
    int ack_rec;
    ack_rec = 0;
    while(!ack_rec){
        if(slave_addr == 0){ // Write to EEPROM
            if(block_select){ //Write to upper 64k
                IIC_TXR = 0xA3;
            }
            else{ //Write to lower 64k
                IIC_TXR = 0xA1;
            }
        }
        else if(slave_addr == 1){
            IIC_TXR = 0x93;
        }
        else{
            printf("\r\nInvalid slave address");
        }
        IIC_CR = 0x91; //Set start condition and indicate write to slave
        //printf("\r\n Transmit Register: %x", IIC_TXR);
        //printf("\r\n Control Register: %x", IIC_CR);
        wait_tx_complete();
        ack_rec = ACK_Received_from_Slave();
    }
}

void WriteData_byte(unsigned int data, unsigned int command){ //sends write data
    int ack_rec;
    ack_rec = 0;
    while(!ack_rec){
        IIC_TXR = data;
        IIC_CR  = command;
        wait_tx_complete();
        ack_rec = ACK_Received_from_Slave();
    }
}

void WriteData_byte_EEPROM(){ //writes a data byte to specified location
    unsigned int address;
    unsigned int address_low;
    unsigned int address_high;
    unsigned int data;
    int block_select;

    printf("\r\nEnter the address you want to write to: ");
    address = Get6HexDigits(0);
    block_select = (address >> 16)%2;
    address_high = (address & 0x00FF00)>>8;
    address_low = address & 0x0000FF;

    printf("\r\nEnter a byte to write: ");
    data = Get2HexDigits(0);

    //printf("\r\nYou entered address: %06x",address);
    //printf("\r\nData to write: %02x", data);

    send_write_control_code(0, block_select);
    //printf("\r\nWriting Address to slave");
    WriteData_byte(address_high, 0x11);
    WriteData_byte(address_low, 0x11);
    //printf("\r\nSending Data to slave");
    WriteData_byte(data, 0x51); // Write a byte and generate stop command
    //Polling for write complete
    //printf("\r\nPolling for write completion....");
    send_write_control_code(0, block_select);
    generate_stop();
    printf("\r\n-----------Write completed-----------");
}

void ReadData_byte_EEPROM(){ //reads a byte from specified location
    unsigned int address;
    unsigned int address_low;
    unsigned int address_high;
    int block_select;
    unsigned int read_data;

    printf("\r\nEnter the address you want to write to: ");
    address = Get6HexDigits(0);
    block_select = (address >> 16)%2;
    address_high = (address & 0x00FF00)>>8;
    address_low = address & 0x0000FF;

    //printf("\r\nYou entered address: %06x",address);

    send_write_control_code(0, block_select);
    //printf("\r\nWriting Address to slave");
    WriteData_byte(address_high, 0x11);
    WriteData_byte(address_low, 0x11);
    send_read_control_code(0, block_select);
    IIC_CR = 0x69;
    //printf("\r\nReading data from slave");
    wait_rx_complete();

    read_data = IIC_RXR;
    printf("\r\nRead Data: %02x", read_data);
}

void write_data_block(start_address, end_address, data){ //writes data between start and end address
    unsigned int range;
    unsigned int address_high;
    unsigned int address_low;
    unsigned int limit;
    unsigned int i;
    unsigned int current_address;
    int block_select;

    block_select = (start_address >> 16)%2;

    for(current_address = start_address; current_address <= end_address; current_address = current_address + 128){
        address_high = (current_address & 0x00FF00)>>8;
        address_low = current_address & 0x0000FF;
        range = end_address - current_address;
        send_write_control_code(0, block_select);
        WriteData_byte(address_high, 0x11);
        WriteData_byte(address_low, 0x11);
        i = 0;
        limit = (range > 127)? 128: range;
        while(i < limit){
            WriteData_byte(data, 0x11);
            i++;
        }
        WriteData_byte(data, 0x51); // Write a byte and generate stop command
        send_write_control_code(0, block_select);
        generate_stop();
    }
}

void read_data_block(start_address, end_address){
    unsigned int address_high;
    unsigned int address_low;
    unsigned int current_address;
    int block_select;
    unsigned int read_data;

    block_select = (start_address >> 16)%2;
    address_high = (current_address & 0x00FF00)>>8;
    address_low = current_address & 0x0000FF;
    current_address = start_address;

    send_write_control_code(0, block_select);
    WriteData_byte(address_high, 0x11);
    WriteData_byte(address_low, 0x11);
    send_read_control_code(0, block_select);
    IIC_CR = 0x29;//read from slave and provide acknowledge. Do not give stop condition
    while(current_address <= end_address){
        wait_rx_complete();
        read_data = IIC_RXR;
        printf("\r\nLocation %06x: %02x", current_address, read_data);
        current_address++;
    }
    generate_stop();
}

void sequential_write(){ //write data between start and end adress
    unsigned int start_address;
    unsigned int end_address;
    int block_select_s;
    int block_select_e;
    unsigned int data;
    unsigned int boundary_address;

    printf("\r\nEnter the start address you want to write to: ");
    start_address = Get6HexDigits(0);

    printf("\r\nEnter the end address you want to write to: ");
    end_address = Get6HexDigits(0);

    printf("\r\nEnter the data you want to write: ");
    data = Get2HexDigits(0);

    block_select_s = (start_address >> 16)%2;
    block_select_e = (end_address >> 16)%2;

    printf("\r\nWriting data.......");
    if(block_select_s == block_select_e){ //belongs to same block therefore no need to worry about boundary condition
        write_data_block(start_address, end_address, data);
    }
    else{
        boundary_address = 0xFFFF;
        write_data_block(start_address, boundary_address, data);
        write_data_block(boundary_address + 1, end_address, data);
    }
    printf("\r\n-----------Write completed-----------");
}

void sequential_read(){
    unsigned int start_address;
    unsigned int end_address;
    int block_select_s;
    int block_select_e;
    unsigned int data;
    unsigned int boundary_address;

    printf("\r\nEnter the start address you want to write to: ");
    start_address = Get6HexDigits(0);

    printf("\r\nEnter the end address you want to write to: ");
    end_address = Get6HexDigits(0);

    block_select_s = (start_address >> 16)%2;
    block_select_e = (end_address >> 16)%2;

    if(block_select_s == block_select_e){ //belongs to same block therefore no need to worry about boundary condition
        read_data_block(start_address, end_address);
    }
    else{
        boundary_address = 0x00ffff;
        read_data_block(start_address, boundary_address);
        read_data_block(boundary_address + 1, end_address);
    }
    printf("\r\n-----------Read completed-----------");
}

void inc_counter(){
    unsigned int counter;
    int i;
    //for(counter = 0; counter < 256; counter++){
    //    for(i = 0; i < 10; i++){
    //        WriteData_byte(counter, 0x11);
    //    }
    //}
    for(i = i; i < 100; i++){
        WriteData_byte(0xFF, 0x11);
    }
}

void dec_counter(){
    unsigned int counter;
    int i;
    for(counter = 255; counter >= 0; counter--){
        for(i = 0; i < 100; i++){
            WriteData_byte(counter, 0x11);
        }
    }
}

void DAC_write(){
    printf("\r\n Running DAC...");
    send_write_control_code(1,0); //initiate the i2c communication with DAC
    WriteData_byte(0x40, 0x11); //control byte
    while(1){
        inc_counter();
        dec_counter();
    }
}

int read_adc_data(){
    int read_data;
    int i = 0;
    //IIC_CR = 0x29;//read from slave and provide acknowledge. Do not give stop condition
    IIC_CR = 0x69;
    wait_rx_complete();
    read_data = IIC_RXR;
    //generate_stop();
    return read_data;
}

void ADC_Read(){
    int read_data;
    int i;
    i = 1;
    while(i < 4){
        send_write_control_code(1,0);
        WriteData_byte(i, 0x11); //control byte
        send_read_control_code(1,0);
        read_data = read_adc_data();
        printf("\r\nChannel %x: %02x", i, read_data);
        i++;
    }
}

void Options(){
    int selection;
    printf("\r\n///////////////////////////////////////////////");
    printf("\r\n1: Read a byte from EEPROM");
    printf("\r\n2: Write a byte to EEPROM");
    printf("\r\n3: Sequential Read");
    printf("\r\n4: Sequential Write");
    printf("\r\n5: DAC Write");
    printf("\r\n6: ADC Read");
    printf("\r\n//////////////////////////////////////////////");
    printf("\r\nEnter your choice: ");
    selection = getchar() - '0';
    if(selection == 1){
       ReadData_byte_EEPROM();
    }
    else if(selection == 2){
        WriteData_byte_EEPROM();
    }
    else if(selection == 3){
        sequential_read();
    }
    else if(selection == 4){
        sequential_write();
    }
    else if(selection == 5){
        DAC_write();
    }
    else if(selection == 6){
        ADC_Read();
    }
    else{
        printf("\r\nPlease enter a valid choice");
    }
}

/******************************************************************************************************************************
* Start of user program
******************************************************************************************************************************/


unsigned char * RamWriter;
unsigned char * start_address;
unsigned char * end_address;
unsigned int test_type;
unsigned int user_data;
unsigned char * current_address;
unsigned char *  intermediate_address;
int address_increment;
int address_length_flag;
unsigned int read_write_test;

void main()
{
    printf("\r\nRunning Demo Program");
    //printf("\r\nInitializing I2C Controller");
    IIC_init();
    //printf("\r\nI2C Controller Initiallized Successfully");
    Options();
}