### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	WAITLIST.agc
## Purpose:	Part of the reconstructed source code for LMY99 Rev 0,
##		otherwise known as Luminary Rev 99, the second release
##		of the Apollo Guidance Computer (AGC) software for Apollo 11.
##		It differs from LMY99 Rev 1 (the flown version) only in the
##		placement of a single label. The corrections shown here have
##		been verified to have the same bank checksums as AGC developer
##		Allan Klumpp's copy of Luminary Rev 99, and so are believed
##		to be accurate. This file is intended to be a faithful 
##		recreation, except that the code format has been changed to 
##		conform to the requirements of the yaYUL assembler rather than 
##		the original YUL assembler.
##
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Pages:	1117-1132
## Mod history:	2009-05-25 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2011-01-06 JL	Fixed pseudo-label indentation.
##		2011-05-07 JL	Removed workarounds.
##		2016-12-17 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-01-28 RSB	WTIH -> WITH.
##		2017-02-09 RSB	Comment-text fixes identified in proofing Artemis 72.
##		2017-02-27 RSB	Corrected WAITP00H and LONGP00H to similar POOH names.
##		2017-03-14 RSB	Comment-text fixes noted in proofing Luminary 116.
##		2017-03-16 RSB	Comment-text fixes identified in 5-way
##				side-by-side diff of Luminary 69/99/116/131/210.
##		2017-08-01 MAS	Created from LMY99 Rev 1.

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the MIT Museum.  The digitization
## was performed by Paul Fjeld, and arranged for by Deborah Douglas of
## the Museum.  Many thanks to both.  The images (with suitable reduction
## in storage size and consequent reduction in image quality as well) are
## available online at www.ibiblio.org/apollo.  If for some reason you
## find that the images are illegible, contact me at info@sandroid.org
## about getting access to the (much) higher-quality images which Paul
## actually created.
##
## The code has been modified to match LMY99 Revision 0, otherwise
## known as Luminary Revision 99, the Apollo 11 software release preceeding
## the listing from which it was transcribed. It has been verified to
## contain the same bank checksums as AGC developer Allan Klumpp's listing
## of Luminary Revision 99 (for which we do not have scans).
##
## Notations on Allan Klumpp's listing read, in part:
##
##	ASSEMBLE REVISION 099 OF AGC PROGRAM LUMINARY BY NASA 2021112-51

