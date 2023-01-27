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
!Define mailbox block for LAB_IO

	Parameter MAX_MESSAGE = 128		     !Maximum message length
	Parameter MBX_RESPONSE_L = 2                 !Response Length
	Parameter MBX_ACK_L = MAX_MESSAGE+MBX_RESPONSE_L

	Integer*2 MBX_IO_STATUS, MBX_MESSAGE_L
	Integer*4 MBX_PID
	Byte MBX_RESPONSE(MBX_RESPONSE_L)
	Byte MBX_MESSAGE(MAX_MESSAGE)

	Common /MBX_BLOCK/ MBX_CHANNEL, MBX_IO_STATUS, MBX_MESSAGE_L,
	1                  MBX_PID, MBX_RESPONSE, MBX_MESSAGE

!                > MBX_BLOCK <
!	____________________________________
!	!            MBX_CHANNEL            ! Word 1-2
!	-------------------------------------
!	! MBX_MESSAGE_L   ! MBX_IO_STATUS   ! Word 3-4
!	-------------------------------------
!	!             MBX_PID               ! Word 5-6
!	-------------------------------------
!	!           MBX_RESPONSE            ! Word 7-8
!	-------------------------------------
!	!                                   !
!	!                                   !
!	!           MBX_MESSAGE             ! Word 9-MAX_MESSAGE+8
!	!                                   !
!	!                                   !
!       -------------------------------------
!
![End of File]
