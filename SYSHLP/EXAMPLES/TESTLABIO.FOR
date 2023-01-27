!File:	TESTLABIO.FOR
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
!
! Tests the LABIO system by allocating upto 16 channels
! Enter the number of channels, rate, and buffer size

	Program TEST_LABIO

	Include 'LABCHNDEF.FOR'

	Parameter MBX_NAME = 'TEST_LABIO2'
	Character*130 RETURN
	Character*15 COMMAND
	Character*24 DATE_TIME
	Logical*4 SUCCESS,SYS$CREMBX
	Integer*4 TEST_CHAN,TEST_RATE,TEST_BUF_SIZE

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
! Get parameters from operator
!
10	LAST_TEST_CHAN=TEST_CHAN
	Type 600,' Enter number of channels, rate(in tics), and buffer size'
	Accept 700, TEST_CHAN,TEST_RATE,TEST_BUF_SIZE
	If ( TEST_CHAN .eq. 0 ) CAll Exit(1)
!
! Deallocate Channels from last time
!
	Do 20 AD_CHANNEL=1,LAST_TEST_CHAN

	Call SYS$CLREF(%Val(EF_ACTIVITY_OFF+AD_CHANNEL)) !Stop Acq.
	Call SYS$SETEF(%Val(EF_NOTIFY_OFF+AD_CHANNEL))
	
	COMMAND = 'DEALLOCATE'
	Write(1,400) COMMAND,AD_CHANNEL
	Read(2,200) RETURN_CODE,RETURN
	If( RETURN_CODE .ne. 0 ) 
	1  Type 500, ' Deallocation failure',RETURN_CODE,RETURN
20	Continue
!
! Allocate Channels
!
	Do 30 AD_CHANNEL=1,TEST_CHAN
	
	COMMAND = 'ALLOCATE'
	Write(1,400) COMMAND,AD_CHANNEL,TEST_RATE,TEST_BUF_SIZE,0
	Read(2,200) RETURN_CODE,RETURN
	If( RETURN_CODE .ne. 0 ) 
	1  Type 500, ' Allocation failure',RETURN_CODE,RETURN


! Enable data acqusition by setting event flag ACTIVITY and NOTIFY
!
	Call SYS$SETEF(%Val(EF_ACTIVITY_OFF+AD_CHANNEL))
30	Call SYS$SETEF(%Val(EF_NOTIFY_OFF+AD_CHANNEL))
	Go To 10
!
! Connect Failure
!
99	Type 500, ' Connect failure',RETURN_CODE,RETURN
	Go To 10

100	Format(' ',A,A)
200	Format(I2,A)
400	Format(' ',A,4I)
500	Format(A/' ',I2,A)
600	Format(A)
700	Format(3I10)
	End