## Page 1117
# PROGRAM DESCRIPTION								DATE - 10 OCTOBER 1966
# MOD NO - 2									LOG SECTION - WAITLIST
# MOD BY - MILLER	(DTMAX INCREASED TO 162.5 SEC)				ASSEMBLY SUNBURST REV 5
# MOD 3 BY KERNAN	(INHINT INSERTED AT WAITLIST) 2/28/68 SKIPPER REV 4
# MOD 4 BY KERNAN	(TWIDDLE IN 54) 3/28/68 SKIPPER REV 13.
#
# FUNCTIONAL DESCRIPTION -
#	PART OF A SECTION OF PROGRAMS,- WAITLIST, TASKOVER, T3RUPT, USED TO CALL A PROGRAM, (CALLED A TASK),
#	WHICH IS TO BEGIN IN C(A) CENTISECONDS.  WAITLIST UPDATES TIME3, LST1 AND LST2.  THE MEANING OF THESE LISTS
#	FOLLOW.
#
#		C(TIME3) = 16384 -(T1-T) CENTISECONDS, (T=PRESENT TIME, T1-TIME FOR TASK1)
#
#			C(LST1)		=	-(T2-T1)+1
#			C(LST1 +1)	=	-(T3-T2)+1
#			C(LST1 +2)	=	-(T4-T3)+1
#				        .
#					.
#			C(LST1 +6)	=	-(T8-T7)+1
#			C(LST1 +7)	=	-(T9-T8)+1
#
#			C(LST2)		=	2CADR OF TASK1
#			C(LST2 +2)	=	2CADR OF TASK2
#				        .
#					.
#			C(LST2 +14)	=	2CADR OF TASK8
#			C(LST2 +16)	=	2CADR OF TASK9
#
# WARNINGS -
# --------
#	1)	1 <= C(A) <= 16250D (1 CENTISECOND TO 162.5 SEC)
#	2)	9 TASKS MAXIMUM
#	3)	TASKS CALLED UNDER INTERRUPT INHIBITED
#	4)	TASKS END BY TC TASKOVER
#
# CALLING SEQUENCE -
#	L-1	CA	DELTAT 	(TIME IN CENTISECONDS TO TASK START)
#	L	TC	WAITLIST
#	L+1	2CADR	DESIRED TASK
#	L+2	(MINOR OF 2CADR)
#	L+3	RELINT		(RETURNS HERE)
#
# TWIDDLE -
# -------
#	TWIDDLE IS FOR USE WHEN THE TASK BEING SET UP IS IN THE SAME EBANK AND FBANK AS THE USER.  IN
#	SUCH CASES, IT IMPROVES UPON WAITLIST BY ELIMINATING THE NEED FOR THE BBCON HALF OF THE 2CADR,
## Page 1118
#	SAVING A WORD.  TWIDDLE IS LIKE WAITLIST IN EVERY RESPECT EXCEPT CALLING SEQUENCE, TO WIT-
#		L-1	CA	DELTAT
#		L	TC	TWIDDLE
#		L+1	ADRES	DESIRED TASK
#		L+2	RELINT		(RETURNS HERE)
#
# NORMAL EXIT MODES -
#	AT L+3 OF CALLING SEQUENCE
#
# ALARM OR ABORT EXIT MODES -
#	TC	ABORT
#	OCT	1203	(WAITLIST OVERFLOW - TOO MANY TASKS)
#
# ERASABLE INITIALIZATION REQUIRED -
#	ACCOMPLISHED BY FRESH START,--	LST2, ..., LST2 +16 = ENDTASK
#					LST1, ..., LST1 +7  = NEG1/2
#
# OUTPUT --
#	LST1 AND LST2 UPDATED WITH NEW TASK AND ASSOCIATED TIME.
#
# DEBRIS -
#	CENTRALS - A,Q,L
#	OTHER    - WAITEXIT, WAITADR, WAITTEMP, WAITBANK
#
# DETAILED ANALYSIS OF TIMING -
#	CONTROL WILL NOT BE RETURNED TO THE SPECIFIED ADDRESS (2CADR) IN EXACTLY DELTA T CENTISECONDS.
#	THE APPROXIMATE TIME MAY BE CALCULATED AS FOLLOWS
#		LET TO = THE TIME OF THE TC WAITLIST
#		LET TS = TO +147U + COUNTER INCREMENTS (SET UP TIME)
#		LET X  = TS -(100TS)/100  (VARIANCE FROM COUNTERS)
#		LET Y  = LENGTH OF TIME OF INHIBIT INTERRUPT AFTER T3RUPT
#		LET Z  = LENGTH OF TIME TO PROCESS TASKS WHICH ARE DUE THIS T3RUPT BUT DISPATCHED EARLIER.
#			 (Z=0, USUALLY)
#		LET DELTD  = THE ACTUAL TIME TAKEN TO GIVE CONTROL TO 2CADR
#		THEN DELTD = TS+DELTA T -X +Y +Z +1.05MS* +COUNTERS*
#		*-THE TIME TAKEN BY WAITLIST ITSELF AND THE COUNTER TICKING DURING THIS WAITLIST TIME.
#	IN SHORT, THE ACTUAL TIME TO RETURN CONTROL TO A 2CADR IS AUGMENTED BY THE TIME TO SET UP THE TASK:S
# 	INTERRUPT, ALL COUNTERS TICKING, THE T3RUPT PROCESSING TIME, THE WAITLIST PROCESSING TIME AND THE POSSIBILITY
#	OF OTHER TASKS INHIBITING THE INTERRUPT.

		BLOCK	02
