C
C	Version 'V03-000'
C
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
C
C
C
C	AUTHOR	BRIAN PORTER		CREATION DATE	07-MAR-79
C
C

C++
C	Functional description:
C
C	This routine outputs the bit-to-text translation for a given
C	register bit field.  The bit-to-text translation is controlled by
C	argument FLAG.  If FLAG is '0' then all set bits are translated.
C	If FLAG is '1' then all clear bits are translated.  If FLAG is '2'
C	then all bits are translated according to their polarity.
C
C	Modified by:
C
C	v02-002	BP0002		Brian Porter		02-JUN-1981
C		Appended OUTPUT_MLINES subroutine.
C
C	v02-001	BP0001		Brian Porter		06-JAN-1981
C		Rewritten to include FLAG control '2'.
C**
C--



	subroutine output (lun,register_mask,text_array,text_array_base,
	1 translation_start_bit,translation_end_bit,translation_control_flag)




	byte		lun

	byte		translation_control_flag

	integer*4	text_array_base

	integer*4	translation_start_bit

	integer*4	translation_end_bit

	integer*4	register_mask

	integer*4	lib$extzv

	integer*4	compressc

	character*(*)	text_array(text_array_base:translation_end_bit,0:1)




	do 100,i = translation_start_bit,translation_end_bit

	polarity = lib$extzv (i,1,register_mask)

	if ((translation_control_flag .eq. '0'
	1 .and.
	1 polarity .eq. 1)
	1 .or.
	1 (translation_control_flag .eq. '1'
	1 .and.
	1 polarity .eq. 0)) then

	call linchk (lun,1)

	write(lun,10) text_array(i,0)
10	format(' ',t40,a<compressc (text_array(i,0))>)

	else if (translation_control_flag .eq. '2')  then

	call linchk (lun,1)

	write(lun,20) text_array(i,polarity)
20	format(' ',t40,a<compressc (text_array(i,polarity))>)
	endif

100	continue

	return

	end



	Subroutine OUTPUT_MLINES (lun,string,sub_string,field_length)



C++
C	Author:	Sharon Reynolds			Creation date:	19-Mar-1981
C
C
C	Functional description:
C
C	This module will take the passed character string and separate
C	it at the delimiting character(s) and output it. If there are
C	no delimiting characters found, the string will be output
C	on one line. 
C	Because this routine is an interim solution for outputting
C	multiple lines of text, there are two restrictions; (1) the 
C	passed string will only be separated into six lines and (2) the
C	passed string can only be 192 characters in length (six lines for
C	32 character field). These restrictions may be changed by manipulating 
C	the size of 'array' and 'c_string'.
C
C	Modified by:
C**
C--


	Byte		lun


	Integer*4	field_length
	Integer*4	cnt
	Integer*4	num_lines
	Integer*4	sub_string_pos
	Integer*4	ret_status
	Integer*4	rstatus
	Integer*4	I

	Character*(*)	string

	Character*80	array(0:5)
	Character*1	sub_string
	Character*192	c_string


C
C	Initialize necessary variables
C

	Cnt = 0

	C_string = string

C
C	Locate the first occurence of the delimiter symbol in the string
C

	Sub_string_pos = INDEX (c_string,sub_string)

C
C	If there was no delimiter symbol in the string then output it
C	on one line using the field length that was passed via the call
C

	If (sub_string_pos .eq. 0) then

	Call LINCHK (lun,1)
	Write (lun,10) string
10	Format (' ',T40,A<field_length>)

	Return
	Endif

C
C	There was a delimiter symbol found in the string; separate the 
C	string at the delimiter
C

20	Ret_status = STR$LEFT (array(cnt),c_string,(sub_string_pos - 1))

	Cnt = cnt + 1

	Rstatus = STR$RIGHT (array(cnt),c_string,(sub_string_pos + 1))

C
C	See if there is another delimiter symbol in the second portion 
C	of the string and make a copy of the string
C

	Sub_string_pos = INDEX (array(cnt),sub_string)

	C_String = array(cnt)

C
C	Check to see if the string has been separated into the maximum
C	number of lines and if so, output the strings 
C	

	If (cnt .eq. 5) then

	Goto 25
	Endif

C
C	Check to see if a delimiter symbol was found in the second 
C	portion of the string and if so, go separate the string
C	again
C	

	If (sub_string_pos .ne. 0) then

	Goto 20

	Endif

C
C	The strings are ready to be output so do it.
C

25	Num_lines = cnt
	Cnt = 0

	Call LINCHK (lun,(num_lines))

	Write (lun,27) array(cnt)
27	Format (' ',T40,A<field_length>)

	Do 40, I=1, num_lines

	Cnt = cnt + 1

	Write (lun,30) array(cnt)
30	Format (' ',T40,'- ',A<field_length>)

40	Continue

100	Return
	END
