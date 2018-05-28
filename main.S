/*
 * main.S - ECE 540 project #1 starter code for microAptiv_UP MIPS core
 * running on Nexys4 DDR FPGA target board
 *
 * Copyright Rahul, Kiyasul, 2018
 * 
 * Created By:		Rahul, Kiyasul
 * Last Modified:	25-Jan-2017 (R.M,K.A)
 *
 * Description:
 * Reads the switches on the FPGA board and writes
 * the values to the LEDs and the seven segment display
 *
 * Assumes the existance of an AHB-Lite peripheral for the 8 digit
 * 7-segment display on the Nexys4 DDR.  The peripheral has 4 memory
 * mapped I/O registers:
 *	PORT_SEVENSEG_EN - (8 bits) Individual enables for each digit. Set bit to 0 to enable digit
 *									Digit7 = bit[7], Digit6 = bit[6], Digit5 = bit[5], Digit4 = bit[4],
 *									Digit3 = bit[3], Digit2 = bit[2], Digit1 = bit[1], Digit0 = bit[0]
 *	PORT_SEVENSEG_HGH = (32 bits) Value of digit.  Each digit has the range of 31:0, top 3 bits ignored
 *									Digit7 = bits[31:24], Digit6 = bits[23:16],
 *									Digit5 = bits[15:8] , Digit4 = bits[7:0]
 *	PORT_SEVENSEG_LOW = (32 bits) Value of digit.  Each digit has the range of 31:0, top 3 bits ignored
 *									Digit3 = bits[31:24], Digit2 = bits[23:16],
 *									Digit1 = bits[15:8] , Digit0 = bits[7:0]
 *	PORT_SEVENSEG_DP - (8 bits) Individual decimal points for each digit. Set bit to 0 to turn on the decimal point
 *									DP7 = bit[7], DP6 = bit[6], DP5 = bit[5], DP4 = bit[4],
 *									DP3 = bit[3], DP2 = bit[2], DP1 = bit[1], DP0 = bit[0]
 */



PORT_SEVENSEG_EN 	= 0xbf700000		# (o) 7 Segment enable
PORT_SEVENSEG_HGH	= 0xbf700004		# (o) 7 Segment Higher Display
PORT_SEVENSEG_LOW	= 0xbf700008		# (o) 7 Segment Lower Display
PORT_SEVENSEG_DP	= 0xbf70000C		# (o) 7 segment Decimal Point Display
PORT_PUSHBUTTON     = 0xbf800008        # (o) Pushbutton

                                        # Motion                    || COMPASS

DEFAULT_STOP  = 0x00      				# Segment g Steady 	        || NO CHANGE
RIGHT = 0x01      		  				# Left at 5hz 			 	|| DECREMENT At 5Hz
LEFT =  0x04       		  				# Right at 5hz 				|| INCREMENT At 5Hz
DOWN = 0x08        						# Right at 5hz 				|| INCREMENT At 5Hz
UP   = 0x10        						# Left at 5hz 				|| DECREMENT At 5HZ
RL   = 0x05        						# Segment A Forward at 1hz 	|| NO CHANGE
RU   = 0x11        						# Left at 10hz 				|| DECREMENT At 10Hz
RD   = 0x09        						# Segment g Steady 			|| NO CHANGE
LU   = 0x14        						# Segment g Steady 			|| NO CHANGE
LD   = 0x0C        						# Right at 10hz 			|| INCREMENT At 10Hz
LUD  = 0x1C        						# Right at 5hz 				|| INCREMENT At 10Hz
LRD  = 0x0D        						# Right at 5hz 				|| INCREMENT At 10Hz
LUR  = 0x15        						# Left at 5hz 				|| DECREMENT At 10Hz
RUD  = 0x19        						# Left at 5hz 				|| DECREMENT At 10Hz
URLD  =0x1D        						# Segment Steady 			|| NO CHANGE
UD   = 0x18        						# Reverse 					|| NO CHANGE
CENTER = 0x02      						# Center 					|| NO CHANGE

