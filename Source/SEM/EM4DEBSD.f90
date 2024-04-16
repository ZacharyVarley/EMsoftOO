! ###################################################################
! Copyright (c) 2016-2024, Marc De Graef Research Group/Carnegie Mellon University
! All rights reserved.
!
! Redistribution and use in source and binary forms, with or without modification, are 
! permitted provided that the following conditions are met:
!
!     - Redistributions of source code must retain the above copyright notice, this list 
!        of conditions and the following disclaimer.
!     - Redistributions in binary form must reproduce the above copyright notice, this 
!        list of conditions and the following disclaimer in the documentation and/or 
!        other materials provided with the distribution.
!     - Neither the names of Marc De Graef, Carnegie Mellon University nor the names 
!        of its contributors may be used to endorse or promote products derived from 
!        this software without specific prior written permission.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
! AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
! IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
! ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
! LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
! DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
! SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
! CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
! OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
! USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
! ###################################################################

program EM4DEBSD
  !! author: MDG
  !! version: 1.0 
  !! date: 06/05/23
  !!
  !! Generate a set of EBSD patterns for a scan across an ROI containing defects
  !! The output patterns can then be used to obtain ECCI-type images

use mod_kinds
use mod_global
use mod_EMsoft
use mod_4DEBSD
use mod_HDFnames
use stringconstants

IMPLICIT NONE

character(fnlen)     :: progname = 'EM4DEBSD.f90'
character(fnlen)     :: progdesc = 'Generate EBSD patterns for a scan across an ROI containing defects'

type(EMsoft_T)       :: EMsoft
type(EBSD4D_T)       :: EBSD4D
type(HDFnames_T)     :: HDFnames

logical              :: doconvolution

! print the EMsoft header and handle any command line arguments  
EMsoft = EMsoft_T( progname, progdesc, tpl = (/ 140 /) )

! deal with the namelist stuff
EBSD4D = EBSD4D_T(EMsoft%nmldeffile)

HDFnames = HDFnames_T() 
call HDFnames%set_ProgramData(SC_EBSD4D) 
call HDFnames%set_NMLlist(SC_EBSD4DNameList) 
call HDFnames%set_NMLfilename(SC_EBSD4DNML) 

! perform the computations
doconvolution = EBSD4D%getdoconvolution()
if (doconvolution.eqv..TRUE.) then 
  call EBSD4D%EBSD4Dconvol(EMsoft, progname, HDFnames)
else
  call EBSD4D%EBSD4D(EMsoft, progname, HDFnames)
end if

end program EM4DEBSD
