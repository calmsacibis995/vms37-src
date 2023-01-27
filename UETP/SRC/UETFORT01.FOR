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

C         ALCOA ENGINEERING STANDARDS -- 32.6.7.1            MAY, 1972          
C         TESTS OF STANDARD FORTRAN (ANSI X3.9-1966)                            
C         TEST 3.5.3.3                                                          
C                                                                               
	PROGRAM UETFORT01
      INTEGER A(10), B(5,5), C(4,4,4), S                                        
C*****                                                                          
      IPU=6                                                                     
      ICU=5                                                                     
C*****                                                                          
      ISW= 1                                                                    
      WRITE (IPU,376)                                                           
  376 FORMAT(1H1,33X,39H ALCOA ENGINEERING STANDARD -- 32.6.7.1///)             
      WRITE (IPU,378)                                                           
  378 FORMAT (20H BEGIN TEST 3.5.3.3 )                                          
      DO 9 I=1,10                                                               
9     A(I)= 0                                                                   
      DO 81 J=1,5                                                               
      DO 81 I=1,5                                                               
81    B(I,J)= 0                                                                 
      DO 20 K=1,4                                                               
      DO 20 J=1,4                                                               
      DO 20 I=1,4                                                               
20    C(I,J,K)=0                                                                
      S=1                                                                       
1     READ( ICU,11 ) I, A(I)                                                    
      IF( A(7) .NE. 7 ) GO TO 30                                                
      S=2                                                                       
2     READ( ICU,11 ) I,J, B(I,J )                                               
      IF( B(3,2) .NE. 8 ) GO TO 40                                              
      S=3                                                                       
3     READ(ICU,11 ) I,J,K, C( I,J,K )                                           
      IF( C(2,3,4) .NE. 58 ) GO TO 50                                           
      S=4                                                                       
200   DO 12 I=1,10                                                              
12    A(I)= 0                                                                   
4     READ( ICU,11 ) I,( A(L), L=1,I )                                          
      DO 13 I=1,10                                                              
      IF( A(I) .NE. I ) GO TO 30                                                
13    CONTINUE                                                                  
      S=5                                                                       
201   DO 14 J=1,5                                                               
      DO 14 I=1,5                                                               
14    B(I,J)= 0                                                                 
5     READ( ICU,11 ) I,J,(( B(L,M),L=1,I),M=1,J )                               
      DO 15 J=1,5                                                               
      DO 15 I=1,5                                                               
      IF( B(I,J) .NE. I+5*(J-1) ) GO TO 40                                      
15    CONTINUE                                                                  
      S=6                                                                       
202   DO 16 K=1,4                                                               
      DO 16 J=1,4                                                               
      DO 16 I=1,4                                                               
16    C(I,J,K)= 0                                                               
6     READ( ICU,11 ) I,J,K,((( C(L,M,N),L=1,I),M=1,J),N=1,K )                   
      DO 17 K=1,4                                                               
      DO 17 J=1,4                                                               
      DO 17 I=1,4                                                               
      IF( C(I,J,K) .NE. I+4*(J-1)+16*(K-1)  ) GO TO 50                          
17    CONTINUE                                                                  
      S=7                                                                       
203   DO 60 K=1,4                                                               
      DO 60 J=1,4                                                               
      DO 60 I=1,4                                                               
60    C(I,J,K)= 0                                                               
7     READ( ICU,11 ) I,J,K,C( 2*I, J-1, 3*K+1 )                                 
      IF( C(2,3,4) .NE. 58 )  GO TO 50                                          
      S=8                                                                       
205   DO 80 J=1,5                                                               
      DO 80 I=1,5                                                               
80    B(I,J)=0                                                                  
8     READ( ICU,11 ) I,J,( B(I,N), N=1,J )                                      
      DO 82 J=1,5                                                               
      IF( B(3,J) .NE. 3+5*(J-1) ) GO TO 40                                      
82    CONTINUE                                                                  
204   GO TO ( 18,19 ), ISW                                                      
18    WRITE (IPU,21)                                                            
21    FORMAT( 32H SUCESSFUL COMPLETION            )                             
19    WRITE (IPU,377)                                                           
  377 FORMAT (21H0END OF TEST 3.5.3.3 )                                         
      STOP                                                                      
30    WRITE (IPU,31) S,A                                                        
31    FORMAT( 19H0ERROR IN STATEMENT, I2 / 9H ARRAY A  /                        
     1 1H , 10I3  )                                                             
32    ISW= 2                                                                    
      S=S+1                                                                     
      GO TO ( 1,2,3,200,201,202,203,205,204 ), S                                
40    WRITE (IPU,41) S,B                                                        
 41   FORMAT (19H0ERROR IN STATEMENT,I2/9H ARRAY B ,(/                          
     11H ,20I3))                                                                
      GO TO 32                                                                  
50    WRITE (IPU,51) S,C                                                        
  51  FORMAT (19H0ERROR IN STATEMENT, I2/ 9H ARRAY C  ,(/                       
     11H ,20I3))                                                                
      GO TO 32                                                                  
11    FORMAT(  39I2 )                                                           
      END                                                                       
