!File:	LABCHNDEF.FOR
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
	Implicit Integer (A-Z)


!AD_CHANNEL STATUS BLOCK defined the parameters associated
!with each A/D channel
!
!For each A/D channel:
! 1)	Status of the channel (ACTIVE or INACTIVE)
! 2)	PID of the connected process allocated the channel
! 3)	Tics/sample (time between sample in tics)
! 4)	Buffer size in words
! 5)	Buffer count (0 if no limit)
! 6)	Buffers acquired
! 7)	Index to the last full buffer containing valid data
!	      0 => No buffer available
! 8)	Number of data points in the last full buffer

! The following elements are used by the data acquisition interrupt service
! routine. In general, they will not be used by an application process.
! 
! 9)	Index to the current data acquisition buffer
! 10)	Number of data points in the current data acquisition buffer
! 11)	Number of tics until the next sample
! 12)	Offset to the next data point to be acquired (wrst buffer #1)
!	(NOTE: Offset = Index - 1 )

	Parameter	MAX_AD_CHANNEL = 16	!Maximum number of channels
	Parameter	MAX_BUF_SIZE = 512	!Maximum buffer size
	Parameter	INACTIVE = 1		!Status values for AD_BLOCK
	Parameter	ACTIVE = 2		!

	Integer*4	AD_BLOCK(MAX_AD_CHANNEL,16)

!
! Data buffers
!
	Parameter	BUFFER_COUNT = 2 	! Number of buffers/channel

	Integer*2 DATA_BUFFER(MAX_BUF_SIZE,BUFFER_COUNT,MAX_AD_CHANNEL)



!This module defines the common data structures
!for the privileged LABIO processes.

!CONNECT BLOCK used to identify processes currently
!connected to the LABIO process.
!
!For each process CONNECT_BLOCK contains:
!	Process ID (PID)
!	Internal VMS I/O channel of the connected processes mailbox

	Parameter	MAX_PID = 16		!Maximum number of processes
	Integer*4	CONNECT_BLOCK(MAX_PID,2)







!
!
! DATA COMMON SECTION
! This will be mapped as a global data section
!

	Common  /LABIO_SECTION/ AD_BLOCK, DATA_BUFFER, CONNECT_BLOCK
	Common  /LABIO_SECTION/ LABIO_BUFFER_E !Last element of DATA section
	Equivalence (AD_BLOCK,LABIO_BUFFER_S)  !First element of DATA section
	Integer*4 SECTION(2),SECTION_SIZE



!
! Define Global Event Flag Cluster names and numbers
!
! EF_NOTIFY_CLUSTER is used to notify the priveleged LABIO process
! that change of status has occured, i.e. channel has
! become ACTIVE or INACTIVE, or a buffer has been freed.
! Flags 0-15 of the cluster correspond to CHANNELS 1-16
! Flags 16-31 are not used.

	Parameter EF_NOTIFY_CLSTR = 'LABIO_EF_NOTIFY'
! First flag of notify
	Parameter EF_NOTIFY_1 = 64
! Offset to Notify
	Parameter EF_NOTIFY_OFF = 63
! Event Flag EF_DATA_ACQ is set when LABIO_DATA_ACQ has completed initialization
	Parameter EF_DATA_ACQ = EF_NOTIFY_1+17
! Event Flag EF_CONNECT is set when LABIO_CONNECT has completed initialization
	Parameter EF_CONNECT = EF_NOTIFY_1+18

! EF_STATUS is used to notify a applications process
! that a buffer is available, and used by an application
! process to inicate the status (ACTIVE or INACTIVE) of
! a channel.
!
! Flags 0-15 of the cluster are the ACTIVITY flags
! if set (by the application process), the corresponding
! channel(1-16) is active. If clear, the channel is inactive.
! When a change of state is made the corresponding flag must
! also be set in Cluster EF_NOTIFY_CLUSTER.
!
! Flags 16-31 are the buffer status flags, when set,
! a buffer for the corresponding channel (1-16) is available.
! The application process mus clear the flag and set the corresponding
! flag in EF_NOTIFY_CLUSTER when it is finished with the buffer.

	Parameter EF_STATUS_CLSTR = 'LABIO_EF_STATUS'
!First event flag in Activity and Status
	Parameter EF_ACTIVITY_1 = 96
	Parameter EF_STATUS_1 = EF_ACTIVITY_1 + 16
!Offset to Activity and Status  
	Parameter EF_ACTIVITY_OFF = 95
	Parameter EF_STATUS_OFF = EF_ACTIVITY_OFF + 16
 
! BIT array, BIT(I) = has bit I set ( I = 1 to 32 )

	Integer*4 BIT(32)
	Data BIT/ '1'X,'2'X,'4'X,'8'X,'10'X,'20'X,'40'X,'80'X,
	1	  '100'X,'200'X,'400'X,'800'X,'1000'X,'2000'X,
	1	  '4000'X,'8000'X,'10000'X,'20000'X,'40000'X,
	1	  '80000'X,'100000'X,'200000'X,'400000'X,
	1	  '800000'X,'1000000'X,'2000000'X,'4000000'X,
	1	  '8000000'X,'10000000'X,'20000000'X,'40000000'X,
	1	  '80000000'X/
!
![End of File]