## Page 1119
		EBANK=	LST1		# TASK LISTS IN SWITCHED E BANK.

		COUNT*	$$/WAIT
TWIDDLE		INHINT
		TS	L		# SAVE DELAY TIME IN L
		CA	POSMAX
		ADS	Q		# CREATING OVERFLOW AND Q-1 IN Q
		CA	BBANK
		EXTEND
		ROR	SUPERBNK
		XCH	L

WAITLIST	INHINT
		XCH	Q		# SAVE DELTA T IN Q AND RETURN IN
		TS	WAITEXIT	# WAITEXIT.
		EXTEND
		INDEX	WAITEXIT	# IF TWIDDLING, THE TS SKIPS TO HERE
		DCA	0		# PICK UP 2CADR OF TASK.
 -1		TS	WAITADR		# BBCON WILL REMAIN IN L
DLY2		CAF	WAITBB		# ENTRY FROM FIXDELAY AND VARDELAY.
		XCH	BBANK
		TCF	WAIT2

# RETURN TO CALLER AFTER TASK INSERTION:

LVWTLIST	DXCH	WAITEXIT
		AD	TWO
		DTCB

		EBANK=	LST1
WAITBB		BBCON	WAIT2

# RETURN TO CALLER +2 AFTER WAITING DT SPECIFIED AT CALLER +1.

FIXDELAY	INDEX	Q		# BOTH ROUTINES MUST BE CALLED UNDER
		CAF	0		# WAITLIST CONTROL AND TERMINATE THE TASK
		INCR	Q		# IN WHICH THEY WERE CALLED.

# RETURN TO CALLER +1 AFTER WAITING THE DT AS ARRIVING IN A.

VARDELAY	XCH	Q		# DT TO Q.  TASK ADRES TO WAITADR.
		TS	WAITADR
		CA	BBANK		# BBANK IS SAVED DURING DELAY.
		EXTEND
		ROR	SUPERBNK	# ADD SBANK TO BBCON.
		TS	L
		CAF	DELAYEX
		TS	WAITEXIT	# GO TO TASKOVER AFTER TASK ENTRY.
		TCF	DLY2

## Page 1120
DELAYEX		TCF	TASKOVER -2	# RETURNS TO TASKOVER

## Page 1121
# ENDTASK MUST BE ENTERED IN FIXED-FIXED SO IT IS DISTINGUISHABLE BY ITS ADRES ALONE.

		EBANK=	LST1
ENDTASK		-2CADR	SVCT3

SVCT3		CCS	FLAGWRD2	# DRIFT FLAG
		TCF	TASKOVER
		TCF	TASKOVER
		TCF	+1

CKIMUSE		CCS	IMUCADR		# DON'T DO NBDONLY IF SOMEONE ELSE IS IN
		TCF	SVCT3X		# IMUSTALL.
		TCF	+3
		TCF	SVCT3X
		TCF	SVCT3X

 +3		CAF	PRIO35		# COMPENSATE FOR NBD COEFFICIENTS ONLY.
		TC	NOVAC		#	ENABLE EVERY 81.93 SECONDS
		EBANK=	NBDX
		2CADR	NBDONLY

		TCF	TASKOVER

SVCT3X		TC	FIXDELAY	# DELAY MAX OF 2 TIMES FOR IMUZERO.
		DEC	500
		TC	SVCT3		# CHECK DRIFT FLAG AGAIN.

## Page 1122
# BEGIN TASK INSERTION.

		BANK	01
		COUNT*	$$/WAIT