.globl main
main:
   li    $20, PORT_PUSHBUTTON           # $20 = address of the pushbutton
   li    $9,  PORT_SEVENSEG_EN			# $9  = address of the 7 segment enable
   li 	 $10, PORT_SEVENSEG_HGH			# $10 = address of the higher 7 segment digits
   li 	 $16, PORT_SEVENSEG_LOW			# $16 = address of the lower 7 segment digits
   li 	 $12, PORT_SEVENSEG_DP			# $12 = address of the dp points in 7 segment digits

READIO:
	li  $11, 0x00000000                 # Initialize $11 to 0x00
	sw  $11, 0($16)                     # Write 0.000 to Lower Seven Segments
	li  $11, 0x00                       # Writing the values to enable the segments
	sw  $11, 0($9)						# Enabling the low segments by writing the values 0
	li  $11, 0xFFFFFFFF                 # Double-Check mask the upper 4 7 segments
	sw  $11, 0($10)						# Write value to upper 7segmnet
	li  $11, 0x16000000                 # Value equivalent to g
	sw  $11, 0($16)						# Values pushed to leds stack
	li  $13,0x00000000                  # BCD counter status value
	li  $4, 0x00000000                  # Delay loop
	li  $5, 0x00000000                  # Delay loop
	li  $6, 0x00000000                  # Temp init
	li $17, 0xf7						# Enable the 4th Decimal Point
    sw $17, 0($12)                      # Write value to DP
    and $17, $17, 0x00000000            # Re-initialize

LOGIC:
    lw  $11, 0($20)                     # Pushbuttons Value Read and Stored into $11
    and $4, $11, 0xFFFFFFFF             # Storing the value of pushbuttons to $4
	and $11, $11, 0x00000000            # Re-initialize $11 to 0x00
    beq $4, DEFAULT_STOP,STOP           # If No Button is Pressed Branch to STOP
    beq $4, RIGHT, ANTICLOCKWISEAT5		# Check if only RIGHT Button is pressed,if True branch
    beq $4, LEFT, CLOCKWISEAT5			# Check if only LEFT Button is Pressed,if True branch
    beq $4, UP, ANTICLOCKWISEAT5        # Check if only UP Button is pressed,if True branch
    beq $4, DOWN, CLOCKWISEAT5			# Check if only DOWN Button is pressed,if True branch
    beq $4, RL, FORWARD					# Check if RIGHT AND UP LEFT Buttons are pressed,if True branch
    beq $4, RU, ANTICLOCKWISEAT10		# Check if RIGHT AND UP Buttons are pressed,if True branch
    beq $4, RD, STOP					# Check if RIGHT AND DOWN Buttons are pressed,if True branch
    beq $4, LU, STOP					# Check if LEFT  AND UP Buttons are pressed,if True branch
    beq $4, LD, CLOCKWISEAT10			# Check if LEFT  AND DOWN Button is pressed,if True branch
    beq $4, LUD, CLOCKWISEAT5			# Check if LEFT, UP AND DOWN Buttons are pressed,if True branch
    beq $4, LRD, CLOCKWISEAT5			# Check if LEFT, RIGHT AND DOWN are pressed,if True branch
    beq $4, LUR, ANTICLOCKWISEAT5		# Check if LEFT, UP AND RIGHT are pressed,if True branch
    beq $4, RUD, ANTICLOCKWISEAT5		# Check if RIGHT,UP AND DOWN are pressed,if True branch
    beq $4, URLD, STOP					# Check if UP,RIGHT,LEFT AND DOWN are pressed,if True branch
    beq $4, UD, REVERSE					# Check if UP AND DOWN are pressed,if True branch
    li  $4, CENTER						# IF NONE ARE Pressed, Loading a constant value
    beq $4, CENTER, DEFAULT             # Beq DEFUALT
    j EXIT                              # Does not reach this statement : Debug purposes

