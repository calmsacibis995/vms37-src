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


	common	opcode

	character*15	opcodes('00'x:'ff'x)

	data		opcodes('0'x)	/'HALT*'/

	data		opcodes('1'x)	/'NOP*'/

	data		opcodes('2'x)	/'REI*'/

	data		opcodes('3'x)	/'BPT*'/

	data		opcodes('4'x)	/'RET*'/

	data		opcodes('5'x)	/'RSB*'/

	data		opcodes('6'x)	/'LDPCTX*'/

	data		opcodes('7'x)	/'SVPCTX*'/

	data		opcodes('8'x)	/'CVTPS*'/

	data		opcodes('9'x)	/'CVTSP*'/

	data		opcodes('A'x)	/'INDEX*'/

	data		opcodes('B'x)	/'CRC*'/

	data		opcodes('C'x)	/'PROBER*'/

	data		opcodes('D'x)	/'PROBEW*'/

	data		opcodes('E'x)	/'INSQUE*'/

	data		opcodes('F'x)	/'REMQUE*'/

	data		opcodes('10'x)	/'BSBB*'/

	data		opcodes('11'x)	/'BRB*'/

	data		opcodes('12'x)	/'BNEQ, BNEQU*'/

	data		opcodes('13'x)	/'BEQL, BEQLU*'/

	data		opcodes('14'x)	/'BGTR*'/

	data		opcodes('15'x)	/'BLEQ*'/

	data		opcodes('16'x)	/'JSB*'/

	data		opcodes('17'x)	/'JMP*'/

	data		opcodes('18'x)	/'BGEQ*'/

	data		opcodes('19'x)	/'BLSS*'/

	data		opcodes('1A'x)	/'BGTRU*'/

	data		opcodes('1B'x)	/'BLEQU*'/

	data		opcodes('1C'x)	/'BVC*'/

	data		opcodes('1D'x)	/'BVS*'/

	data		opcodes('1E'x)	/'BGEQU, BCC*'/

	data		opcodes('1F'x)	/'BLSSU, BCS*'/

	data		opcodes('20'x)	/'ADDP4*'/

	data		opcodes('21'x)	/'ADDP6*'/

	data		opcodes('22'x)	/'SUBP4*'/

	data		opcodes('23'x)	/'SUBP6*'/

	data		opcodes('24'x)	/'CVTPT*'/

	data		opcodes('25'x)	/'MULP*'/

	data		opcodes('26'x)	/'CVTTP*'/

	data		opcodes('27'x)	/'DIVP*'/

	data		opcodes('28'x)	/'MOVC3*'/

	data		opcodes('29'x)	/'CMPC3*'/

	data		opcodes('2A'x)	/'SCANC*'/

	data		opcodes('2B'x)	/'SPANC*'/

	data		opcodes('2C'x)	/'MOVC5*'/

	data		opcodes('2D'x)	/'CMPC5*'/

	data		opcodes('2E'x)	/'MOVTC*'/

	data		opcodes('2F'x)	/'MOVTUC*'/

	data		opcodes('30'x)	/'BSBW*'/

	data		opcodes('31'x)	/'BRW*'/

	data		opcodes('32'x)	/'CVTWL*'/

	data		opcodes('33'x)	/'CVTWB*'/

	data		opcodes('34'x)	/'MOVP*'/

	data		opcodes('35'x)	/'CMPP3*'/

	data		opcodes('36'x)	/'CVTPL*'/

	data		opcodes('37'x)	/'CMPP4*'/

	data		opcodes('38'x)	/'EDITPC*'/

	data		opcodes('39'x)	/'MATCHC*'/

	data		opcodes('3A'x)	/'LOCC*'/

	data		opcodes('3B'x)	/'SKPC*'/

	data		opcodes('3C'x)	/'MOVZWL*'/

	data		opcodes('3D'x)	/'ACBW*'/

	data		opcodes('3E'x)	/'MOVAW*'/

	data		opcodes('3F'x)	/'PUSHAW*'/

	data		opcodes('40'x)	/'ADDF2*'/

	data		opcodes('41'x)	/'ADDF3*'/

	data		opcodes('42'x)	/'SUBF2*'/

	data		opcodes('43'x)	/'SUBF3*'/

	data		opcodes('44'x)	/'MULF2*'/

	data		opcodes('45'x)	/'MULF3*'/

	data		opcodes('46'x)	/'DIVF2*'/

	data		opcodes('47'x)	/'DIVF3*'/

	data		opcodes('48'x)	/'CVTFB*'/

	data		opcodes('49'x)	/'CVTFW*'/

	data		opcodes('4A'x)	/'CVTFL*'/

	data		opcodes('4B'x)	/'CVTRFL*'/

	data		opcodes('4C'x)	/'CVTBF*'/

	data		opcodes('4D'x)	/'CVTWF*'/

	data		opcodes('4E'x)	/'CVTLF*'/

	data		opcodes('4F'x)	/'ACBF*'/

	data		opcodes('50'x)	/'MOVF*'/

	data		opcodes('51'x)	/'CMPF*'/

	data		opcodes('52'x)	/'MNEGF*'/

	data		opcodes('53'x)	/'TSTF*'/

	data		opcodes('54'x)	/'EMODF*'/

	data		opcodes('55'x)	/'CVTFD*'/

	data		opcodes('56'x)	/'RESERVED*'/

	data		opcodes('57'x)	/'ADAWI*'/

	data		opcodes('58'x)	/'RESERVED*'/

	data		opcodes('59'x)	/'RESERVED*'/

	data		opcodes('5A'x)	/'RESERVED*'/

	data		opcodes('5B'x)	/'RESERVED*'/

	data		opcodes('5C'x)	/'INSQHI*'/

	data		opcodes('5D'x)	/'INSQTI*'/

	data		opcodes('5E'x)	/'REMQHI*'/

	data		opcodes('5F'x)	/'REMQTI*'/

	data		opcodes('60'x)	/'ADDD2*'/

	data		opcodes('61'x)	/'ADDD3*'/

	data		opcodes('62'x)	/'SUBD2*'/

	data		opcodes('63'x)	/'SUBD3*'/

	data		opcodes('64'x)	/'MULD2*'/

	data		opcodes('65'x)	/'MULD3*'/

	data		opcodes('66'x)	/'DIVD2*'/

	data		opcodes('67'x)	/'DIVD3*'/

	data		opcodes('68'x)	/'CVTDB*'/

	data		opcodes('69'x)	/'CVTDW*'/

	data		opcodes('6A'x)	/'CVTDL*'/

	data		opcodes('6B'x)	/'CVTRDL*'/

	data		opcodes('6C'x)	/'CVTBD*'/

	data		opcodes('6D'x)	/'CVTWD*'/

	data		opcodes('6E'x)	/'CVTLD*'/

	data		opcodes('6F'x)	/'ACBD*'/

	data		opcodes('70'x)	/'MOVD*'/

	data		opcodes('71'x)	/'CMPD*'/

	data		opcodes('72'x)	/'MNEGD*'/

	data		opcodes('73'x)	/'TSTD*'/

	data		opcodes('74'x)	/'EMODD*'/

	data		opcodes('75'x)	/'POLYD*'/

	data		opcodes('76'x)	/'CVTDF*'/

	data		opcodes('77'x)	/'RESERVED*'/

	data		opcodes('78'x)	/'ASHL*'/

	data		opcodes('79'x)	/'ASHQ*'/

	data		opcodes('7A'x)	/'EMUL*'/

	data		opcodes('7B'x)	/'EDIV*'/

	data		opcodes('7C'x)	/'CLRQ, CLRD*'/

	data		opcodes('7D'x)	/'MOVQ*'/

	data		opcodes('7E'x)	/'MOVAQ, MOVAD*'/

	data		opcodes('7F'x)	/'PUSHAQ, PUSHAD*'/

	data		opcodes('80'x)	/'ADDB2*'/

	data		opcodes('81'x)	/'ADDB3*'/

	data		opcodes('82'x)	/'SUBB2*'/

	data		opcodes('83'x)	/'SUBB3*'/

	data		opcodes('84'x)	/'MULB2*'/

	data		opcodes('85'x)	/'MULB3*'/

	data		opcodes('86'x)	/'DIVB2*'/

	data		opcodes('87'x)	/'DIVB3*'/

	data		opcodes('88'x)	/'BISB2*'/

	data		opcodes('89'x)	/'BISB3*'/

	data		opcodes('8A'x)	/'BICB2*'/

	data		opcodes('8B'x)	/'BICB3*'/

	data		opcodes('8C'x)	/'xORB2*'/

	data		opcodes('8D'x)	/'xORB3*'/

	data		opcodes('8E'x)	/'MNEGB*'/

	data		opcodes('8F'x)	/'CASEB*'/

	data		opcodes('90'x)	/'MOVB*'/

	data		opcodes('91'x)	/'CMPB*'/

	data		opcodes('92'x)	/'MCOMB*'/

	data		opcodes('93'x)	/'BITB*'/

	data		opcodes('94'x)	/'CLRB*'/

	data		opcodes('95'x)	/'TSTB*'/

	data		opcodes('96'x)	/'INCB*'/

	data		opcodes('97'x)	/'DECB*'/

	data		opcodes('98'x)	/'CVTBL*'/

	data		opcodes('99'x)	/'CVTBW*'/

	data		opcodes('9A'x)	/'MOVZBL*'/

	data		opcodes('9B'x)	/'MOVZBW*'/

	data		opcodes('9C'x)	/'ROTL*'/

	data		opcodes('9D'x)	/'ACBB*'/

	data		opcodes('9E'x)	/'MOVAB*'/

	data		opcodes('9F'x)	/'PUSHAB*'/

	data		opcodes('A0'x)	/'ADDW2*'/

	data		opcodes('A1'x)	/'ADDW3*'/

	data		opcodes('A2'x)	/'SUBW2*'/

	data		opcodes('A3'x)	/'SUBW3*'/

	data		opcodes('A4'x)	/'MULW2*'/

	data		opcodes('A5'x)	/'MULW3*'/

	data		opcodes('A6'x)	/'DIVW2*'/

	data		opcodes('A7'x)	/'DIVW3*'/

	data		opcodes('A8'x)	/'BISW2*'/

	data		opcodes('A9'x)	/'BISW3*'/

	data		opcodes('AA'x)	/'BICW2*'/

	data		opcodes('AB'x)	/'BICW3*'/

	data		opcodes('AC'x)	/'xORW2*'/

	data		opcodes('AD'x)	/'xORW3*'/

	data		opcodes('AE'x)	/'MNEGW*'/

	data		opcodes('AF'x)	/'CASEW*'/

	data		opcodes('B0'x)	/'MOVW*'/

	data		opcodes('B1'x)	/'CMPW*'/

	data		opcodes('B2'x)	/'MCOMW*'/

	data		opcodes('B3'x)	/'BITW*'/

	data		opcodes('B4'x)	/'CLRW*'/

	data		opcodes('B5'x)	/'TSTW*'/

	data		opcodes('B6'x)	/'INCW*'/

	data		opcodes('B7'x)	/'DECW*'/

	data		opcodes('B8'x)	/'BISPSW*'/

	data		opcodes('B9'x)	/'BICPSW*'/

	data		opcodes('BA'x)	/'POPR*'/

	data		opcodes('BB'x)	/'PUSHR*'/

	data		opcodes('BC'x)	/'CHMK*'/

	data		opcodes('BD'x)	/'CHME*'/

	data		opcodes('BE'x)	/'CHMS*'/

	data		opcodes('BF'x)	/'CHMU*'/

	data		opcodes('C0'x)	/'ADDL2*'/

	data		opcodes('C1'x)	/'ADDL3*'/

	data		opcodes('C2'x)	/'SUBL2*'/

	data		opcodes('C3'x)	/'SUBL3*'/

	data		opcodes('C4'x)	/'MULL2*'/

	data		opcodes('C5'x)	/'MULL3*'/

	data		opcodes('C6'x)	/'DIVL2*'/

	data		opcodes('C7'x)	/'DIVL3*'/

	data		opcodes('C8'x)	/'BISL2*'/

	data		opcodes('C9'x)	/'BISL3*'/

	data		opcodes('CA'x)	/'BICL2*'/

	data		opcodes('CB'x)	/'BICL3*'/

	data		opcodes('CC'x)	/'xORL2*'/

	data		opcodes('CD'x)	/'xORL3*'/

	data		opcodes('CE'x)	/'MNEGL*'/

	data		opcodes('CF'x)	/'CASEL*'/

	data		opcodes('D0'x)	/'MOVL*'/

	data		opcodes('D1'x)	/'CMPL*'/

	data		opcodes('D2'x)	/'MCOML*'/

	data		opcodes('D3'x)	/'BITL*'/

	data		opcodes('D4'x)	/'CLRL, CLRF*'/

	data		opcodes('D5'x)	/'TSTL*'/

	data		opcodes('D6'x)	/'INCL*'/

	data		opcodes('D7'x)	/'DECL*'/

	data		opcodes('D8'x)	/'ADWC*'/

	data		opcodes('D9'x)	/'SBWC*'/

	data		opcodes('DA'x)	/'MTPR*'/

	data		opcodes('DB'x)	/'MFPR*'/

	data		opcodes('DC'x)	/'MOVPSL*'/

	data		opcodes('DD'x)	/'PUSHL*'/

	data		opcodes('DE'x)	/'MOVAL, MOVAF*'/

	data		opcodes('DF'x)	/'PUSHAL, PUSHAF*'/

	data		opcodes('E0'x)	/'BBS*'/

	data		opcodes('E1'x)	/'BBC*'/

	data		opcodes('E2'x)	/'BBSS*'/

	data		opcodes('E3'x)	/'BBCS*'/

	data		opcodes('E4'x)	/'BBSC*'/

	data		opcodes('E5'x)	/'BBCC*'/

	data		opcodes('E6'x)	/'BBSSI*'/

	data		opcodes('E7'x)	/'BBCCI*'/

	data		opcodes('E8'x)	/'BLBS*'/

	data		opcodes('E9'x)	/'BLBC*'/

	data		opcodes('EA'x)	/'FFS*'/

	data		opcodes('EB'x)	/'FFC*'/

	data		opcodes('EC'x)	/'CMPV*'/

	data		opcodes('ED'x)	/'CMPZV*'/

	data		opcodes('EE'x)	/'EXTV*'/

	data		opcodes('EF'x)	/'EXTZV*'/

	data		opcodes('F0'x)	/'INSV*'/

	data		opcodes('F1'x)	/'ACBL*'/

	data		opcodes('F2'x)	/'AOBLSS*'/

	data		opcodes('F3'x)	/'AOBLEQ*'/

	data		opcodes('F4'x)	/'SOBGEQ*'/

	data		opcodes('F5'x)	/'SOBGTR*'/

	data		opcodes('F6'x)	/'CVTLB*'/

	data		opcodes('F7'x)	/'CVTLW*'/

	data		opcodes('F8'x)	/'ASHP*'/

	data		opcodes('F9'x)	/'CVTLP*'/

	data		opcodes('FA'x)	/'CALLG*'/

	data		opcodes('FB'x)	/'CALLS*'/

	data		opcodes('FC'x)	/'xFC*'/

	data		opcodes('FD'x)	/'ESCD*'/

	data		opcodes('FE'x)	/'ESCE*'/

	data		opcodes('FF'x)	/'ESCF*'/

	common	/opcode/opcodes
