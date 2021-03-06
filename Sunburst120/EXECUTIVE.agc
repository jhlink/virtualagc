### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    EXECUTIVE.agc
## Purpose:     A module for revision 0 of BURST120 (Sunburst). It 
##              is part of the source code for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 5.
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Pages:       1049-1061
## Mod history: 2016-09-30 RSB  Created draft version.
##              2016-10-08 PDJ  Updated against Sunburst120 scan.
##		2016-10-31 RSB	Some typos.
##		2016-12-06 RSB	Comments proofed using octopus/ProoferComments,
##				changes made.
##		2016-06-23 RSB	Fixed a bogus lower-case g in the comments.

## Page 1049
                BLOCK           02                              

# TO ENTER A JOB REQUEST REQUIRING NO VAC AREA:

NOVAC           TS              NEWPRIO                         # SAVE PRIORITY OF NEW JOB.             
                EXTEND                                          
                INDEX           Q                               # Q WILL BE UNDISTURBED THROUGHOUT.
                DCA             0                               # 2CADR OF JOB ENTERED.
                DXCH            NEWLOC                          
                CAF             EXECBANK                        
                XCH             FBANK                           
                TS              EXECTEM1                        
                TCF             NOVAC2                          # ENTER EXECUTIVE BANK.

# TO ENTER A JOB REQUEST REQUIRING A VAC AREA - E.G., ALL (PARTIALLY) INTERPRETIVE JOBS.

FINDVAC         TS              NEWPRIO                                         
                EXTEND                                          
                INDEX           Q                               
                DCA             0                               
                DXCH            NEWLOC                          
                CAF             EXECBANK                        
                XCH             FBANK                           
                TCF             FINDVAC2                        # OFF TO EXECUTIVE SWITCHED-BANK.

# TO ENTER A FINDVAC WITH THE PRIORITY IN NEWPRIO TO THE 2CADR ARRIVING IN A AND L:

SPVAC           XCH             Q                               
                AD              NEG2                            
                XCH             Q                               
                TCF             FINDVAC         +4                         

# TO SUSPEND A BASIC JOB SO A HIGHER PRIORITY JOB MAY BE SERVICED:

CHANG1          CAF             EXECBANK                              
                TS              L                      
                CA              Q                           
                LXCH            BBANK
 +4             INHINT
                TCF             CHANJOB                                                                             

# TO SUSPEND AN INTERPRETIVE JOB:

CHANG2          CAF             EXECBANK          
# ITRACE (4) REFERS TO "CHANG2".               
                TS              BBANK
                CS              LOC                             # NEGATIVE LOC SHOWS JOB = INTERPRETIVE.
                LXCH            BANKSET                         # BANKSET, NOT BBANK, HAS RIGHT CONTENTS.
                TCF             CHANG1          +4              

## Page 1050

# TO VOLUNTARILY SUSPEND A JOB UNTIL THE COMPLETION OF SOME ANTICIPATED EVENT (I/O EVENT ETC.):

JOBSLEEP        TS              LOC                             
                CAF             EXECBANK                        
                TS              FBANK                           
                TCF             JOBSLP1                         

# TO AWAKEN A JOB PUT TO SLEEP IN THE ABOVE FASHION:

JOBWAKE         TS              NEWLOC                                          
                CS              TWO                             # EXIT IS VIA FINDVAC/NOVAC PROCEDURES.
                ADS             Q                               
                CAF             EXECBANK                        
                XCH             FBANK                           
                TCF             JOBWAKE2                        

# TO CHANGE THE PRIORITY OF A JOB CURRENTLY UNDER EXECUTION:

PRIOCHNG        INHINT                                          # NEW PRIORITY ARRIVES IN A.  RETURNS TO
                TS              NEWPRIO                         # CALLER AS SOON AS NEW JOB PRIORITY IS
                CAF             EXECBANK                        # HIGHEST.  PREPARE FOR POSSIBLE BASIC-
                XCH             BBANK                           # STYLE CHANGE-JOB.
                TS              BANKSET                         
                CA              Q                               
                TCF             PRIOCH2                         

# TO FREE THE DISPLAY BEFORE ENDOFJOB:

EJFREE          TC              FREEDSP

# TO REMOVE A JOB FROM EXECUTIVE CONSIDERATIONS:

