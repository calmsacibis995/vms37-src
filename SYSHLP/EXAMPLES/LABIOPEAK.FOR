!File:	LABIOPEAK.FOR
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

	Program LABIO_PEAK
! This routine continuously samples channel #1 search for peaks.
! The sample rate is 1/TIC. It reports the PEAK height and position
! to logical channel 'LABIO_PEAK_DATA'

	Include 'LABCHNDEF.FOR'

	Parameter MBX_NAME = 'LABIO_PEAK'
	Character*130 RETURN
	Character*15 COMMAND
	Character*24 DATE_TIME
	Logical*4 SUCCESS,SYS$CREMBX

	Parameter AD_CHANNEL = 1		! Channel Number
	Parameter AD_RATE = 1			! Rate
	Parameter AD_BUF_SIZE = 512		! Buffer Size

	Parameter MAX_PEAKS = 10
	Integer*4 ITABLE(10),INLAST,INPTR,OUTPUT(2,MAX_PEAKS),IDIMO,NPEAKS
	Integer*2 INPUT(AD_BUF_SIZE*2)

	Data ITABLE/10*0/
	Data INLAST,INPTR,IDIMO,NPEAKS/0,0,MAX_PEAKS,0/
!
! Map To the Global Data Base and the event flags
!
	Call LABIO_INIT(0)
!
! Open Mailbox to LABIO_CONNECT
!
	Open ( Unit = 1, Name = 'LABIO_CONNECT' , Type = 'OLD' )
!
! Create Mailbox for response from LABIO_CONNECT
!
	SUCCESS = SYS$CREMBX(,MBX_CHANNEL,,,%Val('FD00'x),,MBX_NAME)
	If (.not.  SUCCESS )  Call FATAL_ERROR( SUCCESS, 'CREATING MAILBOX')
!
! Open via FORTRAN
!
	Open ( Unit = 2, Name = MBX_NAME, Type = 'OLD' )
!
! Deassign the channel assigned when we created it
!
	Call SYS$DASSGN( %Val(MBX_CHANNEL) )
!
! Open A Data File
!
	Open( Unit = 3, Name = 'LABIO_PEAK_DATA' ,Type = 'NEW' )
!
! Connect to the LABIO system
!
	COMMAND = 'CONNECT'
	Write(1,100) COMMAND,MBX_NAME
!
! Wait for Response from LABIO system
!
	Read(2,200) RETURN_CODE,RETURN
	If( RETURN_CODE .ne. 0 ) Go To 99	!Failed to connect!
!
! Allocate Channel AD_CHANNEL
!          Rate  = AD_RATE
!	   Buffer size = AD_BUF_SIZE

	COMMAND = 'ALLOCATE'
	Write(1,400) COMMAND,AD_CHANNEL,AD_RATE,AD_BUF_SIZE,0
	Read(2,200) RETURN_CODE,RETURN
	If( RETURN_CODE .ne. 0 ) Go To 99	!Failed to allocate!


! Enable data acqusition by setting event flag ACTIVITY and NOTIFY
!
	Call SYS$SETEF(%Val(EF_ACTIVITY_OFF+AD_CHANNEL))
	Call SYS$SETEF(%Val(EF_NOTIFY_OFF+AD_CHANNEL))

! Now, wait for buffer to be filled, event flag STATUS will be set
! when data are ready

5	Call SYS$WAITFR( %Val(EF_STATUS_OFF+AD_CHANNEL) )

! Buffer is filled, get the buffer index
!
	INDEX = AD_BLOCK(7,AD_CHANNEL)

! Move data from data buffer to peak processing buffer

	Do 10 I = 1, AD_BUF_SIZE
10	INPUT(I+INLAST) = DATA_BUFFER(I,INDEX,AD_CHANNEL)
	INLAST = INLAST + AD_BUF_SIZE

! Clear the STATUS event flag and notify the I/O process
!
	Call SYS$CLREF( %Val(EF_STATUS_OFF+AD_CHANNEL) )
!(DEBUG) only
!	Write (3,600) (DATA_BUFFER(I,INDEX,AD_CHANNEL),I=1,AD_BUF_SIZE)
!
! Call the peak processing routine
!
15	Call PEAK(ITABLE,INPUT,INLAST,INPTR,OUTPUT,MAX_PEAKS,NPEAKS)

! Report the peak info

	PEAK_SWITCH = NPEAKS		!Remember the peak switch

	If( NPEAKS .ne. 0 ) Then	!We have some peaks
	  If( NPEAKS .lt. 0 ) NPEAKS = MAX_PEAKS !WE have the max
	  Do 20 I = 1, NPEAKS
	   TOTAL_PEAKS = TOTAL_PEAKS + 1 !One more	
20	   Write(3,500) TOTAL_PEAKS,(OUTPUT(J,I), J = 1,2)
	End If

	NPEAKS = 0			!Reset the pointer
	If( PEAK_SWITCH .lt. 0 ) Go To 15 !More peaks to find

! Move any unprocessed data to the beginning of the input array

	If ( (INPTR .gt. 0) .and. (INPTR .lt. INLAST) ) Then		
	  Do 30 I = 1, INLAST-INPTR	 	  
30	  INPUT(I) = INPUT( INPTR+I )   !Move the data
	  INLAST = I			!Last element stored
	Else
	  INLAST = 0
	End If

	INPTR = 0			!Last element processed

	
! Go wait for more data
	Go To 5

! All done, Call the exit routine

99	Call EXIT(1)		!Exit

100	Format(' ',A,A)
200	Format(I2,A)
400	Format(' ',A,4I)
500	Format(3I10)
600 	Format(I5)
	End
![End of File]