INTEGRATE:
    addi $23, $13, 0                    # Making a copy of the global counter value
    and $19, $23, 0x0000000F    		# Segregate out ones digit for displaying
    and $21, $23, 0x000000F0    		# Segregate out tens digit for displaying
    sll $21, $21, 4						# Shift tens place to the left by two places
    and $22, $23, 0x00000F00    		# Segregate out hundreds digit for displaying
    sll $22, $22, 8					    # Shift for moving to the Hundreds Place(4 Places)
    or  $6, $19, $21				    # OR Value of LSB and Digits in 10s place
    or  $6, $6, $22                     # OR Value of Value obtained to the MSB(Hundreds Place)
    ////////////////////// DOUBLE CHECKING ////////////////////////////////////////////////////////////////
	sll $6, $6, 8 						# Double Checking for Non-Overlapping Values
	srl $6, $6, 8 						# Double Checking for Non_OverLapping Values
	srl $11, $11, 24                    # Shift Right Logical by 24 bits to retain only the Upper Bits
	sll $11, $11, 24					# Shift Left Logical by 24 bits to retain only the Upper Bits
	or $11, $11, $6                     # Or Seggregated Values and the Counter for displaying
	///////////////////////////////////////////////////////////////////////////////////////////////////////
    sw  $11, 0($16)                     # Push Values into Lower 4 Seven Segment Displays for Displaying
    sll $11, $11, 8                     # Left shift by 8 bits
    srl $11, $11, 8						# Right shift by 8 bits
    j DELAY								# Jump to the called function

ANTICLOCKWISEAT5:
li $7, 0x10000000                       # Load Value of Segment A(10) into Upper bits of $7
or $11, $11, $7                         # Or Value of Segment A into Global Display Register($11)
jal ANTICOUNTER_LOGIC5                  # Jump to Decrement Compass Logic for 5hz
jal INTEGRATE                           # Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ                           # Loop at 5hz
jal CHECK_CONTINUOUS                    # Check if Button is still pressed

li $7, 0x15000000                       # Load Value of Segment F(15) into Upper bits of $7
or $11, $11, $7                     	# Or Value of Segment F into Global Display Register($11)
jal ANTICOUNTER_LOGIC5                  # Jump to Decrement Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x14000000						# Load Value of Segment E(14) into Upper bits of $7
or $11, $11, $7             			# Or Value of Segment E into Global Display Register($11)
jal ANTICOUNTER_LOGIC5					# Jump to Decrement Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x13000000						# Load Value of Segment D(13) into Upper bits of $7
or $11, $11, $7            				# Or Value of Segment D into Global Display Register($11)
jal ANTICOUNTER_LOGIC5					# Jump to Decrement Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x12000000						# Load Value of Segment C(12) into Upper bits of $7
or $11, $11, $7           				# Or Value of Segment C into Global Display Register($11)
jal ANTICOUNTER_LOGIC5					# Jump to Decrement Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x11000000						# Load Value of Segment B(11) into Upper bits of $7
or $11, $11, $7             			# Or Value of Segment B into Global Display Register($11)
jal ANTICOUNTER_LOGIC5					# Jump to Decrement Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

j LOGIC                         		# Jump Back to Logic



ANTICLOCKWISEAT10:
li $7, 0x10000000                       # Load Value of Segment A(10) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment A into Global Display Register($11)
jal ANTICOUNTER_LOGIC10					# Jump to Decrement Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x15000000						# Load Value of Segment F(15) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment F into Global Display Register($11)
jal ANTICOUNTER_LOGIC10					# Jump to Decrement Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x14000000						# Load Value of Segment E(14) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment E into Global Display Register($11)
jal ANTICOUNTER_LOGIC10					# Jump to Decrement Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x13000000						# Load Value of Segment D(13) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment D into Global Display Register($11)
jal ANTICOUNTER_LOGIC10					# Jump to Decrement Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x12000000						# Load Value of Segment C(12) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment C into Global Display Register($11)
jal ANTICOUNTER_LOGIC10					# Jump to Decrement Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x11000000						# Load Value of Segment B(11) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment B into Global Display Register($11)
jal ANTICOUNTER_LOGIC10					# Jump to Decrement Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