ENDOFJOB        CAF             EXECBANK                        
                TS              FBANK                           
                TCF             ENDJOB1                         

ENDFIND         CA              EXECTEM1                        # RETURN TO CALLER AFTER JOB ENTRY
                TS              FBANK                           # COMPLETE.
                TCF             Q+2                             
EXECBANK        CADR            FINDVAC2                        

## Page 1051

# LOCATE AN AVAILABLE VAC AREA.

                BANK            01                              
FINDVAC2        TS              EXECTEM1                        # (SAVE CALLER'S BANK FIRST.)
                CCS             VAC1USE                         
                TCF             VACFOUND                        
                CCS             VAC2USE                         
                TCF             VACFOUND                        
                CCS             VAC3USE                         
                TCF             VACFOUND                        
                CCS             VAC4USE                         
                TCF             VACFOUND                        
                CCS             VAC5USE                         
                TCF             VACFOUND                        
                TC              ABORT                        
                OCT             1201                            # NO VAC AREAS.

VACFOUND        AD              TWO                             # RESERVE THIS VAC AREA BY STORING A ZERO
                ZL                                              # IN ITS VAC USE REGISTER AND STORE THE
                INDEX           A                               # ADDRESS OF THE FIRST WORD OF IT IN THE
                LXCH            0               -1              # LOW NINE BITS OF THE PRIORITY WORD.
                ADS             NEWPRIO                         

NOVAC2          CAF             ZERO                            # NOVAC ENTERS HERE.  FIND A CORE SET.
                TS              LOCCTR                          
                CAF             NO.CORES                        # SEVEN SETS OF ELEVEN REGISTERS EACH.
NOVAC3          TS              EXECTEM2                        
                INDEX           LOCCTR                          
                CCS             PRIORITY                        # EACH PRIORITY REGISTER CONTAINS -0 IF
                TCF             NEXTCORE                        # THE CORrESPONDING CORE SET IS AVAILABLE.
NO.CORES        DEC             6                               
                TCF             NEXTCORE                        # AN ACTIVE JOB HAS A POSITIVE PRIORITY
                                                                # BUT A DORMANT JOB'S PRIORITY IS NEGATIVE

## Page 1052

CORFOUND        CA              NEWPRIO                         # SET THE PRIORITY OF THIS JOB IN THE CORE
                INDEX           LOCCTR                          # SET'S PRIORITY REGISTER AND SET THE
                TS              PRIORITY                        # JOB'S PUSH-DOWN POINTER AT THE BEGINNING
                MASK            LOW9                            # OF THE WORK AREA AND OVERFLOW INDICATOR
                INDEX           LOCCTR                          
                TS              PUSHLOC                         # OFF TO PREPARE FOR INTERPRETIVE PROGRAMS

                CCS             LOCCTR                          # IF CORE SET ZERO IS BEING LOADED, SET UP
                TCF             SETLOC                          # OVFIND AND FIXLOC IMMEDIATELY.
                TS              OVFIND                          
                CA              PUSHLOC                         
                TS              FIXLOC                          

SPECTEST        CCS             NEWJOB                          # SEE IF ANY ACTIVE JOBS WAITING (RARE).
                TCF             SETLOC                          # MUST BE AWAKENED BUT UNCHANGED JOB.
                TC              CCSHOLE                         
                TC              CCSHOLE                         
                TS              NEWJOB                          # +0 SHOWS ACTIVE JOB ALREADY SET.
                DXCH            NEWLOC                          
                DXCH            LOC                             
                TCF             ENDFIND                         

SETLOC          DXCH            NEWLOC                          # SET UP THE LOCATION REGISTERS FOR THIS
                INDEX           LOCCTR                          
                DXCH            LOC                             
                INDEX           NEWJOB                          # THIS INDEX INSTRUCTION INSURES THAT THE
                CS              PRIORITY                        # HIGHEST ACTIVE PRIORITY WILL BE COMPARED
                AD              NEWPRIO                         # WITH THE NEW PRIORITY TO SEE IF NEWJOB
                EXTEND                                          # SHOULD BE SET TO SIGNAL A SWITCH.
                BZMF            ENDFIND                         
                CA              LOCCTR                          # LOCCTR IS LEFT SET AT THIS CORE SET IF
                TS              NEWJOB                          # THE CALLER WANTS TO LOAD ANY MPAC
                TCF             ENDFIND                         # REGISTERS, ETC.

