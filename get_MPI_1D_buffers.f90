!=====================================================================
!
!          S p e c f e m 3 D  G l o b e  V e r s i o n  3 . 5
!          --------------------------------------------------
!
!                 Dimitri Komatitsch and Jeroen Tromp
!    Seismological Laboratory - California Institute of Technology
!        (c) California Institute of Technology July 2004
!
!    A signed non-commercial agreement is required to use this program.
!   Please check http://www.gps.caltech.edu/research/jtromp for details.
!           Free for non-commercial academic research ONLY.
!      This program is distributed WITHOUT ANY WARRANTY whatsoever.
!      Do not redistribute this program without written permission.
!
!=====================================================================

  subroutine get_MPI_1D_buffers(myrank,prname,nspec,iMPIcut_xi,iMPIcut_eta,ibool, &
                        idoubling,xstore,ystore,zstore,mask_ibool,npointot, &
                        NSPEC1D_RADIAL,NPOIN1D_RADIAL)

! routine to create the MPI 1D chunk buffers for edges

  implicit none

  include "constants.h"

  integer nspec,myrank
  integer NSPEC1D_RADIAL,NPOIN1D_RADIAL

  logical iMPIcut_xi(2,nspec)
  logical iMPIcut_eta(2,nspec)

  integer ibool(NGLLX,NGLLY,NGLLZ,nspec)

  integer idoubling(nspec)

  double precision xstore(NGLLX,NGLLY,NGLLZ,nspec)
  double precision ystore(NGLLX,NGLLY,NGLLZ,nspec)
  double precision zstore(NGLLX,NGLLY,NGLLZ,nspec)

! logical mask used to create arrays ibool1D
  integer npointot
  logical mask_ibool(npointot)

! global element numbering
  integer ispec

! MPI 1D buffer element numbering
  integer ispeccount,npoin1D,ix,iy,iz

! processor identification
  character(len=150) prname

! write the MPI buffers for the left and right edges of the slice
! and the position of the points to check that the buffers are fine

! *****************************************************************
! ****************** generate for eta = eta_min *******************
! *****************************************************************

! determine if the element falls on the left MPI cut plane