WAIT2		TS	WAITBANK	# BBANK OF CALLING PROGRAM.
		CA	Q
		EXTEND
		BZMF	WAITPOOH

		CS	TIME3
		AD	BIT8		# BIT 8 = OCT 200
		CCS	A		# TEST 200 - C(TIME3).  IF POSITIVE,
					# IT MEANS THAT TIME3 OVERFLOW HAS OCCURRED PRIOR TO CS TIME3 AND THAT
					# C(TIME3) = T - T1, INSTEAD OF 1.0 - (T1 - T).  THE FOLLOWING FOUR
					# ORDERS SET C(A) = TD - T1 + 1 IN EITHER CASE.

		AD	OCT40001	# OVERFLOW HAS OCCURRED.  SET C(A) =
		CS	A		# T - T1 + 1.0 - 201

# NORMAL CASE (C(A) NNZ) YIELDS SAME C(A):  -( -(1.0-(T1-T)) + 200) - 1

		AD	OCT40201
		AD	Q		# RESULT = TD - T1 + 1.

		CCS	A		# TEST TD - T1 + 1

		AD	LST1		# IF TD - T1 POS, GO TO WTLST5 WITH
		TCF	WTLST5		# C(A) = (TD - T1) + C(LST1) = TD-T2+1

		NOOP
		CS	Q

# NOTE THAT THIS PROGRAM SECTION IS NEVER ENTERED WHEN T-T1 G/E -1,
# SINCE TD-T1+1 = (TD-T) + (T-T1+1), AND DELTA T = TD-T G/E +1.  (G/E
# SYMBOL MEANS GREATER THAN OR EQUAL TO).  THUS THERE NEED BE NO CON-
# CERN OVER A PREVIOUS OR IMMINENT OVERFLOW OF TIME3 HERE.

		AD	POS1/2		# WHEN TD IS NEXT, FORM QUANTITY
		AD	POS1/2		#	1.0 - DELTA T = 1.0 - (TD - T)
		XCH	TIME3
		AD	NEGMAX
		AD	Q		# 1.0 - DELTAT T NOW COMPLETE.
		EXTEND			# ZERO INDEX Q.
		QXCH	7		# (ZQ)

## Page 1123
WTLST4		XCH	LST1
		XCH	LST1 	+1
		XCH	LST1 	+2
		XCH	LST1 	+3
		XCH	LST1 	+4
		XCH	LST1 	+5
		XCH	LST1 	+6
		XCH	LST1 	+7

		CA	WAITADR		# (MINOR PART OF TASK CADR HAS BEEN IN L.)
		INDEX	Q
		TCF	+1

		DXCH	LST2
		DXCH	LST2 	+2
		DXCH	LST2 	+4
		DXCH	LST2 	+6
		DXCH	LST2 	+8D
		DXCH	LST2 	+10D	# AT END, CHECK THAT C(LST2 +10) IS STD
		DXCH	LST2 	+12D
		DXCH	LST2 	+14D
		DXCH	LST2 	+16D
		AD	ENDTASK		# END ITEM, AS CHECK FOR EXCEEDING
					# THE LENGTH OF THE LIST.
		EXTEND			# DUMMY TASK ADRES SHOULD BE IN FIXED-
		BZF	LVWTLIST	# FIXED SO ITS ADRES ALONE DISTINGUISHES
		TCF	WTABORT		# IT.

## Page 1124
WTLST5		CCS	A		# TEST TD - T2 + 1
		AD	LST1 	+1
		TCF	+4
		AD	ONE
		TC	WTLST2
		OCT	1

 +4		CCS	A		# TEST TD - T3 + 1
		AD	LST1 	+2
		TCF	+4
		AD	ONE
		TC	WTLST2
		OCT	2

 +4		CCS	A		# TEST TD - T4 + 1
		AD	LST1 	+3
		TCF	+4
		AD	ONE
		TC	WTLST2
		OCT	3

 +4		CCS	A		# TEST TD - T5 + 1
		AD	LST1 	+4
		TCF	+4
		AD	ONE
		TC	WTLST2
		OCT	4

 +4		CCS	A		# TEST TD - T6 + 1
		AD	LST1 	+5
		TCF	+4
		AD	ONE
		TC	WTLST2
		OCT	5

 +4		CCS	A		# TEST TD - T7 + 1
		AD	LST1 	+6
		TCF	+4
		AD	ONE
		TC	WTLST2
		OCT	6