j LOGIC



CLOCKWISEAT10:
li $7, 0x10000000						# Load Value of Segment A(10) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment A into Global Display Register($11)
jal COUNTER_LOGIC10						# Jump to Increment Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x11000000						# Load Value of Segment B(11) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment B into Global Display Register($11)
jal COUNTER_LOGIC10						# Jump to Increment Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x12000000						# Load Value of Segment C(12) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment C into Global Display Register($11)
jal COUNTER_LOGIC10						# Jump to Increment Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x13000000						# Load Value of Segment D(13) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment D into Global Display Register($11)
jal COUNTER_LOGIC10						# Jump to Increment Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x14000000						# Load Value of Segment E(14) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment E into Global Display Register($11)
jal COUNTER_LOGIC10						# Jump to Increment Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x15000000						# Load Value of Segment F(15) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment F into Global Display Register($11)
jal COUNTER_LOGIC10						# Jump to Increment Compass Logic for 10hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT10HZ							# Loop at 10hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

j LOGIC


CLOCKWISEAT5:
li $7, 0x10000000						# Load Value of Segment A(10) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment A into Global Display Register($11)
jal COUNTER_LOGIC5						# Jump to Increment Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x11000000						# Load Value of Segment B(11) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment B into Global Display Register($11)
jal COUNTER_LOGIC5						# Jump to Increment Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x12000000						# Load Value of Segment C(12) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment C into Global Display Register($11)
jal COUNTER_LOGIC5						# Jump to Increment Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x13000000						# Load Value of Segment D(13) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment D into Global Display Register($11)
jal COUNTER_LOGIC5						# Jump to Increment Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x14000000						# Load Value of Segment E(14) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment E into Global Display Register($11)
jal COUNTER_LOGIC5						# Jump to Increment Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

li $7, 0x15000000						# Load Value of Segment F(15) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment F into Global Display Register($11)
jal COUNTER_LOGIC5						# Jump to Increment Compass Logic for 5hz
jal INTEGRATE							# Jump to Integrate for Segregating and Displaying values on the Lower Seven Segments
jal LOOPAT5HZ							# Loop at 5hz
jal CHECK_CONTINUOUS					# Check if Button is still pressed

j LOGIC


FORWARD:
li $7, 0x10000000						# Load Value of Segment A(10) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment A into Global Display Register($11)
or $11, $11, $6							# Or with the Seggregated values stored in Register $6
sw  $11, 0($16)							# Push value of Global Display into 16 for display
jal LOOPAT1HZ							# Loop at 1hz

li $7, 0xFF000000                       # Load Value FF to Turn Off the 4th Seven Segment for Blinking
srl $11, $11, 24                        # Double - Checking
sll $11, $11, 24						# Double - Checking
or $11, $11, $7							# Motion Value
or $11, $11, $6							# Or with Counter values
sw  $11, 0($16)							# Display compass value and blinking 4th Seven Segment
jal LOOPAT1HZ							# Loop at 1hz
j  LOGIC                                # Loop back to Logic

REVERSE:
li $7, 0x13000000						# Load Value of Segment A(10) into Upper bits of $7
or $11, $11, $7							# Or Value of Segment A into Global Display Register($11)
or $11, $11, $6							# Or with the Seggregated values stored in Register $6
sw  $11, 0($16)							# Push value of Global Display into 16 for display
jal LOOPAT1HZ							# Loop at 1hz

li $7, 0xFF000000                       # Load Value FF to turn Off the 4th Seven Segment for Blinking
srl $11, $11, 24                        # Double - Checking
sll $11, $11, 24						# Double - Checking
or $11, $11, $7							# Motion Value
or $11, $11, $6							# Or with Counter Values
sw  $11, 0($16) 						# Write values to 7segment
jal LOOPAT1HZ						    # Loop at 1hz
j LOGIC

