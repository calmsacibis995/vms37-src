!File:	LABIOSAMP.FOR
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

	Program LABIO_SAMPLE
!
! This program samples channel #2 once every 10 seconds.
! It acquires 10 points at 1/tic, averages them and then
! Reports the date, time, and average value on logcial device
! LABIO_SAMPLE_DATA

	Include 'LABCHNDEF.FOR'

	Parameter MBX_NAME = 'LABIO_SAMPLE'
	Character*130 RETURN
	Character*15 COMMAND
	Character*24 DATE_TIME
	Logical*4 SUCCESS,SYS$CREMBX
	Integer*4 DELTA_TIME(2),NEXT_TIME(2)
	Integer*4 AVERAGE

	Parameter AD_CHANNEL = 2		! Channel
	Parameter AD_RATE = 1			!
	Parameter AD_BUF_SIZE = 10
	Parameter SAMPLE_RATE = '0 0:0:10'
	Parameter MAX_SAMPLE = 10 000		! Maximum # samples

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
	Open ( Unit = 2, Name = MBX_NAME, Type = 'Old' )
!
! Deassign the channel assigned when we created it
!
	Call SYS$DASSGN( %Val(MBX_CHANNEL) )
!
! Open A Data File
!
	Open( Unit = 3, Name = 'LAB_SAMPLE_DATA', Type = 'New' )
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
!          Collect 1 buffer at a time

	COMMAND = 'ALLOCATE'
	Write(1,400) COMMAND,AD_CHANNEL,AD_RATE,AD_BUF_SIZE,1
	If( RETURN_CODE .ne. 0 ) Go To 99	!Failed to allocate!
	
!
! Every SAMPLE_RATE secs. we will collect one buffer of data
!

! Convert ASCII delta time to binary
	Call SYS$BINTIM( SAMPLE_RATE, DELTA_TIME ) 

! Schedule wake-ups every delt time interval
! But first cancel any previous wake-ups
	Call SYS$CANWAK(,)
	Call SYS$SCHDWK(,,DELTA_TIME,DELTA_TIME)

! Wait for scheduled time interval
10	Call SYS$HIBER()

! Enable data acqusition by setting event flag ACTIVITY and NOTIFY
!
	Call SYS$SETEF(%Val(EF_ACTIVITY_OFF+AD_CHANNEL))
	Call SYS$SETEF(%Val(EF_NOTIFY_OFF+AD_CHANNEL))
	Call SYS$ASCTIM(,DATE_TIME,,)

! Now, wait for buffer to be filled, event flag STATUS will be set
! when data are ready
	Call SYS$WAITFR( %Val(EF_STATUS_OFF+AD_CHANNEL) )

! Buffer is filled, get the buffer index
	INDEX = AD_BLOCK(7,AD_CHANNEL)

! Clear the STATUS event flag and notify the I/O process
	Call SYS$CLREF( %Val(EF_STATUS_OFF+AD_CHANNEL) )
	Call SYS$SETEF( %Val(EF_NOTIFY_OFF+AD_CHANNEL) )
! Average the points
	AVERAGE = 0
	Do 20 I = 1, AD_BUF_SIZE
20	AVERAGE = AVERAGE + DATA_BUFFER(I,INDEX,AD_CHANNEL)
	AVERAGE = AVERAGE/AD_BUF_SIZE

! Write out average with the acq. date/time
	Write(3,400) DATE_TIME,AVERAGE

! If we're all done, close files and exit
	If( AD_BLOCK(6,AD_CHANNEL) .lt. MAX_SAMPLE ) Go To 10 	

! All done, Call the exit routine

99	Call EXIT(1)		!Exit

100	Format(' ',A,A)
200	Format(I2,A)
400	Format(' ',A,4I)
	End
![End of File]