## Page 1125
 +4		CCS	A	
		AD	LST1 	+7
		TCF	+4
		AD	ONE
		TC	WTLST2
		OCT	7

 +4		CCS	A
WTABORT		TC	FILLED
		NOOP			# CAN'T GET HERE
		AD	ONE
		TC	WTLST2
		OCT	10

OCT40201	OCT	40201

## Page 1126
FILLED		DXCH	WAITEXIT
		TC	BAILOUT1	# NO ROOM IN THE INN
		OCT	01203
		
## Page 1127
# THE ENTRY TO WTLST2 JUST PRECEDING OCT N IS FOR T  LE TD LE T   -1.
#                                                  N           N+1
# (LE MEANS LESS THAN OR EQUAL TO).  AT ENTRY, C(A) = -(TD - T   + 1)
#                                                             N+1
# THE LST1 ENTRY -(T   -T +1) IS TO BE REPLACED BY -(TD - T  + 1), AND
#                   N+1  N                                 N
# THE ENTRY -(T   - TD + 1) IS TO BE INSERTED IMMEDIATELY FOLLOWING.
#              N+1

WTLST2		TS	WAITTEMP	# C(A) = -(TD - T + 1)
		INDEX	Q
		CAF	0
		TS	Q		# INDEX VALUE INTO Q.

		CAF	ONE
		AD	WAITTEMP
		INDEX	Q		# C(A) = -(TD - T ) + 1.
		ADS	LST1 	-1	#                N

		CS	WAITTEMP
		INDEX	Q
		TCF	WTLST4

# 	C(TIME3) 	=	1.0 - (T1 - T)
#
# 	C(LST1)		=	- (T2 - T1) + 1
# 	C(LST1+1)	=	- (T3 - T2) + 1
# 	C(LST1+2)	=	- (T4 - T3) + 1
#	C(LST1+3)	=	- (T5 - T4) + 1
# 	C(LST1+4)	=	- (T6 - T5) + 1
#
#	C(LST2)		=	2CADR TASK1
#	C(LST2+2)	=	2CADR TASK2
#	C(LST2+4)	=	2CADR TASK3
#	C(LST2+6)	=	2CADR TASK4
#	C(LST2+8)	=	2CADR TASK5
#	C(LST2+10)	=	2CADR TASK6

## Page 1128
# ENTERS HERE ON T3 RUPT TO DISPATCH WAITLISTED TASK.

T3RUPT		EXTEND
		ROR	SUPERBNK	# READ CURRENT SUPERBANK VALUE AND
		TS	BANKRUPT	# SAVE WITH E AND F BANK VALUES.
		EXTEND
		QXCH	QRUPT

T3RUPT2		CAF	NEG1/2		# DISPATCH WAITLIST TASK.
		XCH	LST1 	+7
		XCH	LST1 	+6
		XCH	LST1 	+5
		XCH	LST1 	+4	# 1. MOVE UP LST1 CONTENTS, ENTERING
		XCH	LST1 	+3	#    A VALUE OF 1/2 +1 AT THE BOTTOM
		XCH	LST1 	+2	#    FOR T6-T5, CORRESPONDING TO THE
		XCH	LST1 	+1	#    INTERVAL 81.91 SEC FOR ENDTASK.
		XCH	LST1
		AD	POSMAX		# 2. SET T3 = 1.0 - T2 - T USING LIST 1.
		ADS	TIME3		# SO T3 WONT TICK DURING UPDATE.
		TS	RUPTAGN
		CS	ZERO
		TS	RUPTAGN		# SETS RUPTAGN TO +1 ON OVERFLOW.

		EXTEND			# DISPATCH TASK.
		DCS	ENDTASK
		DXCH	LST2 	+16D
		DXCH	LST2 	+14D
		DXCH	LST2 	+12D
		DXCH	LST2 	+10D
		DXCH	LST2 	+8D
		DXCH	LST2 	+6
		DXCH	LST2 	+4
		DXCH	LST2 	+2
		DXCH	LST2

		XCH	L
		EXTEND
		WRITE 	SUPERBNK	# SET SUPERBANK FROM BBCON OF 2CADR
		XCH	L		# RESTORE TO L FOR DXCH Z.
		DTCB