STOP:
li $7, 0x16000000                       # Load value 16(g Seven Segment) for a Steady State
or $11, $11, $7						    # values pushed to leds stack
or $11, $11, $6							# Or with counter values
sw  $11, 0($16)                         # Display the compass value and Motion Indicator Steady State
j LOGIC									# Loop

DEFAULT:
j STOP

EXIT:
j LOGIC

///////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////// COMPASS INTERGRATION LOGIC////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
////////////////////// DECREMENT AT 5HZ///////////////////////////////
ANTICOUNTER_LOGIC5:

   and $24, $13, 0x00000F00                 # Mask all the bits except for the Hundreds Place
   and $25, $13, 0x000000F0                 # Mask all the bits except for the tens place
   and $17, $13, 0x0000000F					# Mask all the bits except for the units place
   srl $24, $24, 8                          # Shift Hundreds digit to the rightmost digit for checking
   srl $25, $25, 4							# Shift Tens digit to the rightmost digit for checking
   bne $24, 0, ANTITENS5                    # If Hundreds Place is not equal to 0, branch to AntiTens5
   bne $25, 0, ANTITENSLOGIC5				# Else If Tens Place is not equal to 0, branch to AntitensLogic5
   beq $17, 0, ANTIULTALOGIC5				# Else if Units place is equal to 0 ,branch to AntiUltaLogic5
   sub $13, $13, 1							# Else We can subtract one from the units place
   j DELAY

ANTIULTALOGIC5:
  beq $25, 0, ANTIZEROLOGIC5				# Branch if Tens Place if Equal to 0, else continue sequential execution

ANTIZEROLOGIC5:
  beq $24, 0, ULTALOGIC5                    #Branch if Hundreds Place is Equal to 0,else continue sequential execution

ULTALOGIC5:
  and  $13, $13, 0x00000000                 # And Global Counter variable($13) with 0000 as the number is equal to 0
  addi $13, $13, 857						# Add immediate value of Global Variable with 857( Hex 359)
  j DELAY

ANTITENSLOGIC5:
  beq $17,0, ANTIONE9LOGIC5                 # Branch to ANTIONE9LOGIC5 if units place if equal to 0, else continue sequential execution
  sub $13, $13, 1							# Units place is in between 1 and 9 hence we can subtract one directly
  j DELAY

ANTIONE9LOGIC5:
  and $13, $13, 0x00000FF0                  # Mask Hundreds and Tens Place
  or $13, $13, 0x00000009                   # Or the Masked Value with 9 as the Units Place was 0
  sub $13, $13, 16							# Subtract 16, which will decrement the Tens Place by 1
  j DELAY

ANTITENS5:
   beq $25, 0, ANTIUNIT5					# Branch if Tens Place is equal to 0 , else continue sequential execution
   j ANTITENSLOGIC5							# Jump to ANTITENSLOGIC 5

ANTIUNIT5:
   beq $17, 0, ANTITWO9LOGIC5               # Branch if the units place is equal to 0, else continue sequential execution
   j ANTITENSLOGIC5                         # Jump to ANTITENSLOGIC5

ANTITWO9LOGIC5:
   and $13, $13, 0x00000F00                 # Mask Hundreds Place
   or $13, $13, 0x00000099                  # Or Global Counter with 99,as the number is Either 100,200 or 300
   sub $13, $13, 256						# Subtract 256, it will decrement the Hundreds Place by 1
   j DELAY
//////////////////////////////////////////////////////////////////////////////
//////////////////////  DECREMENT AT 5HZ//////////////////////////////////////






//////////////////////////////////////////////////////////////////////////////
////////////////////// DECREMENT AT 10HZ///////////////////////////////
ANTICOUNTER_LOGIC10:

   and $24, $13, 0x00000F00                 # Mask all the bits except for the Hundreds Place
   and $25, $13, 0x000000F0                 # Mask all the bits except for the tens place
   and $17, $13, 0x0000000F					# Mask all the bits except for the units place
   srl $24, $24, 8							# Shift Hundreds digit to the rightmost digit for checking
   srl $25, $25, 4							# Shift Tens digit to the rightmost digit for checking
   bne $24, 0, ANTITENS10					# If Hundreds Place is not equal to 0, branch to AntiTens10
   bne $25, 0, ANTITENSLOGIC10				# Else If Tens Place is not equal to 0, branch to AntitensLogic10
   beq $17, 0, ANTIULTALOGIC10				# Else if Units place is equal to 0 ,branch to AntiUltaLogic10
   sub $13, $13, 1							# Else We subtract one from the units place
   j DELAY