NEXTCORE        CAF             COREINC                         
                ADS             LOCCTR                          
                CCS             EXECTEM2                        
                TCF             NOVAC3                          
                TC              ABORT                           # NO CORE SETS.
                OCT             1202                            

## Page 1053

# THE FOLLOWING ROUTINE SWAPS CORE SET 0 WITH THAT WHOSE RELATIVE ADDRESS IS IN NEWJOB.

 -1             DXCH            LOC                             
CHANJOB         INDEX           NEWJOB                          # LOC ARRIVES IN A AND BBANK IN L.                                          
                DXCH            LOC 
                DXCH            LOC    

                DXCH            MPAC                            # SWAP MULTI-PURPOSE ACCUMULATOR AREAS. 
                INDEX           NEWJOB
                DXCH            MPAC
                DXCH            MPAC
                DXCH            MPAC            +2
                INDEX           NEWJOB
                DXCH            MPAC            +2
                DXCH            MPAC            +2
                DXCH            MPAC            +4
                INDEX           NEWJOB
                DXCH            MPAC            +4
                DXCH            MPAC            +4
                DXCH            MPAC            +6
                INDEX           NEWJOB
                DXCH            MPAC            +6
                DXCH            MPAC            +6

                CAF             ZERO
                XCH             OVFIND                          # MAKE PUSHLOC NEGATIVE IF OVFIND NZ.                        
                EXTEND 
                BZF             +3
                CS              PUSHLOC
                TS              PUSHLOC

                DXCH            PUSHLOC                         
                INDEX           NEWJOB                          
                DXCH            PUSHLOC                         
                DXCH            PUSHLOC                         # SWAPS PUSHLOC AND PRIORITY.
                CAF             LOW9                            # SET FIXLOC TO BASE OF VAC AREA.
                MASK            PRIORITY                        
                TS              FIXLOC                          

                CCS             PUSHLOC                         # SET OVERFLOW INDICATOR ACCORDING TO
                CAF             ZERO                            
                TCF             ENDPRCHG        -1
                CS              PUSHLOC                         
                TS              PUSHLOC
                CAF             ONE                             
                XCH             OVFIND
                TS              NEWJOB 

ENDPRCHG        RELINT                                          
                DXCH            LOC                             # BASIC JOBS HAVE POSITIVE ADDRESSES, SO              

## Page 1054

                EXTEND                                          # DISPATCH WITH A DTCB.
                BZMF            +2                              # IF INTERPRETIVE, SET UP EBANK, ETC.
                DTCB  

## Page 1055
                COM                                             # EPILOGUE TO JOB CHANGE FOR INTERPRETIVE
                AD              ONE                             
                TS              LOC                             # RESUME.
                TCF             INTRSM                          

# COMPLETE JOBSLEEP PREPARATIONS.

JOBSLP1         INHINT                                          
                CS              PRIORITY                        # NNZ PRIORITY SHOWS JOB ASLEEP.
                TS              PRIORITY                        
                CAF             LOW7                            
                MASK            BBANK                           
                TS              BANKSET                         
                CS              ZERO                            
JOBSLP2         TS              BUF             +1              # HOLDS - HIGHEST PRIORITY.
                TCF             EJSCAN                          # SCAN FOR HIGHEST PRIORITY ALA ENDOFJOB.

## Page 1056

# TO WAKE UP A JOB, EACH CORE SET IS FOUND TO LOCATE ALL JOBS WHICH ARE ASLEEP.  IF THE FCADR IN THE
# LOC REGISTER OF ANY SUCH JOB MATCHES THAT SUPPLIED BY THE CALLER, THAT JOB IS AWAKENED.  IF NO JOB IS FOUND,
# LOCCTR IS SET TO -1 AND NO FURTHER ACTION TAKES PLACE.

JOBWAKE2        TS              EXECTEM1                        
                CAF             ZERO                            # BEGIN CORE SET SCAN.
                TS              LOCCTR                          
                CAF             NO.CORES                        
JOBWAKE4        TS              EXECTEM2                        
                INDEX           LOCCTR                          
                CCS             PRIORITY                        
                TCF             JOBWAKE3                        # ACTIVE JOB - CHECK NEXT CORE SET.