! global point number and coordinates left MPI 1D buffer
  open(unit=10,file=prname(1:len_trim(prname))//'ibool1D_leftxi_lefteta.txt',status='unknown')

! erase the logical mask used to mark points already found
  mask_ibool(:) = .false.

! nb of global points shared with the other slice
  npoin1D = 0

! nb of elements in this 1D buffer
  ispeccount=0

  do ispec=1,nspec

! remove central cube for chunk buffers
  if(idoubling(ispec) == IFLAG_IN_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_BOTTOM_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_TOP_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_IN_FICTITIOUS_CUBE) cycle

! corner detection here
  if(iMPIcut_xi(1,ispec) .and. iMPIcut_eta(1,ispec)) then

    ispeccount=ispeccount+1

! loop on all the points
  ix = 1
  iy = 1
  do iz=1,NGLLZ

! select point, if not already selected
  if(.not. mask_ibool(ibool(ix,iy,iz,ispec))) then
      mask_ibool(ibool(ix,iy,iz,ispec)) = .true.
      npoin1D = npoin1D + 1

      write(10,*) ibool(ix,iy,iz,ispec),xstore(ix,iy,iz,ispec), &
              ystore(ix,iy,iz,ispec),zstore(ix,iy,iz,ispec)
  endif

  enddo

  endif
  enddo

! put flag to indicate end of the list of points
  write(10,*) '0  0  0.  0.  0.'

! write total number of points
  write(10,*) npoin1D

  close(10)

! compare number of edge elements detected to analytical value
  if(ispeccount /= NSPEC1D_RADIAL .or. npoin1D /= NPOIN1D_RADIAL) &
    call exit_MPI(myrank,'error MPI 1D buffer detection in xi=left')

! determine if the element falls on the right MPI cut plane

! global point number and coordinates right MPI 1D buffer
  open(unit=10,file=prname(1:len_trim(prname))//'ibool1D_rightxi_lefteta.txt',status='unknown')

! erase the logical mask used to mark points already found
  mask_ibool(:) = .false.

! nb of global points shared with the other slice
  npoin1D = 0

! nb of elements in this 1D buffer
  ispeccount=0

  do ispec=1,nspec

! remove central cube for chunk buffers
  if(idoubling(ispec) == IFLAG_IN_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_BOTTOM_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_TOP_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_IN_FICTITIOUS_CUBE) cycle

! corner detection here
  if(iMPIcut_xi(2,ispec) .and. iMPIcut_eta(1,ispec)) then

    ispeccount=ispeccount+1

! loop on all the points
  ix = NGLLX
  iy = 1
  do iz=1,NGLLZ

! select point, if not already selected
  if(.not. mask_ibool(ibool(ix,iy,iz,ispec))) then
      mask_ibool(ibool(ix,iy,iz,ispec)) = .true.
      npoin1D = npoin1D + 1

      write(10,*) ibool(ix,iy,iz,ispec),xstore(ix,iy,iz,ispec), &
              ystore(ix,iy,iz,ispec),zstore(ix,iy,iz,ispec)
  endif

  enddo

  endif
  enddo

! put flag to indicate end of the list of points
  write(10,*) '0  0  0.  0.  0.'

! write total number of points
  write(10,*) npoin1D

  close(10)

! compare number of edge elements and points detected to analytical value
  if(ispeccount /= NSPEC1D_RADIAL .or. npoin1D /= NPOIN1D_RADIAL) &
    call exit_MPI(myrank,'error MPI 1D buffer detection in xi=right')

! *****************************************************************
! ****************** generate for eta = eta_max *******************
! *****************************************************************

! determine if the element falls on the left MPI cut plane

! global point number and coordinates left MPI 1D buffer
  open(unit=10,file=prname(1:len_trim(prname))//'ibool1D_leftxi_righteta.txt',status='unknown')

! erase the logical mask used to mark points already found
  mask_ibool(:) = .false.

! nb of global points shared with the other slice
  npoin1D = 0

! nb of elements in this 1D buffer
  ispeccount=0

  do ispec=1,nspec

! remove central cube for chunk buffers
  if(idoubling(ispec) == IFLAG_IN_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_BOTTOM_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_TOP_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_IN_FICTITIOUS_CUBE) cycle

! corner detection here
  if(iMPIcut_xi(1,ispec) .and. iMPIcut_eta(2,ispec)) then

    ispeccount=ispeccount+1

! loop on all the points
  ix = 1
  iy = NGLLY
  do iz=1,NGLLZ

! select point, if not already selected
  if(.not. mask_ibool(ibool(ix,iy,iz,ispec))) then
      mask_ibool(ibool(ix,iy,iz,ispec)) = .true.
      npoin1D = npoin1D + 1

      write(10,*) ibool(ix,iy,iz,ispec),xstore(ix,iy,iz,ispec), &
              ystore(ix,iy,iz,ispec),zstore(ix,iy,iz,ispec)
  endif

  enddo

  endif
  enddo

! put flag to indicate end of the list of points
  write(10,*) '0  0  0.  0.  0.'

! write total number of points
  write(10,*) npoin1D

  close(10)

! compare number of edge elements detected to analytical value
  if(ispeccount /= NSPEC1D_RADIAL .or. npoin1D /= NPOIN1D_RADIAL) &
    call exit_MPI(myrank,'error MPI 1D buffer detection in xi=left')

! determine if the element falls on the right MPI cut plane

! global point number and coordinates right MPI 1D buffer
  open(unit=10,file=prname(1:len_trim(prname))//'ibool1D_rightxi_righteta.txt',status='unknown')

! erase the logical mask used to mark points already found
  mask_ibool(:) = .false.

! nb of global points shared with the other slice
  npoin1D = 0

! nb of elements in this 1D buffer
  ispeccount=0

  do ispec=1,nspec

! remove central cube for chunk buffers
  if(idoubling(ispec) == IFLAG_IN_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_BOTTOM_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_TOP_CENTRAL_CUBE .or. &
     idoubling(ispec) == IFLAG_IN_FICTITIOUS_CUBE) cycle

! corner detection here
  if(iMPIcut_xi(2,ispec) .and. iMPIcut_eta(2,ispec)) then

    ispeccount=ispeccount+1

! loop on all the points
  ix = NGLLX
  iy = NGLLY
  do iz=1,NGLLZ

! select point, if not already selected
  if(.not. mask_ibool(ibool(ix,iy,iz,ispec))) then
      mask_ibool(ibool(ix,iy,iz,ispec)) = .true.
      npoin1D = npoin1D + 1

      write(10,*) ibool(ix,iy,iz,ispec),xstore(ix,iy,iz,ispec), &
              ystore(ix,iy,iz,ispec),zstore(ix,iy,iz,ispec)
  endif

  enddo

  endif
  enddo

! put flag to indicate end of the list of points
  write(10,*) '0  0  0.  0.  0.'

! write total number of points
  write(10,*) npoin1D

  close(10)

! compare number of edge elements and points detected to analytical value
  if(ispeccount /= NSPEC1D_RADIAL .or. npoin1D /= NPOIN1D_RADIAL) &
    call exit_MPI(myrank,'error MPI 1D buffer detection in xi=right')

  end subroutine get_MPI_1D_buffers

