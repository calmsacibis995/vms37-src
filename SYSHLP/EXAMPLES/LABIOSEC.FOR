!File:	LABIOSEC.FOR
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
! Block Data Routine to place the LABIO_SECTION Common
! on a page boundry. This is necessary because we will
! remap it. We could have used a MACRO program to
! declare the PSECT LABIO_SECTION to be paged aligned,
! but the LINKer would then give us a warning message.

	Block Data LABIO_SECTION
	Common /LABIO_SECTION/ AD_BLOCK
	End
!
![End of File]
