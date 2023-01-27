!File:	LABIOCOM.FOR
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
	Logical Function LABIO_INIT( PRIVILEGE )
!
! This routine is used to attach a LABIO user program to the
! LABIO system. It associated the two event flag clusters and
! maps to the LABIO global data section.
!
! INPUT:	PRIVILEGE - Privileged LABIO users can set this
!		to 1 to allow write access to the data base.
!		All others must set this to 0.
!
! OUTPUT:	None - Currently will always return with success code.
!		If an error occurs, FATALERR is called to display
!		the error messages and STOP THE PROCESS!
!
!

	Include 'LABCHNDEF.FOR'
	Logical*4 SYS$ASCEFC,SYS$MGBLSC,SUCCESS,SYS$WAITFR
	External SEC$M_WRT

!
! Create event flag cluster EF_NOTIFY and associate with event flags 64-95
! These are used to notify the Data Acquisition process.

	SUCCESS = SYS$ASCEFC( %VAL(EF_NOTIFY_1),EF_NOTIFY_CLSTR,,)
	If ( .not. SUCCESS)
	1	Call FATAL_ERROR( SUCCESS, 'CREATING EVENT FLAG CLUSTER')
!
! Create event flag cluster EF_STATUS and associate with event flags 96-127
! These are used to notify and report the status of the user buffers
!
	SUCCESS = SYS$ASCEFC( %VAL(EF_STATUS_1),EF_STATUS_CLSTR,,)
	If ( .not. SUCCESS)
	1	Call FATAL_ERROR( SUCCESS, 'CREATING EVENT FLAG CLUSTER')

!
! Map to the GLOBAL DATA section created by the I/O program
! Wait for event flag EF_CONNECT (non-privileged) or
! EF_DATA_ACQ  (privileged) before attempting mappimg.

	SECTION(1) = %Loc(LABIO_BUFFER_S)
	SECTION(2) = %Loc(LABIO_BUFFER_E) - 1

	SECTION_FLAGS = 0		!Default flags

	If( PRIVILEGE .ne. 0 ) Then
	  SECTION_FLAGS=%Loc(SEC$M_WRT)
	  Call SYS$WAITFR( %Val( EF_DATA_ACQ ) )
	Else
	  Call SYS$WAITFR( %Val( EF_CONNECT ) )
	End If

	SUCCESS = SYS$MGBLSC( SECTION,,,%Val(SECTION_FLAGS),'LABIOCOMMON',,)
	If( .not. SUCCESS ) Call FATAL_ERROR(SUCCESS,'mapping data section')

	LABIO_INIT = SUCCESS

	Return

	End

!	FATAL_ERROR  -  FATAL ERROR HANDLER
!
!	This routine is used to report a fatal error and exit the image
!
!	INPUT:	ERROR_CODE - SYSTEM ERROR CODE TO REPORT
!		ERROR_MESSAGE - ERROR MESSAGE TO BE PRINTED
!
!	OUTPUT:	NONE
!	
!	>>>> THIS ROUTINE DOES NOT RETURN <<<<<
!
!	FUNCTION: TYPEs the message
!
!		  'process name-FATAL ERROR - error_message'
!
!		 Then prints system message corresponding to  ERROR_CODE
!
!
!		 Finally, exits image by calling LIB$STOP
!
	Subroutine FATAL_ERROR(error_code,error_message)

	Integer*4 ERROR_CODE
	Character ERROR_MESSAGE*(*)
	Logical*4 SUCCESS,SYS$CREMBX,SYS$GETJPI
	Integer*2 JPI2(8),PROCESS_NAME_L
	Integer*4 JPI4(4)
	Character*15 PROCESS_NAME
	Equivalence (JPI2,JPI4)
	Parameter JPI$_PRCNAM='31C'X
!
!	Get the process name
!
	JPI2(1) =  15			!Number of elements in name
	JPI2(2) = JPI$_PRCNAM		!Want process name
	JPI4(2) = %Loc(PROCESS_NAME)	!Address of process name
	JPI4(3) = %Loc(PROCESS_NAME_L)	!Address of process name length
	JPI4(4) = 0			!Terminate list

	Call SYS$GETJPI(,,,JPI4,,,)
!
! Print the process name and error message
!
	Type 100, PROCESS_NAME(1:PROCESS_NAME_L),ERROR_MESSAGE
!
! Print the error message corresponding to ERROR_CODE and exit
!	
	Call LIB$STOP( %Val(ERROR_CODE) )

100	Format(' 'A,' - FATAL ERROR ',A)

	Stop

	END
![End of File]