ANTIULTALOGIC10:
  beq $25, 0, ANTIZEROLOGIC10				# Branch if Tens Place if Equal to 0, else continue sequential execution

ANTIZEROLOGIC10:
  beq $24, 0, ULTALOGIC10					#Branch if Hundreds Place is Equal to 0,else continue sequential execution

ULTALOGIC10:
  and  $13, $13, 0x00000000					# And Global Counter variable($13) with 0000 as the number is equal to 0
  addi $13, $13, 857						# Add immediate value of Global Variable with 857( Hex 359)
  j DELAY

ANTITENSLOGIC10:
  beq $17,0, ANTIONE9LOGIC10				# Branch to ANTIONE9LOGIC10 if units place if equal to 0, else continue sequential execution
  sub $13, $13, 1							# Units place is in between 1 and 9 hence we can subtract one directly
  j DELAY

ANTIONE9LOGIC10:
  and $13, $13, 0x00000FF0					# Mask Hundreds and Tens Place
  or $13, $13, 0x00000009 					# Or the Masked Value with 9 as the Units Place was 0
  sub $13, $13, 16							# Subtract 16, which will decrement the Tens Place by 1
  j DELAY

ANTITENS10:
   beq $25, 0, ANTIUNIT10					# Branch if Tens Place is equal to 0 , else continue sequential execution
   j ANTITENSLOGIC10						# Jump to ANTITENSLOGIC10

ANTIUNIT10:
   beq $17, 0, ANTITWO9LOGIC10				# Branch if the units place is equal to 0, else continue sequential execution
   j ANTITENSLOGIC10						# Jump to ANTITENSLOGIC10

ANTITWO9LOGIC10:
   and $13, $13, 0x00000F00					# Mask Hundreds Place
   or $13, $13, 0x00000099                  # Or Global Counter with 99, as the Number is either 100,200 or 300
   sub $13, $13, 256						# Subtract 256 from the Global Counter($13) which will decrement Hundreds Place by 1
   j DELAY
//////////////////////////////////////////////////////////////////////////////
//////////////////////  DECREMENT AT 10HZ//////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////////
/////////////////////////INCREMENT AT 5HZ/////////////////////////////////////////////

COUNTER_LOGIC5:
 and $24, $13, 0x0000000F                   # Mask all the bits except for the LSB
 beq $24, 9, CHECK_TOP5						# Check if Units Place is 9
 addi $13, $13, 1                           # If LSB is less than 9, Increment counter
 j DELAY

CHECK_TOP5:
bne $13, 857, CHECK_MIDDLE5                 # Branch if Number is not 359, else continue sequentially
and $13, $13, 0x00000000					# Set to zero if it is greater than 359.
j DELAY

CHECK_MIDDLE5:                              # Number is less than 359, now check if 10s place is 9
 and $25, $13, 0x000000F0					# Mask all other values except 10s Place
 bne $25, 144, CHECK_1005					# If number is not equal to 9 , branch to Check Hundreds Place
 j CHECK_3005                         	    # Jump to Check_3005

CHECK_1005:
 and $17, $13, 0x00000F00                   # Mask all the digits except for the Hundreds Digit
 beq $25, 90, CHECK_3005                    # Branch if the Tens Place is Equal to 90, else continue executing sequentially
 bne $17, 3, TENS_LOGIC5					# Branch if the Hundreds Place is Not equal to 3(0,1,2)

CHECK_3005:
bne $17, 3, HUNDREDS_LOGIC5					# Branch if Hundreds Place not equal to 3

