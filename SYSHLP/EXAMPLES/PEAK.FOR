!File FPEAK.FOR
!	Version V02-000
!
!****************************************************************************
!*									    *
!*  COPYRIGHT (c) 1980                                                      *
!*  BY DIGITAL EQUIPMENT CORPORATION, MAYNARD, MASS.			    *
!* 									    *
!*  THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY BE USED AND  COPIED  *
!*  ONLY  IN  ACCORDANCE  WITH  THE  TERMS  OF  SUCH  LICENSE AND WITH THE  *
!*  INCLUSION OF THE ABOVE COPYRIGHT NOTICE.  THIS SOFTWARE OR  ANY  OTHER  *
!*  COPIES  THEREOF MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY  *
!*  OTHER PERSON.  NO TITLE TO AND OWNERSHIP OF  THE  SOFTWARE  IS  HEREBY  *
!*  TRANSFERRED.							    *
!* 									    *
!*  THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE  WITHOUT  NOTICE  *
!*  AND  SHOULD  NOT  BE  CONSTRUED  AS  A COMMITMENT BY DIGITAL EQUIPMENT  *
!*  CORPORATION.							    *
!* 									    *
!*  DIGITAL ASSUMES NO RESPONSIBILITY FOR THE USE OR  RELIABILITY  OF  ITS  *
!*  SOFTWARE ON EQUIPMENT WHICH IS NOT SUPPLIED BY DIGITAL.		    *
!*									    *
!****************************************************************************
!

	Subroutine PEAK(ITABLE,INPUT,INLAST,INPTR,OUTPUT,IDIMO,NPEAKS)
!A trivial peak-picking routine. The calling sequence is patterned
!after the LSPLIB routine PEAK.

	Integer*4 ITABLE(10),OUTPUT(2,IDIMO),INLAST,INPTR,IDIM0,NPEAK
	Integer*2 INPUT(1)
	Parameter NOISE = 5	!Noise value = 5 A/D units

!Initialize some parameters, if necesary
	If( NPEAKS .lt. 0 ) NPEAKS = 0
	If( INPTR  .lt. 0 ) INPTR  = 0

!First time thru?
	If( INPTR  .lt. INLAST .and. ITABLE(1) .eq. 0 ) Then 
	  INPTR = INPTR + 1
	  ITABLE(1) = 1 		!Assume we're rising
	  ITABLE(2) = 1			!first point
	  ITABLE(3) = INPUT(INPTR)
	End If
!Any data to process?
	If(INPTR .lt. INLAST ) Then
	  Do 10 I = INPTR+1, INLAST
	   If( ITABLE(1) .gt. 0 ) Then	!We're rising, look for a fall
	    If( INPUT(I) .lt. ITABLE(3)-NOISE ) Then !We found a peak
	        If( NPEAKS .lt. IDIMO ) Then !Any room to store it?
	          NPEAKS = NPEAKS + 1
	          OUTPUT(1,NPEAKS) = ITABLE(3)
	          OUTPUT(2,NPEAKS) = ITABLE(2)
	          ITABLE(1) = -1
	        Else				!No, tell user
	          INPTR = I - 1
	          NPEAKS = -IDIMO
	          Return
	        End If
	    End If
	   Else				!We're falling, see if we found a valley
	    If( INPUT(I) .gt. ITABLE(3)+NOISE )    ITABLE(1) = 1
	   End If
	   ITABLE(3) = INPUT(I)
10	   ITABLE(2) = ITABLE(2) + 1
	End If

	INPTR = -1			!Normal exit all data processed.
	Return

	End