## Page 1129
# RETURN, AFTER EXECUTION OF T3 OVERFLOW TASK:

		BLOCK	02
		COUNT*	$$/WAIT
TASKOVER	CCS	RUPTAGN		# IF +1 RETURN TO T3RUPT, IF -0 RESUME.
		CAF	WAITBB
		TS	BBANK
		TCF	T3RUPT2		# DISPATCH NEXT TASK IF IT WAS DUE.

		CA	BANKRUPT
		EXTEND
		WRITE	SUPERBNK	# RESTORE SUPERBANK BEFORE RESUME IS DONE

RESUME		EXTEND
		QXCH	QRUPT
NOQRSM		CA	BANKRUPT
		XCH	BBANK
NOQBRSM		DXCH	ARUPT
		RELINT
		RESUME

## Page 1130
# LONGCALL
# PROGRAM DESCRIPTION				DATE - 17 MARCH 1967
# PROGRAM WRITTEN BY W.H.VANDEVER		LOG SECTION WAITLIST
# MOD BY - R. MELANSON TO ADD DOCUMENTATION	ASSEMBLY SUNDISK REV. 100
#
# FUNCTIONAL DESCRIPTION -
#	LONGCALL IS CALLED WITH THE DELTA TIME ARRIVING IN A,L SCALED AS TIME2,TIME1 WITH THE 2CADR OF THE TASK
#	IMMEDIATELY FOLLOWING THE TC LONGCALL.  FOR EXAMPLE, IT MIGHT BE DONE AS FOLLOWS WHERE TIMELOC IS THE NAME OF
# 	A DP REGISTER CONTAINING A DELTA TIME AND WHERE TASKTODO IS THE NAME OF THE LOCATION AT WHICH LONGCALL IS TO
# 	START
# CALLING SEQUENCE -
#		EXTEND
#		DCA	TIMELOC
#		TC	LONGCALL
#		2CADR	TASKTODO
# NORMAL EXIT MODE -
#	1).	TC	WAITLIST
#	2).	DTCB	(TO L+3 OF CALLING ROUTINE 1ST PASS THRU LONGCYCL)
#	3).	DTCB	(TO TASKOVER ON SUBSEQUENT PASSES THRU LONGCYCL)
# ALARM OR ABORT EXIT MODE -
#	NONE
# OUTPUT -
#	LONGTIME AND LONGTIME+1 = DELTA TIME
#	LONGEXIT AND LONGEXIT+1 = RETURN 2CADR
#	LONGCADR AND LONGCADR+1 = TASK 2CADR
#	A = SINGLE PRECISION TIME FOR WAITLIST
# ERASABLE INITIALIZATION -
#	A = MOST SIGNIFICANT PART OF DELTA TIME
#	L = LEAST SIGNIFICANT PART OF DELTA TIME
#	Q = ADDRESS OF 2CADR TASK VALUE
# DEBRIS -
#	A,Q,L
#	LONGCADR AND LONGCADR+1
#	LONGEXIT AND LONGEXIT+1
#	LONGTIME AND LONGTIME+1
# *** THE FOLLOWING IS TO BE IN FIXED-FIXED AND UNSWITCHED ERRASIBLE ***

		BLOCK	02
		EBANK=	LST1