COREINC         DEC             12                              # 12 REGISTERS PER CORE SET.
                TCF             WAKETEST                        # SLEEPING JOB - SEE IF CADR MATCHES.

JOBWAKE3        CAF             COREINC                         
                ADS             LOCCTR                          
                CCS             EXECTEM2                        
                TCF             JOBWAKE4                        
                CS              ONE                             # EXIT IF SLEEPING JOB NOT FOUND.
                TS              LOCCTR                          
                TCF             ENDFIND                         

WAKETEST        CS              NEWLOC                          
                INDEX           LOCCTR                          
                AD              LOC                             
                EXTEND                                          
                BZF             +2                              # IF MATCH.
                TCF             JOBWAKE3                        # EXAMINE NEXT CORE SET IF NO MATCH.

                INDEX           LOCCTR                          # RE-COMPLEMENT PRIORITY TO SHOW JOB AWAKE
                CS              PRIORITY                        
                TS              NEWPRIO                         
                INDEX           LOCCTR                          
                TS              PRIORITY                        

                CS              FBANKMSK                        # MAKE UP THE 2CADR OF THE WAKE ADDRESS
                MASK            NEWLOC                          # USING THE CADR IN NEWLOC AND THE EBANK
                AD              2K                              # HALF OF BBANK SAVED IN BANKSET.
                XCH             NEWLOC                          
                MASK            FBANKMSK                        
                INDEX           LOCCTR                          
                AD              BANKSET                         
                TS              NEWLOC          +1              

                CCS             LOCCTR                          # SPECIAL TREATMENT IF THIS JOB WAS
                TCF             SETLOC                          # ALREADY IN THE RUN (0) POSITION.
                TCF             SPECTEST                        

## Page 1057

# PRIORITY CHANGE.  CHANGE THE CONTENTS OF PRIORITY AND SCAN FOR THE JOB OF HIGHEST PRIORITY.

PRIOCH2         TS              LOC                             
                CAF             ZERO                            # SET FLAG TO TELL ENDJOB SCANNER IF THIS
                TS              BUF                             # JOB IS STILL HIGHEST PRIORITY.
                CAF             LOW9                            
                MASK            PRIORITY                        
                AD              NEWPRIO                         
                TS              PRIORITY                        
                COM                                             
                TCF             JOBSLP2                         # AND TO EJSCAN.

## Page 1058

# RELEASE THIS CORE SET AND VAC AREA AND SCAN FOR THE JOB OF HIGHEST ACTIVE PRIORITY.

ENDJOB1         INHINT                                          
                CS              ZERO                            
                TS              BUF             +1              
                XCH             PRIORITY                        
                MASK            LOW9                            
                CCS             A
                INDEX           A
                TS              0

EJSCAN          CCS             PRIORITY        +12D            
                TC              EJ1                             
                TC              CCSHOLE                         
                TCF             +1                              

                CCS             PRIORITY        +24D            # EXAMINE EACH PRIORITY REGISTER TO FIND
                TC              EJ1                             # THE JOB OF HIGHEST ACTIVE PRIORITY.
                TC              CCSHOLE                         
                TCF             +1                              

                CCS             PRIORITY        +36D            
                TC              EJ1                             
-CCSPR          -CCS            PRIORITY                        
                TCF             +1                              

                CCS             PRIORITY        +48D            
                TC              EJ1                             
                TC              CCSHOLE                         
                TCF             +1                              

                CCS             PRIORITY        +60D            
                TC              EJ1                             
                TC              CCSHOLE                         
                TCF             +1                              

                CCS             PRIORITY        +72D            
                TC              EJ1                             
                TC              CCSHOLE                         
                TCF             +1                                                       

## Page 1059

# EVALUATE THE RESULTS OF THE SCAN.

                CCS             BUF             +1              # SEE IF THERE ARE ANY ACTIVE JOBS WAITING
                TC              CCSHOLE                         
                TC              CCSHOLE                         

                TCF             +2                              
                TCF             DUMMYJOB                        
                CCS             BUF                             # BUF IS ZERO IF THIS IS A PRIOCHNG AND
                TCF             +2                              # CHANGED PRIORITY IS STILL HIGHEST.
                TCF             ENDPRCHG                      

                INDEX           A                               # OTHERWISE, SET NEWJOB TO THE RELATIVE
                CAF             0               -1              # ADDRESS OF THE NEW JOB'S CORE SET.
                AD              -CCSPR                          
                TS              NEWJOB                          
                TCF             CHANJOB         -1              

