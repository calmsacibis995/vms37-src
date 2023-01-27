C****************************************************************************
C*									    *
C*  COPYRIGHT (c) 1978, 1980, 1982 BY					    *
C*  DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASSACHUSETTS.		    *
C*  ALL RIGHTS RESERVED.						    *
C* 									    *
C*  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED   *
C*  ONLY IN  ACCORDANCE WITH  THE  TERMS  OF  SUCH  LICENSE  AND WITH THE   *
C*  INCLUSION OF THE ABOVE COPYRIGHT NOTICE. THIS SOFTWARE OR  ANY  OTHER   *
C*  COPIES THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY   *
C*  OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE IS  HEREBY   *
C*  TRANSFERRED.							    *
C* 									    *
C*  THE INFORMATION IN THIS SOFTWARE IS  SUBJECT TO CHANGE WITHOUT NOTICE   *
C*  AND  SHOULD  NOT  BE  CONSTRUED AS  A COMMITMENT BY DIGITAL EQUIPMENT   *
C*  CORPORATION.							    *
C* 									    *
C*  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE  OR  RELIABILITY OF ITS   *
C*  SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.		    *
C* 									    *
C*									    *
C****************************************************************************

C***********************************************************************P0890010
C*****                                                                  P0890020
C*****                       DPSIN - 089                                P0890030
C*****                                                                  P0890040
C***********************************************************************P0890050
C*****  GENERAL PURPOSE                                          ASA REFP0890060
C*****     TO TEST BASIC EXTERNAL FUNCTION - DSIN -              8.3.3  P0890070
C*****     TRIGONOMETRIC SINE - TYPE DOUBLE PRECISION            TABLE 4P0890080
C*****     SAME AS SEGMENT 088 EXCEPT D.P.                              P0890090
C*****     INTRINSIC FUNCTION DSIGN ASSUMED WORKING                     P0890100
C*****     ARGUMENTS FROM 0 TO 2 PI                                     P0890110
C*****                                                                  P0890120
C*****  S P E C I F I C A T I O N S  SEGMENT 089                        P0890130
C*****                                                                  P0012050
C*****  WHEN EXECUTING ONLY SEGMENT 089, THE SPECIFICATION STATEMENTS   P0012055
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C=                  P0012060
C*****  IN COLUMNS  1  AND  2  REMOVED.                                 P0012065
C*****                                                                  P0012070
C=    DOUBLE PRECISION AVD, BVD, CVD, DVD, EVD, PIVD, XVD, FVD, GVD     P0012075
	PROGRAM UETFORT02
      DOUBLE PRECISION AVD, BVD, CVD, DVD, EVD, PIVD, XVD, FVD, GVD     P089A1  
C*****                                                                  P0012080
C*****  O U T P U T  T A P E  ASSIGNMENT STATEMENT.  NO INPUT TAPE.     P0890140
C*****                                                                  P0071780
C*****  WHEN EXECUTING ONLY SEGMENT 089, THE FOLLOWING STATEMENT        P0071785
C*****  NUVI = 6  MUST HAVE THE C= IN COLUMNS 1 AND 2 REMOVED.          P0071790
C=    NUVI = 6                                                          P0071795
      NUVI = 6                                                          P089B1  
C*****                                                                  P0071800
890   FORMAT(15H1 DPSIN - (089)//32H  BASIC EXTERNAL FUNCTION -DSIN-    P0890150
     1//33H  (TRIGONOMETRIC SINE -TYPE D.P.)                            P0890160
     2//27H  ASA REF.- 8.3.3 (TABLE 4)//24H  LINE 1 OF EACH PAIR IS/23H P0890170
     3 HOLLERITH INFORMATION//9H  RESULTS)                              P0890180
      WRITE (NUVI, 890)                                                 P0890190
C*****    HEADER FOR SEGMENT 089 WRITTEN                                P0890200
      AVD = 3.140625D+0                                                 P0890210
      BVD = 0.9613037109375D-3                                          P0890220
      CVD = 0.57220458984375D-5                                         P0890230
      DVD = 0.596046447753906D-6                                        P0890240
      EVD = 0.31786509547056D-7                                         P0890250
C*****PI IS SUM OF AVD TO EVD, PARTS ARE EXPRESSED IN SUMS OF POWERS OF P0890260
C*****2, TO PERMIT A POSSIBLE 20 DECIMAL DIGIT ARGUMENT TO BE CREATED   P0890270
      PIVD = EVD + DVD + CVD + BVD + AVD                                P0890280
      FVD = 1.0D0                                                       P0890290
      GVD = 2.0D0                                                       P0890300
      XVD = DSIN(GVD - 2.0D0 * FVD)                                     P0890310
      WRITE (NUVI, 891) XVD                                             P0890320
      XVD = DSIN(FVD)                                                   P0890330
      WRITE (NUVI, 892) XVD                                             P0890340
      XVD = DSIN(GVD)                                                   P0890350
      WRITE (NUVI, 893) XVD                                             P0890360
      XVD = DSIN(GVD + FVD)                                             P0890370
      WRITE (NUVI, 894) XVD                                             P0890380
      XVD = DSIN(PIVD)                                                  P0890390
      WRITE (NUVI, 895) XVD                                             P0890400
      XVD = DSIN(2. * GVD)                                              P0890410
      WRITE (NUVI, 896) XVD                                             P0890420
      XVD = DSIN(2.0 +FVD + GVD)                                        P0890430
      WRITE (NUVI, 897) XVD                                             P0890440
      XVD = DSIN(GVD * (FVD + GVD))                                     P0890450
      WRITE (NUVI, 898) XVD                                             P0890460
      XVD = DSIN(DSIGN(2.0D0 * PIVD, GVD))                              P0890470
      WRITE (NUVI, 899) XVD                                             P0890480
      WRITE (NUVI, 7890)                                                P0890490
891   FORMAT(9H0 X= 0.0 ,  31H  0.00000000000000000000000     / D31.14) P0890500
892   FORMAT(9H0 X= 1.0 ,  31H +0.84147098480789650665250D+00 /D31.14)  P0890510
893   FORMAT(9H0 X= 2.0 ,  31H +0.90929742682568169539602D+00 /D31.14)  P0890520
894   FORMAT(9H0 X= 3.0 ,  31H +0.14112000805986722210074D+00 /D31.14)  P0890530
895   FORMAT(9H0 X= (PI),  31H  0.00000000000000000000000     / D31.14) P0890540
896   FORMAT(9H0 X= 4.0 ,  31H -0.75680249530792825137264D+00 /D31.14)  P0890550
897   FORMAT(9H0 X= 5.0 ,  31H -0.95892427466313846889315D+00 / D31.14) P0890560
898   FORMAT(9H0 X= 6.0 ,  31H -0.27941549819892587281156D+00 / D31.14) P0890570
899   FORMAT(9H0 X=(2PI),  31H  0.00000000000000000000000     / D31.14) P0890580
7890  FORMAT(//37H  LINE 2 OF EACH PAIR IS THE FUNCTION/25H  CALCULATIONP0890590
     A PRINTED TO ,9H14 DIGITS)                                         P0890600
C*****    END OF TEST SEGMENT 089                                       P0890610
C*****  WHEN EXECUTING ONLY SEGMENT 089, THE  STOP  AND  END  CARDS     P0890620
C*****  WHICH APPEAR AS COMMENT CARDS MUST HAVE THE C=                  P0890630
C*****  IN COLUMNS  1  AND  2  REMOVED.                                 P0890640
C=    STOP                                                              P0890650
C=    END                                                               P0890660
      STOP                                                              P089C1  
      END                                                               P089C2  