LONGCALL	DXCH	LONGTIME	# OBTAIN THE DELTA TIME

		EXTEND			# OBTAIN THE 2CADR
## Page 1131
		NDX	Q
		DCA	0
		DXCH	LONGCADR

		EXTEND			# NOW GO TO THE APPROPRIATE SWITCHED BANK
		DCA	LGCL2CDR	# FOR THE REST OF LONGCALL
		DTCB

		EBANK=	LST1
LGCL2CDR	2CADR	LNGCALL2

# *** THE FOLLOWING MAY BE IN A SWITCHED BANK, INCLUDING ITS ERASABLE ***

		BANK	01
		COUNT*	$$/WAIT
LNGCALL2	LXCH	LONGEXIT +1	# SAVE THE CORRECT BB FOR RETURN
		CA	TWO		# OBTAIN THE RETURN ADDRESS
		ADS	Q
		TS	LONGEXIT

		CA	LONGTIME	# CHECK FOR LEGITIMATE DELTA-TIME
		CCS	A
		TCF	LONGCYCL	# HI-ORDER OK --> ALL IS OK.
		TCF	+2		# HI-ORDER ZERO --> CHECK LO-ORDER.
		TCF	LONGPOOH	# HI-ORDER NEG. --> NEG. DT
 +2		CA	LONGTIME +1	# CHECK LO-ORDER FOR ZERO OR NEGATIVE.
		EXTEND
		BZMF	LONGPOOH	# BAD DELTA-TIME.  ABORT

# *** WAITLIST TASK LONGCYCL ***

LONGCYCL	EXTEND			# CAN WE SUCCESFULLY TAKE ABOUT 1.25
		DCS	DPBIT14		# MINUTES OFF OF LONGTIME
		DAS	LONGTIME

		CCS	LONGTIME +1	# THE REASONIBG BEHIND THIS PART IS
		TCF	MUCHTIME	# INVOLVED, TAKING INTO ACCOUNT THAT THE
					# WORDS MAY NOT BE SIGNED CORRECTED (DP
					# BASIC INSTRUCTIONS
					# DO NOT SIGN CORRECT) AND THAT WE SUBTRAC
					# TED BIT14 (1 OVER HALF THE POS. VALUE
					# REPRESENTIBLE IN SINGLE WORD)
		NOOP			# CAN:T GET HERE **********
		TCF	+1
		CCS	LONGTIME
		TCF	MUCHTIME
DPBIT14		OCT	00000
		OCT	20000
		
					# LONGCALL
## Page 1132
LASTTIME	CA	BIT14		# GET BACK THE CORRECT DELTA T FOR WAITLIST
		ADS	LONGTIME +1
		TC	WAITLIST
		EBANK=	LST1
		2CADR	GETCADR		# THE ENTRY TO OUR LONGCADR

LONGRTRN	CA	TSKOVCDR	# SET IT UP SO THAT ONLY THE FIRST EXIT IS
		DXCH	LONGEXIT	# TO THE CALLER OF LONGCALL
		DTCB			# THE REST ARE TO TASKOVER

MUCHTIME	CA	BIT14		# WE HAVE OVER OUR ABOUT 1.25 MINUTES
		TC	WAITLIST	# SO SET UP FOR ANOTHER CYCLE THROUGH HERE
		EBANK=	LST1
		2CADR	LONGCYCL

		TCF	LONGRTRN	# NOW EXIT PROPERLY

# *** WAITLIST TASK GETCADR ***

GETCADR		DXCH	LONGCADR	# GET THE LONGCALL THAT WE WISHED TO START
		DTCB			# AND TRANSFER CONTROL TO IT

TSKOVCDR	GENADR	TASKOVER
LONGPOOH	DXCH	LONGEXIT
		TCF	+2
WAITPOOH	DXCH	WAITEXIT
 +2		TC	POODOO1
		OCT	01204
		