EJ1             TS              BUF             +2              
                AD              BUF             +1              # - OLD HIGH PRIORITY.
                CCS             A                               
                CS              BUF             +2              
                TCF             EJ2                             # NEW HIGH PRIORITY.
                NOOP                                            
                INDEX           Q                               
                TC              2                               # PROCEED WITH SEARCH.

EJ2             TS              BUF             +1              
                EXTEND                                          
                QXCH            BUF                             # FOR LOCATING CCS PRIORITY + X INSTR.
                INDEX           BUF                             
                TC              2                               

## Page 1060

# IDLING AND COMPUTER ACTIVITY (GREEN) LIGHT MAINTENANCE. THE IDLING ROUTINE IS NOT A JOB IN ITSELF,
# BUT RATHER A SUBROUTINE OF THE EXECUTIVE.

                BLOCK           02
                EBANK=          SELFRET                         # SELF-CHECK STORAGE IN EBANK.

DUMMYJOB        CS              ZERO                            # SET NEWJOB TO -0 FOR IDLING.
                TS              NEWJOB                          
                RELINT                                          
                CS              TWO                             # TURN OFF THE ACTIVITY LIGHT.
                EXTEND                                          
                WAND            DSALMOUT 
                TCF             CHECKNJ         +2

CHECKNJ         EXTEND                                          # SPECIAL NEWJOB TEST FOR SELF-CHECK,
                QXCH            SELFRET                         # WHICH RUNS UNDER EXECUTIVE CONTROL,
 +2             CCS             NEWJOB                          # BUT DOES NOT HAVE A JOBS CORE REGISTERS.
                TCF             NUCHANGE                        # NEW JOB REQUIRING A CHANGE JOB.
                CAF             TWO                             # NEW JOB ALREADY IN POSITION FOR
                TCF             NUDIRECT                        # EXECUTION.                

ADVAN           CAF             SELFBANK                        # (SIMULATOR ADVAN IF NEWJOB = 77777).
                TS              BBANK
                TC              SELFRET

NUDIRECT        EXTEND                                          # TURN THE GREEN LIGHT BACK ON.
                WOR             DSALMOUT                        
                DXCH            LOC                             # JOBS STARTED IN THIS FASHION MUST BE
                DTCB                                            # BASIC.

NUCHANGE        CAF             TWO
                EXTEND
                WOR             DSALMOUT
                CAF             EXECBANK                        # SWAP CORE SETS.
                TS              FBANK
                INHINT                                          # CHANGE JOBS
                TCF             CHANJOB         -1                    

                EBANK=          SELFRET                         
SELFBANK        BBCON           SELFCHK                         

## Page 1061

# PRIORITY CONSTANTS (NOTE IN FIXED-FIXED).

PRIO1           EQUALS          BIT10
PRIO2           EQUALS          BIT11
PRIO3           OCT             03000
PRIO4           EQUALS          BIT12
PRIO5           OCT             05000
PRIO6           OCT             06000
PRIO7           OCT             07000 
PRIO10          EQUALS          BIT13
PRIO11          OCT             11000
PRIO12          =               BNKJUP+4
PRIO13          OCT             13000
PRIO14          OCT             14000
PRIO15          OCT             15000  
PRIO16          OCT             16000
PRIO17          OCT             17000
PRIO20          EQUALS          BIT14 
PRIO21          OCT             21000
PRIO22          OCT             22000
PRIO23          OCT             23000
PRIO24          =               NUFAZ+10
PRIO25          OCT             25000
PRIO26          OCT             26000
PRIO27          OCT             27000
PRIO30          =               BNKCAL+2
PRIO31          OCT             31000
PRIO32          OCT             32000
PRIO33          OCT             33000
PRIO34          OCT             34000
PRIO35          OCT             35000
PRIO36          OCT             36000
PRIO37          OCT             37000

# EBANK CONSTANTS IN FIXED-FIXED

EBANK3          EQUALS          OCT1400
EBANK4          EQUALS          BIT11
EBANK5          OCTAL           02400
EBANK6          EQUALS          PRIO3
EBANK7          OCTAL           03400