HUNDREDS_LOGIC5:
addi $13, $13, 256							# Add 256, which will increment the Hundreds Place by 1
and $13, $13, 0x00000F00					# Set the Tens and Units Place to 0
j DELAY

TENS_LOGIC5:
addi $13, $13, 16							# Add 16 to the Global counter, which will increment Tens Place by 1
and $13, $13, 0xFFFFFFF0					# Set Units Place to 0
j DELAY


////////////////////////////////////////////////////////////////////////////////////
/////////////////////////INCREMENT AT 5HZ/////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////////
/////////////////////////INCREMENT AT 10HZ/////////////////////////////////////////////

COUNTER_LOGIC10:
 and $24, $13, 0x0000000F                   # Mask all the bits except for the LSB
 beq $24, 9, CHECK_TOP10					# Check if LSB is 9
 addi $13, $13, 1                           # If LSB is less than 9, Increment counter
 j DELAY

CHECK_TOP10:
bne $13, 857, CHECK_MIDDLE10                # Branch if Number is not 359, else continue sequentially
and $13, $13, 0x00000000					# Set to zero if it is greater than 359.
j DELAY

CHECK_MIDDLE10:                             # Number is less than 359, now check if 10s place is 9
 and $25, $13, 0x000000F0					# Mask all other values except 10s Place
 bne $25, 144, CHECK_10010					# If number is not equal to 9 , branch to Check Hundreds Place
 j CHECK_30010                         	    # Jump to Check_30010

CHECK_10010:
 and $17, $13, 0x00000F00                   # Mask all the digits except for the Hundreds Digit
 beq $25, 90, CHECK_30010                   # Branch if the Tens Place is Equal to 90, else continue executing sequentially
 bne $17, 3, TENS_LOGIC10					# Branch if the Hundreds Place is Not equal to 3(0,1,2)

CHECK_30010:
bne $17, 3, HUNDREDS_LOGIC10				# Branch if Hundreds Place not equal to 3

HUNDREDS_LOGIC10:
addi $13, $13, 256							# Add 256, which will increment the Hundreds Place by 1
and $13, $13, 0x00000F00					# Set the Tens and Units Place to 0
j DELAY

TENS_LOGIC10:
addi $13, $13, 16							# Add 16 to the Global counter, which will increment Tens Place by 1
and $13, $13, 0xFFFFFFF0					# Set Units Place to 0
j DELAY


////////////////////////////////////////////////////////////////////////////////////
/////////////////////////INCREMENT AT 10HZ/////////////////////////////////////////////

CHECK_CONTINUOUS:

lw $5,0($20)                                # Load value of Button Pressed from Push Button
beq $4 , $5 , DELAY							# Check if Same PushButton is still pressed, if yes go back to the Loop
j DEFAULT




///////////// LOOP 1 HZ////////////////////////////////


LOOPAT1HZ:
li $14,13418316                            # Load Loop Counter Value which will give 1hz Frequency( i<=13418316)
li $15,0								   # i=0
loop1:
beq $15,$14,DELAY
addi $15,$15,1							   # i++
j loop1

///////////// LOOP 1 HZ////////////////////////////////




///////////// LOOP 5 HZ////////////////////////////////


LOOPAT5HZ:
li $14, 2683663                           # Load Loop Counter Value which will give 5hz Frequency( i<=2683663)
li $15,0								  # i=0
loop3:
beq $15,$14,DELAY
addi $15,$15,1							  # i++
j loop3

///////////// LOOP 5 HZ////////////////////////////////




///////////// LOOP 10 HZ////////////////////////////////
LOOPAT10HZ:

li $14,1344989                             # Load Loop Counter Value which will give 10hz Frequency( i<=1344989)
li $15,0								   # i=0
loop2:
beq $15,$14,DELAY
addi $15,$15,1							   # i++
j loop2
///////////// LOOP 10 HZ////////////////////////////////

DELAY:
jr $ra



//////////////////////////////////////////////////////////////////////////
