!*******************************************************************************
!   Cassandra - An open source atomistic Monte Carlo software package
!   developed at the University of Notre Dame.
!   http://cassandra.nd.edu
!   Prof. Edward Maginn <ed@nd.edu>
!   Copyright (2013) University of Notre Dame du Lac
!
!   This program is free software: you can redistribute it and/or modify
!   it under the terms of the GNU General Public License as published by
!   the Free Software Foundation, either version 3 of the License, or
!   (at your option) any later version.
!
!   This program is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!   GNU General Public License for more details.
!
!   You should have received a copy of the GNU General Public License
!   along with this program.  If not, see <http://www.gnu.org/licenses/>.
!*******************************************************************************

MODULE XTC_Routines
  !************************************************************************
  !
  !**************************************************************************
  USE Global_Variables
  USE File_Names
  USE Simulation_Properties
  USE IO_Utilities
  USE GMXFORT_TRAJECTORY

  IMPLICIT NONE

  TYPE(Trajectory), DIMENSION(:), ALLOCATABLE :: trj
  INTEGER, DIMENSION(:), ALLOCATABLE :: iframe, chunkframes
  INTEGER, PARAMETER :: nframes_per_chunk = 100

CONTAINS

  SUBROUTINE Open_XTC(ibox)
          INTEGER :: ibox

          IF (.NOT. ALLOCATED(trj)) ALLOCATE(trj(nbr_boxes))
          IF (.NOT. ALLOCATED(iframe)) ALLOCATE(iframe(nbr_boxes))
          IF (.NOT. ALLOCATED(chunkframes)) ALLOCATE(chunkframes(nbr_boxes))
          iframe(ibox) = 0
          chunkframes(ibox) = 0
          CALL trj(ibox)%OPEN(pregen_xtc_filenames(ibox))
          xtc_is_open(ibox) = .TRUE.

          IF (trj(ibox)%NATOMS() .NE. natoms_to_read(ibox)) THEN
                  err_msg = ""
                  err_msg(1) = "Trying to read different number of atoms than stored in xtc file."
                  err_msg(2) = Int_To_String(natoms_to_read(ibox))
                  err_msg(3) = Int_To_String(trj(ibox)%NATOMS())
                  CALL Clean_Abort(err_msg, "Open_XTC")
          END IF

  END SUBROUTINE Open_XTC

  SUBROUTINE Close_XTC(ibox)
          INTEGER :: ibox

          CALL trj(ibox)%CLOSE()
          xtc_is_open(ibox) = .FALSE.

  END SUBROUTINE Close_XTC

  FUNCTION Skip_XTC_Frames(ibox,nframes)
          INTEGER :: Skip_XTC_Frames
          INTEGER :: ibox, nframes, i

          DO i = 1, nframes
                IF (Read_XTC_Frame(ibox)) EXIT
          END DO
          Skip_XTC_Frames = i-1

  END FUNCTION Skip_XTC_Frames

  FUNCTION Read_XTC_Frame(ibox)
          LOGICAL :: Read_XTC_Frame
          INTEGER :: ibox

          IF (.NOT. xtc_is_open(ibox)) CALL Open_XTC(ibox)
          iframe(ibox) = iframe(ibox) + 1
          IF (iframe(ibox) > chunkframes(ibox)) THEN
                  iframe(ibox) = 1
                  chunkframes(ibox) = trj(ibox)%READ_NEXT(nframes_per_chunk)
          END IF

          Read_XTC_Frame = chunkframes(ibox) < 1

  END FUNCTION Read_XTC_Frame

  FUNCTION Get_XTC_Coords(ibox)
          INTEGER :: ibox
          REAL(DP), DIMENSION(natoms_to_read(ibox),3) :: Get_XTC_Coords
          INTEGER :: i, j

          j = iframe(ibox)

          !$OMP PARALLEL DO DEFAULT(SHARED) SCHEDULE(STATIC)
          DO i = 1, natoms_to_read(ibox)
                Get_XTC_Coords(i,:) = trj(ibox)%x(j,i) * 10.0_DP
          END DO
          !$OMP END PARALLEL DO

  END FUNCTION Get_XTC_Coords

  FUNCTION Get_XTC_Box(ibox)
          INTEGER :: ibox
          REAL(DP), DIMENSION(3,3) :: Get_XTC_Box

          Get_XTC_Box = trj(ibox)%box(iframe(ibox)) * 10.0_DP

  END FUNCTION Get_XTC_Box




!*******************************************************************************

END MODULE XTC_Routines

