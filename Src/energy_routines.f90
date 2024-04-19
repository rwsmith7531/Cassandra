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

MODULE Energy_Routines
  !-----------------------------------------------------------------------------
  ! This modules contains a collection of all the routines involved in computing
  ! energies and associated quantities.
  !
  ! Compute_Molecule_Bond_Energy: passed a molecule and species index, this
  !                       returns the total bond energy associated with that
  !                       molecule
  !                       Currently supports none and harmonic.
  !
  ! Compute_Molecule_Angle_Energy: Passed a molecule and species index, it
  !                       returns the total energy of that molecule due to bond
  !                       angles.
  !                       Currently supports none and harmonic.
  !
  ! Compute_Molecule_Dihedral_Energy: Passed a molecule and species index, it
  !                       returns the total dihedral energy of that molecule.
  !                       Currently supports none and OPLS.
  !
  ! Compute_Molecule_Improper_Energy: Passed molecule and species indices, this
  !                       computes the total improper energy of the molecule.
  !                       Not yet tested!!!
  !                       Currently supports harmonic.
  !
  ! Compute_Atom_Nonbond_Energy: passed indices of an atom, molecule and
  !                       species, this returns the vdw and either direct
  !                       charge-charge or the real space part of the Ewald
  !                       energy of this atom with all existing atoms in the
  !                       system. It accounts for intramolecular scaling of 1-2,
  !                       1-3 and 1-4.
  !
  !                       Supports vdw_style = none or LJ
  !                       For LJ, it supports rcut, cut_tail and cut_shift,
  !                       though TAIL CORRECTIONS HAVE NOT YET BEEN ADDED.
  !                       LJ is assumed to be 12-6 LJ.
  !
  !                       Supports charge_style none or coul.
  !                       For charge_style = coul, it supports rcut and Ewald is
  !                       roughed in. However, the Ewald parts of the code need
  !                       some thought, especially in light of computing energy
  !                       differences. This routine also returns the virial
  !                       contribution. It needs more testing, but I believe it
  !                       works.
  !
  ! Compute_Molecule_Nonbond_Intra_Energy: passed molecule and species indices,
  !                       returns the intramolecular LJ and electrostatic energy
  !                       of the molecule.
  !
  ! Compute_Molecule_Nonbond_Inter_Energy: passed molecule and species indices,
  !                       returns the intermolecular LJ and electrostatic energy
  !                       between this molecule and all other molecules in the
  !                       system.
  !
  ! Compute_MoleculePair_Energy:
  ! Compute_MoleculePair_Force:
  !                       Computes the intermolecular energy/force between a
  !                       pair of input molecules.
  !
  ! Compute_AtomPair_Energy:
  ! Compute_AtomPair_Force:
  !                       Computes the vdw and q-q pair energy/force between i
  !                       atoms ia and ja of molecules im and jm of species is
  !                       and js, given their separation rijsq. I have passed
  !                       each component of separation nut right now this is
  !                       unnecessary.
  !                       It also computes the real space part of the Ewald sum
  !                       if necessary.
  !
  !                       LJ potential:
  !                         Eij = 4*epsilon(i,j) *
  !                                 [ (sigma(i,j)/rij)^12 - (sigma(i,j)/rij)^6 ]
  !                         Wij = -rij/3 * d Eij / d rij.
  !                         Use the virial in: P = NkBT + < W >
  !
  ! Compute_AtomPair_Ewald_Real: Real space part of Ewald sum. Need to add
  !                       reciprocal, self and energy difference sin and cos
  !                       sums. Contains erfc function.
  !
  ! Ewald_Reciprocal_Lattice_Vector_Setup : Sets up lattice vectors for Ewald
  !                       Summation for the input box.
  !
  ! Compute_System_Ewald_Reciprocal_Energy:
  ! Compute_System_Ewald_Reciprocal_Force:
  !                       Computes reciprocal space energy/force for a given box
  !
  ! Update_System_Ewald_Reciprocal_Energy:
  !                       Updates the
  !                       reciprocal space energy due to various moves. The
  !                       routine makes use of the fact that for a given move,
  !                       the coordinates of only one molecule are perturbed.
  !                       Hence cos_sum and sin_sum arrays can be computed by
  !                       taking differences of q_i cos(k * r_i) terms in new
  !                       and old configurations.
  !
  ! Compute_System_Ewald_Self_Energy: Calculation of self energy for the Ewald
  !                       summation is obtained from this subroutine.
  !
  ! Compute_Molecule_Ewald_Self_Energy: Computes the self energy of the given
  !                       molecule.
  !
  ! Compute_System_Total_Energy:
  ! Compute_System_Total_Force:
  !                       Computes the total system energy/forces within a given
  !                       box. Forces are then used to compute the pressure
  !                       tensor.
  !
  ! Compute_LR_Correction:
  ! Compute_LR_Force:
  !                       Determines long range correction when the flag is set
  !                       to 'cut_tail'.
  !
  ! Check_MoleculePair_Cutoff:
  !
  ! Check_AtomPair_Cutoff:
  !
  ! Get_Molecule_Energy: Computes the intra- and inter-molecular energy of
  !                       a given molecule interacting with all other molecules.
  !
  ! Compute_Ring_Fragment_Energy: Computes the energy of a ring fragment in its
  !                       old conformation.
  !
  ! Check_System_Energy:
  !
  !
  !
  !
  ! Used by
  !
  !   angle_distortion
  !   atom_displacement
  !   chempot
  !   cutNgrow
  !   deletion
  !   fragment_growth
  !   gcmc_control
  !   gcmc_driver
  !   gemc_control
  !   gemc_driver
  !
  !   gemc_particle_transfer
  !   make_config
  !   input_routines
  !   insertion
  !   main
  !   nptmc_control
  !   nptmc_driver
  !   nvtmc_control
  !   nvtmc_driver
  !   nvt_mc_fragment_driver
  !   nvt_mc_ring_fragment
  !   precalculate
  !   rotate
  !   translate
  !   volume_change
  !   write_properties
  !
  ! Revision history
  !
  !   12/10/13  : Beta Release
  !-----------------------------------------------------------------------------

  USE Type_Definitions
  USE Global_Variables
  USE File_Names
  USE Pair_Nrg_Routines
  USE IO_Utilities
  USE Internal_Coordinate_Routines
 !$  USE OMP_LIB

  IMPLICIT NONE

  INTEGER, PARAMETER :: kxyz_max_allowed = 1023

CONTAINS

  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_Molecule_Bond_Energy(im,is,energy)

    !**************************************************************************
    ! This subroutine computes the total bond energy of a selected molecule
    ! Currently, the available potential functions are none or harmonic.
    ! If none, the code will do a check for fixed bond lengths.
    !
    ! As of now, the code can only support fixed bond length simulations.
    ! Effectively, this subroutine will act as a check for fixed bond length
    ! (useful if using a restart configuration from other packages)
    !
    ! CALLED BY
    !
    !         Compute_System_Total_Energy.
    !         Angle_Distortion
    !         Deletion
    !         Rotate_Dihedral
    !         Insertion
    !         GEMC_Particle_Transfer
    !         Cut_N_Grow
    !
    ! CALLS
    !
    !         Get_Bond_Length
    !
    ! INPUT VARIABLES
    !
    !         im[INTEGER]:     LOCATE of the molecule.
    !         is[INTEGER]:     species type of the molecule.
    !
    ! OUTPUT VARIABLES
    !
    !         energy[REALDP]: total bond energy of molecule
    !
    ! RAISES
    !         It will throw an error if bond lenghts do not match
    !         the MCF specifications within a tolerance.
    !
    !
    ! DOCUMENTATION LAST UPDATED: 08/10/2016
    !
    !**************************************************************************


    INTEGER :: im,is
    REAL(DP) :: energy
    INTEGER :: ib
    REAL(DP) :: length
    REAL(DP) :: k,l0,eb,ltol
    CHARACTER(7) :: mcf_bond_length, current_bond_length
  !-----------------------------------------------------------------------------
    energy = 0.0_DP
    DO ib=1,nbonds(is)
       IF (bond_list(ib,is)%int_bond_type == int_none) THEN
          l0 = bond_list(ib,is)%bond_param(1)
          ltol = bond_list(ib,is)%bond_param(2)
          CALL Get_Bond_Length(ib,im,is,length)
          IF ((int_sim_type /= sim_pregen) .AND. (abs(l0 - length) > ltol)) THEN
             WRITE(mcf_bond_length,'(F7.3)') l0
             WRITE(current_bond_length,'(F7.3)') length
             err_msg = ''
             err_msg(1) = 'Fixed bond is broken between atoms ' &
                        // TRIM(Int_To_String(bond_list(ib,is)%atom(1))) // ' and ' &
                        // TRIM(Int_To_String(bond_list(ib,is)%atom(2))) &
                        // ' of molecule ' // TRIM(Int_To_String(im)) &
                        // ' of species ' // TRIM(Int_To_String(is))
             err_msg(2) = 'Bond length in MCF:  ' // mcf_bond_length
             err_msg(3) = 'Current bond length: ' // current_bond_length
             CALL Clean_Abort(err_msg, 'Compute_Molecule_Bond_Energy')
          END IF
          eb = 0.0_DP
       ELSEIF (bond_list(ib,is)%int_bond_type == int_harmonic) THEN
          k=bond_list(ib,is)%bond_param(1)
          l0 = bond_list(ib,is)%bond_param(2)
          CALL Get_Bond_Length(ib,im,is,length)
          eb = k*(length-l0)**2

       ENDIF
       energy = energy + eb
    ENDDO


  END SUBROUTINE Compute_Molecule_Bond_Energy
  !-----------------------------------------------------------------------------


  SUBROUTINE Compute_Molecule_Angle_Energy(im,is,energy)
    !**************************************************************************
    ! This subroutine is passed a molecule and species index. It then
    ! computes the total bond angle energy of this molecule.
    !
    ! Currently, the available potential functions are none or harmonic.
    ! If none, the code will do a check for fixed angles.
    !
    ! INPUT VARIABLES
    !
    !         im[INTEGER]:     LOCATE of the molecule.
    !         is[INTEGER]:     species type of the molecule.
    !
    ! OUTPUT VARIABLES
    !
    !         energy[REALDP]:      total bond energy of molecule
    !
    ! RAISES
    !         It will throw an error if angles do not match
    !         the MCF specifications within a tolerance.
    !
    !
    ! DOCUMENTATION LAST UPDATED: 08/10/2016
    !**************************************************************************

    USE Random_Generators
    INTEGER :: im,is
    REAL(DP) :: energy
    INTEGER :: ia
    REAL(DP) :: k,theta0,theta,ea,theta_tol
    CHARACTER (7) :: mcf_angle, current_angle

    energy = 0.0_DP
    DO ia=1,nangles(is)
       IF (angle_list(ia,is)%int_angle_type == int_none) THEN
          theta0 = angle_list(ia,is)%angle_param(1) ! in degrees
          theta_tol = angle_list(ia,is)%angle_param(2) ! in degrees
          CALL Get_Bond_Angle(ia,im,is,theta)
          theta = theta * 180.0_DP / PI
          IF (abs(theta0 - theta) > theta_tol) THEN
             WRITE(mcf_angle,'(F7.3)') theta0
             WRITE(current_angle,'(F7.3)') theta
             err_msg = ''
             err_msg(1) = 'Fixed angle is broken between atoms ' &
                        // TRIM(Int_To_String(angle_list(ia,is)%atom(1))) // ' and ' &
                        // TRIM(Int_To_String(angle_list(ia,is)%atom(2))) // ' and ' &
                        // TRIM(Int_To_String(angle_list(ia,is)%atom(3))) &
                        // ' of molecule ' // TRIM(Int_To_String(im)) &
                        // ' of species ' // TRIM(Int_To_String(is))
             err_msg(2) = 'Angle in MCF:  ' // mcf_angle
             err_msg(3) = 'Current angle: ' // current_angle
             CALL Clean_Abort(err_msg, 'Compute_Molecule_Angle_Energy')
          END IF
          ea = 0.0_DP
       ELSEIF (angle_list(ia,is)%int_angle_type == int_harmonic) THEN
          k=angle_list(ia,is)%angle_param(1)
          theta0 = angle_list(ia,is)%angle_param(2)
          CALL Get_Bond_Angle(ia,im,is,theta)
          ea = k*(theta-theta0)**2
          ! Add more potential functions here.
       ENDIF
       energy = energy + ea
    ENDDO

  END SUBROUTINE Compute_Molecule_Angle_Energy
  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_Molecule_Dihedral_Energy(molecule,species,energy_dihed)
    !**************************************************************************
    ! This routine is passed a molecule and species index. It then computes
    !the total dihedral angle energy of this molecule.
    !
    ! Currently, the available potential functions are OPLS, CHARMM, harmonic,
    ! and none.
    !
    ! INPUT VARIABLES
    !
    !         im[INTEGER]:     LOCATE of the molecule.
    !         is[INTEGER]:     species type of the molecule.
    !
    ! OUTPUT VARIABLES
    !
    !         energy[REALDP]:      total dihedral energy of molecule
    !
    ! RAISES
    !
    ! DOCUMENTATION LAST UPDATED: 08/10/2016
    !**************************************************************************
  USE Global_Variables
    INTEGER :: molecule,species
    REAL(DP) :: energy_dihed
    INTEGER :: idihed, idihed_rb, atom1, atom2, atom3, atom4
    REAL(DP) :: a0,a1,a2,a3,a4,a5,a6,a7,a8,edihed,phi,cosphi,r12dn,twophi,threephi
    REAL(DP) :: cosphi_vec(0:5)

    TYPE(Atom_Class), POINTER, CONTIGUOUS :: these_atoms(:)

    IF (widom_active) THEN
            these_atoms => widom_atoms
    ELSE
            these_atoms => atom_list(:,molecule,species)
    END IF

    energy_dihed = 0.0_DP
    cosphi_vec = 0.0_DP
    cosphi_vec(0) = 1.0_DP
    DO idihed_rb = 1, species_list(species)%ndihedrals_rb
        IF (.NOT. ALL(these_atoms(dihedral_list(idihed_rb,species)%atom)%exist)) CYCLE
        CALL Get_Dihedral_Angle_COS(idihed_rb,molecule,species,cosphi_vec(1))
        cosphi_vec(2) = cosphi_vec(1)*cosphi_vec(1)
        cosphi_vec(3) = cosphi_vec(1)*cosphi_vec(2)
        cosphi_vec(4) = cosphi_vec(2)*cosphi_vec(2)
        cosphi_vec(5) = cosphi_vec(2)*cosphi_vec(3)
        energy_dihed = energy_dihed + DOT_PRODUCT(cosphi_vec,dihedral_list(idihed_rb,species)%rb_c)
    END DO
    DO idihed=idihed_rb, species_list(species)%ndihedrals_energetic
       ! Verify that the atoms of this dihedral exist. This is required
       ! for CBMC moves in which only a part of the molecule is present in
       ! the simulation
       IF (.NOT. ALL(these_atoms(dihedral_list(idihed,species)%atom)%exist)) CYCLE
       CALL Get_Dihedral_Angle_COS(idihed,molecule,species,cosphi,r12dn)
       phi = SIGN(ACOS(cosphi), r12dn)
       SELECT CASE(dihedral_list(idihed,species)%int_dipot_type)
       CASE(int_opls)
          ! Note: this case should never occur now that all OPLS dihedrals are internally converted to RB torsions
          ! However, I left it here anyway just in case that changes somehow.
          IF (.NOT. ALL(these_atoms(dihedral_list(idihed,species)%atom)%exist)) CYCLE
          a0 = dihedral_list(idihed,species)%dihedral_param(1)
          a1 = dihedral_list(idihed,species)%dihedral_param(2)
          a2 = dihedral_list(idihed,species)%dihedral_param(3)
          a3 = dihedral_list(idihed,species)%dihedral_param(4)

          twophi = 2.0_DP*phi
          threephi = 3.0_DP*phi
          edihed =  a0 + a1*(1.0_DP+COS(phi)) + &
               a2*(1.0_DP-COS(twophi)) + a3*(1.0_DP+COS(threephi))
       CASE(int_charmm)
          ! Check to see if the atoms of this dihedral exists. This is required
          ! for CBMC moves in which only a part of the molecule is present in
          ! the simulation
          IF (.NOT. ALL(these_atoms(dihedral_list(idihed,species)%atom)%exist)) CYCLE

          a0 = dihedral_list(idihed,species)%dihedral_param(1)
          a1 = dihedral_list(idihed,species)%dihedral_param(2)
          a2 = dihedral_list(idihed,species)%dihedral_param(3)

          edihed = a0 * (1.0_DP + DCOS(a1*phi - a2))

       CASE(int_harmonic)
          IF (.NOT. ALL(these_atoms(dihedral_list(idihed,species)%atom)%exist)) CYCLE

          a0 = dihedral_list(idihed,species)%dihedral_param(1)
          a1 = dihedral_list(idihed,species)%dihedral_param(2)

          IF(a1 .GT. 0.0_DP .AND. phi .LT.0) phi = phi + twoPI

          edihed = a0 * (phi - a1)**2

          ! Add more potential functions here.
       END SELECT
       energy_dihed = energy_dihed + edihed
    ENDDO


  END SUBROUTINE Compute_Molecule_Dihedral_Energy
  !-----------------------------------------------------------------------------


  SUBROUTINE Compute_Molecule_Improper_Energy(molecule,species,energy)
    !**************************************************************************
    ! This routine is passed the molecule and species index, and returns the
    ! total improper energy of that molecule. Only "none" and "harmonic" types
    ! are supported.
    !
    ! INPUT VARIABLES
    !
    !         im[INTEGER]:     LOCATE of the molecule.
    !         is[INTEGER]:     species type of the molecule.
    !
    ! OUTPUT VARIABLES
    !
    !         energy[REALDP]:      total dihedral energy of molecule
    !
    ! RAISES
    !
    ! DOCUMENTATION LAST UPDATED: 08/10/2016
    !**************************************************************************
    INTEGER :: molecule,species,iimprop
    REAL(DP) :: energy
    REAL(DP) :: eimprop,k,phi0,phi,n_imp,d_imp
    energy = 0.0_DP
    DO iimprop=1,nimpropers(species)
       IF (improper_list(iimprop,species)%int_improp_type == int_none) THEN
          eimprop = 0.0_DP
       ELSEIF (improper_list(iimprop,species)%int_improp_type == int_harmonic) THEN
          k = improper_list(iimprop,species)%improper_param(1)
          phi0 = improper_list(iimprop,species)%improper_param(2)
          CALL Get_Improper_Angle(iimprop,molecule,species,phi)
          eimprop = k*(phi-phi0)**2
       ELSEIF (improper_list(iimprop,species)%int_improp_type == int_cvff) THEN
          k = improper_list(iimprop,species)%improper_param(1)
          d_imp = improper_list(iimprop,species)%improper_param(2)
          n_imp = improper_list(iimprop,species)%improper_param(3)
          CALL Get_Improper_Angle(iimprop,molecule,species,phi)
          eimprop = k*(1.0_DP + d_imp*DCOS(n_imp*phi))
       ELSE
          err_msg = ""
          err_msg(1) = "Unable to compute improper energy"
          CALL Clean_Abort(err_msg,'Compute_Molecular_Improper_Energy')
       ENDIF
       energy = energy + eimprop
    ENDDO

  END SUBROUTINE Compute_Molecule_Improper_Energy
  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_Atom_Nonbond_Energy(ia,im,is, &
       E_intra_vdw,E_inter_vdw,E_intra_qq,E_inter_qq,overlap)

    !**************************************************************************
    ! Computes the energy components between one particular atom and ALL others
    ! in its box, accounting for exclusions, scalings and existence. It returns
    ! energy components.
    !
    !
    ! Note that the VDW energy (without LRC) is returned as is the real space
    ! part of the q-q interactions (for Ewald and DSF). These two contributions
    ! are categorized into intra or intermolecular energy.
    !
    ! INPUT VARIABLES
    !
    !         ia[INTEGER]:         atom number
    !         im[INTEGER]:     LOCATE of the molecule.
    !         is[INTEGER]:      species type of the molecule.
    !
    ! OUTPUT VARIABLES
    !
    !         E_intra_vdw[REALDP]:        Intramolecular vdw energy of atom
    !         E_inter_vdw[REALDP]:        Intermolecular vdw energy of atom
    !         E_intra_qq[REALDP]:         Intramolecular qq energy of atom
    !         E_inter_qq[REALDP]:         Intermolecular qq energy of atom
    !         Overlap[LOGICAL]:           Flag that gets triggered if atom
    !                                     has a core overlap with another
    !
    ! RAISES
    !
    ! DOCUMENTATION LAST UPDATED: 08/10/2016
    !**************************************************************************


    INTEGER, INTENT(IN) :: ia,im,is
    REAL(DP), INTENT(OUT) :: E_intra_vdw,E_inter_vdw,E_intra_qq,E_inter_qq
    LOGICAL, INTENT(OUT) :: overlap
    INTEGER :: this_box,js,jm,ja, mol_js, itype, jtype, rinteraction, vdw_in
    REAL(DP) :: rxij,ryij,rzij,rijsq,rxijp,ryijp,rzijp
    REAL(DP) :: Eij_intra_vdw,Eij_inter_vdw,Eij_intra_qq,Eij_inter_qq
    REAL(DP) :: eps, sig, SigOverRsq, SigOverR6, SigOverR12
    REAL(DP) :: rij, erf_val, erfc_val, qsc
    REAL(DP) :: T, x, xsq, TP
    REAL(DP) :: rcom,rx,ry,rz
    REAL(DP) :: rcut, rcutsq
    REAL(DP) :: SigOverR, SigOverRn, SigOverRm, mie_coeff,  mie_n, mie_m

    LOGICAL :: get_vdw,get_qq, get_interaction

    REAL(DP), PARAMETER :: A1 = 0.254829592_DP, A2 = -0.284496736_DP
    REAL(DP), PARAMETER :: A3 = 1.421413741_DP, A4 = -1.453152027_DP
    REAL(DP), PARAMETER :: A5 = 1.061405429_DP, P = 0.3275911_DP

    TYPE(Molecule_Class), POINTER :: this_molecule_i, this_molecule_j
    TYPE(Atom_Class), POINTER :: these_atoms_i(:), these_atoms_j(:)

    IF (widom_active) THEN 
            this_molecule_i => widom_molecule
            these_atoms_i => widom_atoms
    ELSE
            this_molecule_i => molecule_list(im,is)
            these_atoms_i => atom_list(:,im,is)
    END IF

    !---------------------------------------------------------------------------
    E_inter_vdw = 0.0_DP
    E_intra_vdw = 0.0_DP
    E_inter_qq = 0.0_DP
    E_intra_qq = 0.0_DP
    Eij_inter_vdw = 0.0_DP
    Eij_intra_vdw = 0.0_DP
    Eij_inter_qq = 0.0_DP
    Eij_intra_qq = 0.0_DP

    ! Check that ia exists
    IF (.NOT. these_atoms_i(ia)%exist ) THEN
       err_msg = ""
       err_msg(1) = 'Attempt to compute energy of an atom that does not exist'
       CALL Clean_Abort(err_msg,'Compute_Atom_Nonbond_Energy')
    ENDIF

    ! Set the box number this particular atom is in.
    this_box = this_molecule_i%which_box

    ! Initialize flags which force a call to pair_energy
    get_vdw = .FALSE.
    get_qq = .FALSE.

    ! Initialize the overlap flag to false to indicate no overlap between atoms.
    overlap = .FALSE.

    SpeciesLoop:DO js=1,nspecies

       MoleculeLoop:DO mol_js=1,nmols(js,this_box)

          jm = locate(mol_js,js,this_box) ! molecule INDEX
          IF (jm == widom_locate .AND. js == widom_species) THEN
                  this_molecule_j => widom_molecule
                  these_atoms_j => widom_atoms
          ELSE
                  this_molecule_j => molecule_list(jm,js)
                  these_atoms_j => atom_list(:,jm,js)
          END IF
          IF (.NOT. this_molecule_j%live) CYCLE MoleculeLoop

          ! Check tos see if atom is to interact with the molecule based
          ! on COM cutoff.
          CALL Check_MoleculePair_Cutoff(jm,js,im,is, &
               get_interaction,rcom,rx,ry,rz)

          IF (.NOT. get_interaction) CYCLE MoleculeLoop

          AtomLoop:DO ja=1,natoms(js)
             ! Test for intramolecular interaction
             IF (.NOT. these_atoms_j(ja)%exist ) CYCLE AtomLoop
             IF (js == is .AND. jm == im) THEN

                IF (ja == ia) THEN
                   ! Avoid computing energy with self
                   CYCLE AtomLoop
                ELSE
                   ! Intra energy. Do not apply PBC
                   IF ( .NOT. these_atoms_j(ja)%exist) CYCLE AtomLoop

                   ! Interatomic distance
                   rxij = these_atoms_j(ja)%rxp &
                        - these_atoms_i(ia)%rxp
                   ryij = these_atoms_j(ja)%ryp &
                        - these_atoms_i(ia)%ryp
                   rzij = these_atoms_j(ja)%rzp &
                        - these_atoms_i(ia)%rzp

                   rijsq = rxij*rxij + ryij*ryij + rzij*rzij

                   IF (rijsq <= rcut_lowsq) THEN
                      IF (.not.(l_bonded(ja,ia,js))) THEN
                         overlap = .true.
                         RETURN
                      ENDIF
                   END IF
                ENDIF

             ELSE
                ! Intermolecular energy so apply pbc.

                ! First compute the parent separation
                rxijp = these_atoms_j(ja)%rxp &
                      - these_atoms_i(ia)%rxp
                ryijp = these_atoms_j(ja)%ryp &
                      - these_atoms_i(ia)%ryp
                rzijp = these_atoms_j(ja)%rzp &
                      - these_atoms_i(ia)%rzp

                ! Now get the minimum image separation
                CALL Minimum_Image_Separation(this_box,rxijp,ryijp,rzijp, &
                     rxij,ryij,rzij)

                rijsq = rxij*rxij + ryij*ryij + rzij*rzij

                IF (rijsq < rcut_lowsq) THEN
                   overlap = .true.
                   RETURN
                END IF

             ENDIF

             CALL Check_AtomPair_Cutoff(rijsq,get_vdw,get_qq,this_box)

             ! Compute vdw and q-q energy using if required
             IF (get_vdw .OR. get_qq) THEN

                CALL Compute_AtomPair_Energy(rxij,ryij,rzij,rijsq, &
                     js,jm,ja,is,im,ia,&
                     get_vdw,get_qq, &
                     Eij_intra_vdw,Eij_intra_qq,Eij_inter_vdw,Eij_inter_qq)

                E_intra_vdw = E_intra_vdw + Eij_intra_vdw
                E_intra_qq  = E_intra_qq  + Eij_intra_qq
                E_inter_vdw = E_inter_vdw + Eij_inter_vdw
                E_inter_qq  = E_inter_qq  + Eij_inter_qq
             ENDIF

          END DO AtomLoop

       END DO MoleculeLoop

    END DO SpeciesLoop

  END SUBROUTINE Compute_Atom_Nonbond_Energy

  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_Atom_Nonbond_Intra_Energy(ia,im,is, &
                  E_intra_vdw,E_intra_qq,E_inter_qq,overlap)
          INTEGER, INTENT(IN) :: ia,im,is
          REAL(DP), INTENT(OUT) :: E_intra_vdw, E_intra_qq, E_inter_qq
          LOGICAL, INTENT(OUT) :: overlap
          TYPE(Atom_Class), DIMENSION(:), POINTER :: these_atoms
          INTEGER :: ja, this_box
          LOGICAL :: get_vdw, get_qq, nonzero_vdw, nonzero_qq
          REAL(DP) :: Eij_intra_vdw, Eij_intra_qq, Eij_inter_vdw, Eij_inter_qq
          REAL(DP) :: rxij, ryij, rzij, rijsq
          E_intra_vdw = 0.0_DP
          E_intra_qq = 0.0_DP
          E_inter_qq = 0.0_DP
          overlap = .TRUE.
          IF (widom_active) THEN
                  these_atoms => widom_atoms
          ELSE
                  these_atoms => atom_list(:,im,is)
          END IF
          this_box = molecule_list(im,is)%which_box
          DO ja = 1, natoms(is)
                IF (ja == ia .OR. .NOT. these_atoms(ja)%exist) CYCLE
                nonzero_vdw = vdw_intra_scale(ia,ja,is) > 0.0_DP 
                nonzero_qq = charge_intra_scale(ia,ja,is) > 0.0_DP 
                IF (.NOT. (nonzero_vdw .OR. nonzero_qq)) CYCLE
                rxij = these_atoms(ja)%rxp - these_atoms(ia)%rxp
                ryij = these_atoms(ja)%ryp - these_atoms(ia)%ryp
                rzij = these_atoms(ja)%rzp - these_atoms(ia)%rzp
                !CALL Minimum_Image_Separation(this_box,rxijp,ryijp,rzijp,rxij,ryij,rzij)
                rijsq = rxij*rxij+ryij*ryij+rzij*rzij
                IF (rijsq < rcut_lowsq .AND. nonzero_vdw) RETURN
                CALL Check_AtomPair_Cutoff(rijsq,get_vdw,get_qq,this_box)
                get_vdw = get_vdw .AND. nonzero_vdw
                get_qq = get_qq .AND. nonzero_qq
                ! Compute vdw and q-q energy if required
                IF (get_vdw .OR. get_qq) THEN
                   CALL Compute_AtomPair_Energy(rxij,ryij,rzij,rijsq, &
                        is,im,ja,is,im,ia,&
                        get_vdw,get_qq, &
                        Eij_intra_vdw,Eij_intra_qq,Eij_inter_vdw,Eij_inter_qq)
                   E_intra_vdw = E_intra_vdw + Eij_intra_vdw
                   E_intra_qq  = E_intra_qq  + Eij_intra_qq
                   E_inter_qq = E_inter_qq + Eij_inter_qq
                ENDIF
          END DO
          overlap = .FALSE.
  END SUBROUTINE Compute_Atom_Nonbond_Intra_Energy

  !-----------------------------------------------------------------------------

!  SUBROUTINE Compute_Atom_Nonbond_Inter_Energy_Cells(ia,im,is, &
!       E_inter_vdw,E_inter_qq)
!        INTEGER, INTENT(IN) :: ia,im,is
!        REAL(DP), INTENT(OUT):: E_inter_vdw, E_inter_qq
!        REAL(DP) :: Eij_intra_vdw, Eij_intra_qq, Eij_inter_vdw, Eij_inter_qq
!        INTEGER :: grid_length(3), this_box, i
!        INTEGER, DIMENSION(:), POINTER :: xi, yi, zi, thisrange_cells, sector_atom_ID, these_cells
!        INTEGER :: dummy_ind, dummy, n_cells_occupied, icell, ia_cell, cell_coords(3), secind
!        !LOGICAL, DIMENSION(:,:,:), POINTER :: filtered_mask, this_mask
!        LOGICAL :: get_vdw, get_qq
!        REAL(DP) :: rijsq, rxijp, ryijp, rzijp, rxij, ryij, rzij, cp(3)
!        TYPE(Atom_Class), POINTER :: atom_ptr
!        INTEGER, DIMENSION(:), POINTER :: this_yb
!        INTEGER, DIMENSION(:,:), POINTER :: this_zb
!        INTEGER :: ix, iy, iz, iy_c, iz_c
!        E_inter_vdw = 0.0_DP
!        E_inter_qq = 0.0_DP
!        IF (widom_active) THEN
!                cp(1) = widom_atoms(ia)%rxp
!                cp(2) = widom_atoms(ia)%ryp
!                cp(3) = widom_atoms(ia)%rzp
!                this_box = widom_molecule%which_box
!        ELSE
!                cp(1) = atom_list(ia,im,is)%rxp
!                cp(2) = atom_list(ia,im,is)%ryp
!                cp(3) = atom_list(ia,im,is)%rzp
!                this_box = molecule_list(im,is)%which_box
!        END IF
!        IF (cbmc_flag) THEN
!                thisrange_cells => cbmcrange_cells(:,this_box)
!!                this_mask => cbmc_mask(-thisrange_cells(1):thisrange_cells(1), &
!!                        -thisrange_cells(2):thisrange_cells(2), &
!!                        -thisrange_cells(3):thisrange_cells(3), &
!!                        this_box)
!                this_yb => cbmc_yb(this_box, -thisrange_cells(1):thisrange_cells(1))
!                this_zb => cbmc_zb(this_box, -thisrange_cells(1):thisrange_cells(1), &
!                        -thisrange_cells(2):thisrange_cells(2))
!        ELSE
!                thisrange_cells => cutrange_cells(:,this_box)
!!                this_mask => cut_mask(-thisrange_cells(1):thisrange_cells(1), &
!!                        -thisrange_cells(2):thisrange_cells(2), &
!!                        -thisrange_cells(3):thisrange_cells(3), &
!!                        this_box)
!                this_yb => cut_yb(this_box, -thisrange_cells(1):thisrange_cells(1))
!                this_zb => cut_zb(this_box, -thisrange_cells(1):thisrange_cells(1), &
!                        -thisrange_cells(2):thisrange_cells(2))
!        END IF
!        grid_length = thisrange_cells*2+1
!        !filtered_mask => filtered_mask_super(1:grid_length(1),1:grid_length(2),1:grid_length(3))
!        cell_coords = IDNINT(cp*cell_length_inv(:,this_box))
!        xi => ci_grid(1,1:grid_length(1))
!        yi => ci_grid(2,1:grid_length(2))
!        zi => ci_grid(3,1:grid_length(3))
!        dummy = cell_coords(1) - thisrange_cells(1)
!        DO i = 1, grid_length(1)
!                xi(i) = dummy
!                dummy = dummy + 1
!        END DO
!        dummy = cell_coords(2) - thisrange_cells(2)
!        DO i = 1, grid_length(2)
!                yi(i) = dummy
!                dummy = dummy + 1
!        END DO
!        dummy = cell_coords(3) - thisrange_cells(3)
!        DO i = 1, grid_length(3)
!                zi(i) = dummy
!                dummy = dummy + 1
!        END DO
!        IF (cell_coords(1)+thisrange_cells(1)>sectorbound(1,this_box)) THEN
!                dummy_ind = grid_length(1) + 1 - (cell_coords(1)+thisrange_cells(1)-sectorbound(1,this_box))
!                xi(dummy_ind:grid_length(1)) = xi(dummy_ind:grid_length(1)) - length_cells(1,this_box)
!        ELSE IF (cell_coords(1)-thisrange_cells(1)<-sectorbound(1,this_box)) THEN
!                dummy_ind = thisrange_cells(1)-sectorbound(1,this_box) - cell_coords(1)
!                xi(1:dummy_ind) = xi(1:dummy_ind) + length_cells(1,this_box)
!        END IF
!        IF (cell_coords(2)+thisrange_cells(2)>sectorbound(2,this_box)) THEN
!                dummy_ind = grid_length(2) + 1 - (cell_coords(2)+thisrange_cells(2)-sectorbound(2,this_box))
!                yi(dummy_ind:grid_length(2)) = yi(dummy_ind:grid_length(2)) - length_cells(2,this_box)
!        ELSE IF (cell_coords(2)-thisrange_cells(2)<-sectorbound(2,this_box)) THEN
!                dummy_ind = thisrange_cells(2)-sectorbound(2,this_box) - cell_coords(2)
!                yi(1:dummy_ind) = yi(1:dummy_ind) + length_cells(2,this_box)
!        END IF
!        IF (cell_coords(3)+thisrange_cells(3)>sectorbound(3,this_box)) THEN
!                dummy_ind = grid_length(3) + 1 - (cell_coords(3)+thisrange_cells(3)-sectorbound(3,this_box))
!                zi(dummy_ind:grid_length(3)) = zi(dummy_ind:grid_length(3)) - length_cells(3,this_box)
!        ELSE IF (cell_coords(3)-thisrange_cells(3)<-sectorbound(3,this_box)) THEN
!                dummy_ind = thisrange_cells(3)-sectorbound(3,this_box) - cell_coords(3)
!                zi(1:dummy_ind) = zi(1:dummy_ind) + length_cells(3,this_box)
!        END IF
!!        filtered_mask = sector_has_atoms(xi,yi,zi,this_box) .AND. this_mask
!!        n_cells_occupied = COUNT(filtered_mask)
!!        these_cells => cell_index_vector(1:n_cells_occupied)
!!        these_cells = PACK(sector_index_map(xi,yi,zi,this_box),filtered_mask)
!!        DO icell = 1, n_cells_occupied
!!                secind = these_cells(icell)
!        iy_c = 1+thisrange_cells(2)
!        iz_c = 1+thisrange_cells(3)
!        DO ix = 1, grid_length(1)
!                DO iy = iy_c-this_yb(ix), iy_c+this_yb(ix)
!                        DO iz = iz_c - this_zb(ix,iy), iz_c+this_zb(ix,iy)
!                                IF (.NOT. sector_has_atoms(xi(ix),yi(iy),zi(iz),this_box)) CYCLE
!                                secind = sector_index_map(xi(ix),yi(iy),zi(iz),this_box)
!                                DO ia_cell = 1, sector_n_atoms(secind)
!                                        sector_atom_ID => sector_atoms(ia_cell,secind,:)
!                                        IF (sector_atom_ID(2) == im .AND. sector_atom_ID(3) == is) CYCLE
!                                        atom_ptr => atom_list(sector_atom_ID(1),sector_atom_ID(2),sector_atom_ID(3))
!                                        rxijp = atom_ptr%rxp - cp(1)
!                                        ryijp = atom_ptr%ryp - cp(2)
!                                        rzijp = atom_ptr%rzp - cp(3)
!                                        CALL Minimum_Image_Separation(this_box,rxijp,ryijp,rzijp,rxij,ryij,rzij)
!                                        rijsq = rxij*rxij+ryij*ryij+rzij*rzij
!                                        CALL Check_AtomPair_Cutoff(rijsq,get_vdw,get_qq,this_box)
!                                        ! Compute vdw and q-q energy using if required
!                                        IF (get_vdw .OR. get_qq) THEN
!                                           CALL Compute_AtomPair_Energy(rxij,ryij,rzij,rijsq, &
!                                                sector_atom_ID(3),sector_atom_ID(2),sector_atom_ID(1),is,im,ia,&
!                                                get_vdw,get_qq, &
!                                                Eij_intra_vdw,Eij_intra_qq,Eij_inter_vdw,Eij_inter_qq)
!                                           E_inter_vdw = E_inter_vdw + Eij_inter_vdw
!                                           E_inter_qq  = E_inter_qq  + Eij_inter_qq
!                                        END IF
!                                END DO
!                        END DO
!                END DO
!        END DO
!!        END DO
!  END SUBROUTINE Compute_Atom_Nonbond_Inter_Energy_Cells

  !-----------------------------------------------------------------------------
  SUBROUTINE Compute_Atom_Nonbond_Inter_Energy_Cells(ia,im,is, &
                  E_inter_vdw, E_inter_qq, overlap, Eij_qq)
          !
          INTEGER, INTENT(IN) :: ia, im, is
          REAL(DP), INTENT(OUT) :: E_inter_vdw, E_inter_qq
          REAL(DP), INTENT(OUT), OPTIONAL :: Eij_qq
          REAL(DP) :: Eij_qq_temp
          INTEGER :: this_box
          INTEGER :: this_locate, i_dim, secind
          INTEGER :: xi, yi, zi, i, ia_cell
          INTEGER, DIMENSION(:), POINTER :: sector_atom_ID
          !INTEGER, DIMENSION(:,:,:), POINTER :: sector_index_map_ptr
          TYPE(Atom_Class), POINTER :: atom_ptr
          INTEGER :: cell_coords(3)
          INTEGER, DIMENSION(3) :: ci_min, ci_max
          REAL(DP) :: cp(3), dx, dy, dz, dxp, dyp, dzp, rijsq
          REAL(DP) :: Eij_intra_vdw,Eij_intra_qq,Eij_inter_vdw,Eij_inter_qq
          REAL(DP), DIMENSION(:), POINTER :: cell_length_inv_ptr
          LOGICAL :: get_vdw, get_qq, overlap
          !
          overlap = .TRUE.
          E_inter_vdw = 0.0_DP
          E_inter_qq = 0.0_DP
          Eij_qq_temp = 0.0_DP
          IF (widom_active) THEN
                  cp(1) = widom_atoms(ia)%rxp
                  cp(2) = widom_atoms(ia)%ryp
                  cp(3) = widom_atoms(ia)%rzp
                  this_box = widom_molecule%which_box
          ELSE
                  cp(1) = atom_list(ia,im,is)%rxp
                  cp(2) = atom_list(ia,im,is)%ryp
                  cp(3) = atom_list(ia,im,is)%rzp
                  this_box = molecule_list(im,is)%which_box
          END IF
          IF (cbmc_flag) THEN
                  cell_length_inv_ptr => cell_length_inv_cbmc(:,this_box)
          ELSE
                  cell_length_inv_ptr => cell_length_inv_full(:,this_box)
          END IF
          cell_coords = IDNINT(cp*cell_length_inv_ptr)
          ci_min = cell_coords - 1
          ci_max = cell_coords + 1
          IF (cbmc_flag) THEN
                  DO xi = ci_min(1), ci_max(1)
                        DO yi = ci_min(2), ci_max(2)
                                DO zi = ci_min(3), ci_max(3)
                                        secind = sector_index_map_cbmc(xi,yi,zi,this_box)
                                        DO ia_cell = 1, sector_n_atoms_cbmc(secind)
                                                sector_atom_ID => sector_atoms_cbmc(ia_cell,secind,:)
                                                atom_ptr => atom_list(sector_atom_ID(1),sector_atom_ID(2),sector_atom_ID(3))
                                                dxp = atom_ptr%rxp - cp(1)
                                                dyp = atom_ptr%ryp - cp(2)
                                                dzp = atom_ptr%rzp - cp(3)
                                                CALL Minimum_Image_Separation(this_box,dxp,dyp,dzp,dx,dy,dz)
                                                rijsq = dx*dx+dy*dy+dz*dz
                                                CALL Check_AtomPair_Cutoff(rijsq,get_vdw,get_qq,this_box)
                                                IF (get_vdw .OR. get_qq) THEN
                                                   IF (rijsq < rcut_lowsq) RETURN
                                                   CALL Compute_AtomPair_Energy(dx,dy,dz,rijsq, &
                                                        sector_atom_ID(3),sector_atom_ID(2),sector_atom_ID(1),is,im,ia,&
                                                        get_vdw,get_qq, &
                                                        Eij_intra_vdw,Eij_intra_qq,Eij_inter_vdw,Eij_inter_qq)
                                                   E_inter_vdw = E_inter_vdw + Eij_inter_vdw
                                                   E_inter_qq  = E_inter_qq  + Eij_inter_qq
                                                END IF
                                        END DO
                                END DO
                        END DO
                  END DO
          ELSE
                  DO xi = ci_min(1), ci_max(1)
                        DO yi = ci_min(2), ci_max(2)
                                DO zi = ci_min(3), ci_max(3)
                                        secind = sector_index_map_full(xi,yi,zi,this_box)
                                        DO ia_cell = 1, sector_n_atoms_full(secind)
                                                sector_atom_ID => sector_atoms_full(ia_cell,secind,:)
                                                atom_ptr => atom_list(sector_atom_ID(1),sector_atom_ID(2),sector_atom_ID(3))
                                                dxp = atom_ptr%rxp - cp(1)
                                                dyp = atom_ptr%ryp - cp(2)
                                                dzp = atom_ptr%rzp - cp(3)
                                                CALL Minimum_Image_Separation(this_box,dxp,dyp,dzp,dx,dy,dz)
                                                rijsq = dx*dx+dy*dy+dz*dz
                                                CALL Check_AtomPair_Cutoff(rijsq,get_vdw,get_qq,this_box)
                                                IF (get_vdw .OR. get_qq) THEN
                                                   IF (rijsq < rcut_lowsq) RETURN
                                                   CALL Compute_AtomPair_Energy(dx,dy,dz,rijsq, &
                                                        sector_atom_ID(3),sector_atom_ID(2),sector_atom_ID(1),is,im,ia,&
                                                        get_vdw,get_qq, &
                                                        Eij_intra_vdw,Eij_intra_qq,Eij_inter_vdw,Eij_inter_qq)
                                                   E_inter_vdw = E_inter_vdw + Eij_inter_vdw
                                                   E_inter_qq  = E_inter_qq  + Eij_inter_qq
                                                   IF (PRESENT(Eij_qq)) THEN
                                                           IF (widom_active) THEN
                                                                   Eij_max = MAX(Eij_max,Eij_inter_vdw+Eij_qq)
                                                           END IF
                                                           Eij_qq_temp = Eij_qq_temp + Eij_qq
                                                   END IF
                                                END IF
                                        END DO
                                END DO
                        END DO
                  END DO
          END IF
          Eij_qq = Eij_qq_temp
          overlap = .FALSE.
          

  END SUBROUTINE Compute_Atom_Nonbond_Inter_Energy_Cells

  SUBROUTINE Compute_Molecule_Nonbond_Intra_Energy(im,is, &
    E_intra_vdw,E_intra_qq,E_inter_qq,intra_overlap)
    !---------------------------------------------------------------------------
    ! The subroutine calculates the intramolecular LJ potential energy and
    ! electrostatic energy of an entire molecule. The routine takes care of
    ! double counting by looping only over i+1 to natoms for ith atom interaction.
    !
    ! Only the minimum image electrostatic energy is stored in E_intra_qq. The
    ! periodic image electrostatic energy is stored in E_inter_qq.
    !
    ! CALLS
    !
    ! Compute_AtomPair_Energy
    !
    ! CALLED BY
    !
    ! Rotate_Dihedral
    ! Angle_Distortion
    !
    !
    ! Written by Jindal Shah on 12/05/07
    !***************************************************************************

    IMPLICIT NONE

    INTEGER :: ia, ja, im, is, this_box

    REAL(DP) :: E_intra_vdw, E_intra_qq, E_inter_qq
    REAL(DP) :: rxij, ryij, rzij, rijsq
    REAL(DP) :: E_intra_vdw_old, E_intra_qq_old
    REAL(DP) :: Eij_intra_vdw, Eij_intra_qq, Eij_inter_vdw, Eij_inter_qq

    LOGICAL :: get_vdw, get_qq, intra_overlap

    TYPE(Atom_Class), POINTER :: these_atoms(:)

    IF (widom_active) THEN
            these_atoms => widom_atoms
    ELSE
            these_atoms => atom_list(:,im,is)
    END IF

    E_intra_vdw = 0.0_DP
    E_intra_qq = 0.0_DP
    E_inter_qq = 0.0_DP
    E_intra_vdw_old = 0.0_DP
    E_intra_qq_old = 0.0_DP

    ! loop over all the atoms in a molecule

    this_box = molecule_list(im,is)%which_box

    DO ia = 1, natoms(is)

       ! check to see if this atom exists
       ! Note 'im' is the linked number of the molecule of interest i.e locate(molecule,is)
       ! The checking for existence of a molecule may be unneccessary.

       IF ( these_atoms(ia)%exist) THEN

          DO ja = ia+1,natoms(is)

             ! make sure that the atom is present

             IF ( .NOT. these_atoms(ja)%exist) CYCLE

             ! Find distance between this atom and all others in the system
             rxij = these_atoms(ia)%rxp - these_atoms(ja)%rxp
             ryij = these_atoms(ia)%ryp - these_atoms(ja)%ryp
             rzij = these_atoms(ia)%rzp - these_atoms(ja)%rzp

             rijsq = rxij*rxij + ryij*ryij + rzij*rzij

             IF (rijsq <= rcut_lowsq) THEN
                IF (.not.(l_bonded(ia,ja,is))) THEN
                   intra_overlap = .true.
                   RETURN
                ENDIF
             END IF

             CALL Check_AtomPair_Cutoff(rijsq,get_vdw,get_qq,this_box)

             IF(cbmc_flag.and.species_list(is)%L_Coul_CBMC) THEN
                get_qq=.false.
             ENDIF

             ! Compute vdw and q-q energy using if required
             IF (get_vdw .OR. get_qq) THEN

                CALL Compute_AtomPair_Energy(rxij,ryij,rzij,rijsq, &
                   is,im,ia,is,im,ja,get_vdw,get_qq, &
                   Eij_intra_vdw,Eij_intra_qq,Eij_inter_vdw,Eij_inter_qq)

                E_intra_vdw = E_intra_vdw + Eij_intra_vdw
                E_intra_qq  = E_intra_qq + Eij_intra_qq
                E_inter_qq  = E_inter_qq + Eij_inter_qq

             END IF

          END DO

       END IF

    END DO

  END SUBROUTINE Compute_Molecule_Nonbond_Intra_Energy
  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_Molecule_Nonbond_Inter_Energy(im,is, &
    E_inter_vdw,E_inter_qq,overlap)
    !***************************************************************************
    ! This subroutine computes interatomic LJ and charge interactions as well as
    ! virials associated with these interactions.
    !
    ! CALLS
    !
    ! Minimum_Image_Separation
    ! Compute_MoleculePair_Energy
    ! Clean_Abort
    !
    ! CALLED BY
    !
    ! Translate
    ! Rotation
    ! Rotate_Dihedral
    ! Angle_Distortion
    ! Insertion
    ! Deletion
    ! Reaction
    !
    ! Written by Jindal Shah on 12/07/07
    !***************************************************************************

    IMPLICIT NONE

!    !$ include 'omp_lib.h'

    INTEGER, INTENT(IN):: im, is
    REAL(DP), INTENT(OUT) :: E_inter_vdw, E_inter_qq
    LOGICAL :: overlap
    !---------------------------------------------------------------------------

    INTEGER  :: ispecies, imolecule, this_box, this_locate

    REAL(DP) :: Eij_vdw, Eij_qq
    REAL(DP) :: eps
    REAL(DP) :: rcom, rx, ry, rz

    LOGICAL :: get_interaction

    INTEGER :: locate_1, locate_2

    LOGICAL :: l_pair_store
    LOGICAL :: my_overlap, shared_overlap

    E_inter_vdw = 0.0_DP
    E_inter_qq = 0.0_DP
    overlap = .FALSE.
    my_overlap = .FALSE.
    shared_overlap = .FALSE.

    this_box = molecule_list(im,is)%which_box

    l_pair_store = .FALSE.

    IF (l_pair_nrg .AND. (.NOT. cbmc_flag)) l_pair_store = .TRUE.

    IF (l_pair_store) CALL Get_Position_Alive(im,is,locate_1)

    speciesLoop: DO ispecies = 1, nspecies

       !$OMP PARALLEL DO DEFAULT(SHARED) &
       !$OMP PRIVATE(imolecule,this_locate,locate_2,get_interaction) &
       !$OMP PRIVATE(rx,ry,rz,rcom,Eij_vdw,Eij_qq) &
       !$OMP SCHEDULE(DYNAMIC) &
       !$OMP REDUCTION(+:E_inter_vdw,E_inter_qq) &
       !$OMP REDUCTION(.OR.:my_overlap)

       moleculeLoop: DO imolecule = 1, nmols(ispecies,this_box)

          IF(shared_overlap) CYCLE

          this_locate = locate(imolecule,ispecies,this_box)
          IF (.NOT. molecule_list(this_locate,ispecies)%live) CYCLE moleculeLoop
          IF (ispecies == is .AND. this_locate == im) CYCLE moleculeLoop

          ! reset pair energy, if storing energies
          IF (l_pair_store) THEN
             CALL Get_Position_Alive(this_locate,ispecies,locate_2)

             pair_nrg_vdw(locate_1,locate_2) = 0.0_DP
             pair_nrg_vdw(locate_2,locate_1) = 0.0_DP

             pair_nrg_qq(locate_1,locate_2) = 0.0_DP
             pair_nrg_qq(locate_2,locate_1) = 0.0_DP
          END IF

          ! Determine if any atoms of these two molecules will interact
          CALL Check_MoleculePair_Cutoff(im,is,this_locate,ispecies,get_interaction, &
               rcom,rx,ry,rz)

          IF (.NOT. get_interaction) CYCLE moleculeLOOP
          IF (cbmc_flag .AND. precalc_atompair_nrg) THEN
                  CALL Estimate_MoleculePair_Energy(im,is,this_locate,ispecies, &
                          this_box,Eij_vdw,my_overlap)
                  ! Eij_vdw given by estimate is actually combined vdW and qq energy
                  ! so don't add Eij_qq
          ELSE
                  CALL Compute_MoleculePair_Energy(im,is,this_locate,ispecies, &
                       this_box,Eij_vdw,Eij_qq,my_overlap)
                  E_inter_qq  = E_inter_qq + Eij_qq
          END IF
          IF (my_overlap) shared_overlap = .TRUE.

          E_inter_vdw = E_inter_vdw + Eij_vdw

       END DO moleculeLoop
       !$OMP END PARALLEL DO

       IF(shared_overlap) THEN
          overlap = .TRUE.
          RETURN
       ENDIF

    END DO speciesLoop

  END SUBROUTINE Compute_Molecule_Nonbond_Inter_Energy
  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_Molecule_Nonbond_Inter_Energy_Widom(im,is, &
    E_inter,overlap)
    !***************************************************************************
    ! This subroutine computes interatomic LJ and charge interactions as well as
    ! virials associated with these interactions.
    !
    ! CALLS
    !
    ! Minimum_Image_Separation
    ! Compute_MoleculePair_Energy
    !
    ! CALLED BY
    !
    !
    !***************************************************************************

    IMPLICIT NONE

!    !$ include 'omp_lib.h'

    INTEGER, INTENT(IN):: im, is
    REAL(DP), INTENT(OUT) :: E_inter
    LOGICAL :: overlap
    !---------------------------------------------------------------------------

    INTEGER  :: ispecies, imolecule, this_box, this_locate, ia

    REAL(DP) :: Eij, Eij_vdw, Eij_qq, Eij_qq_simple, Ei_qq_simple
    REAL(DP) :: eps
    REAL(DP) :: rcom, rx, ry, rz
!molecule_priority    REAL(DP) :: hardcore_max_r, molecule_hardcore_r
    REAL(DP) :: Ei_inter_vdw, Ei_inter_qq

    LOGICAL :: get_interaction
!molecule_priority    LOGICAL, DIMENSION(MAXVAL(nmols(:,widom_molecule%which_box)),nspecies) :: shortrange, midrange

    E_inter = 0.0_DP
    overlap = .FALSE.

    this_box = widom_molecule%which_box

    IF ((cbmc_cell_list_flag .AND. cbmc_flag) .OR. full_cell_list_flag) THEN
            DO ia = 1, natoms(is)
                IF (.NOT. widom_atoms(ia)%exist) CYCLE
                IF (est_emax) THEN
                        CALL Compute_Atom_Nonbond_Inter_Energy_Cells(ia,im,is, &
                                Ei_inter_vdw, Ei_inter_qq, overlap, Ei_qq_simple)
                ELSE
                        CALL Compute_Atom_Nonbond_Inter_Energy_Cells(ia,im,is, &
                                Ei_inter_vdw, Ei_inter_qq, overlap)
                END IF
                IF (overlap) RETURN
                E_inter = E_inter + Ei_inter_vdw + Ei_inter_qq
            END DO
            RETURN
    END IF

!molecule_priority    IF (widom_active .AND. l_sectors) THEN
    speciesLoop0: DO ispecies = 1, nspecies
        moleculeLoop0: DO imolecule = 1, nmols(ispecies,this_box)
                this_locate = locate(imolecule,ispecies,this_box)
                IF (ispecies == is .AND. this_locate == im) CYCLE moleculeLoop0
                IF (.NOT. molecule_list(this_locate,ispecies)%live) CYCLE moleculeLoop0
                CALL Check_MoleculePair_Cutoff(im,is,this_locate,ispecies,get_interaction, &
                        rcom,rx,ry,rz)
                IF (.NOT. get_interaction) CYCLE moleculeLoop0
                IF (cbmc_flag .AND. precalc_atompair_nrg) THEN
                        CALL Estimate_MoleculePair_Energy(im,is,this_locate,ispecies, &
                                this_box, Eij, overlap)
                        E_inter = E_inter + Eij 
                ELSE
                        IF (est_emax) THEN
                                CALL Compute_MoleculePair_Energy(im,is,this_locate,ispecies, &
                                     this_box,Eij_vdw,Eij_qq,overlap,Eij_qq_simple)
                        ELSE
                                CALL Compute_MoleculePair_Energy(im,is,this_locate,ispecies, &
                                     this_box,Eij_vdw,Eij_qq,overlap)
                        END IF
                        E_inter = E_inter + Eij_vdw + Eij_qq
                END IF

                IF (overlap) RETURN ! this should never happen when using cell list

        END DO moleculeLoop0
    END DO speciesLoop0
!molecule_priority            RETURN
!molecule_priority    END IF

!molecule_priority    hardcore_max_r = widom_molecule%max_dcom + rcut_low
!molecule_priority    molecule_hardcore_r = rcut_low - widom_molecule%min_dcom
!molecule_priority
!molecule_priority
!molecule_priority    speciesLoop: DO ispecies = 1, nspecies
!molecule_priority       moleculeLoop: DO imolecule = 1, nmols(ispecies,this_box)
!molecule_priority          this_locate = locate(imolecule,ispecies,this_box)
!molecule_priority          IF (ispecies == is .AND. this_locate == im) THEN
!molecule_priority                  shortrange(imolecule, ispecies) = .FALSE.
!molecule_priority                  midrange(imolecule, ispecies) = .FALSE.
!molecule_priority                  CYCLE moleculeLoop
!molecule_priority          ELSE IF (.NOT. molecule_list(this_locate,ispecies)%live) THEN
!molecule_priority                  shortrange(imolecule, ispecies) = .FALSE.
!molecule_priority                  midrange(imolecule, ispecies) = .FALSE.
!molecule_priority                  CYCLE moleculeLoop
!molecule_priority          END IF
!molecule_priority
!molecule_priority          ! Determine whether any atoms of these two molecules will interact
!molecule_priority          CALL Check_MoleculePair_Cutoff(im,is,this_locate,ispecies,get_interaction, &
!molecule_priority               rcom,rx,ry,rz)
!molecule_priority
!molecule_priority          IF (.NOT. get_interaction) THEN
!molecule_priority                  shortrange(imolecule, ispecies) = .FALSE.
!molecule_priority                  midrange(imolecule, ispecies) = .FALSE.
!molecule_priority          ELSE IF (rcom + molecule_list(this_locate,ispecies)%min_dcom < molecule_hardcore_r) THEN
!molecule_priority                  overlap = .TRUE.
!molecule_priority                  RETURN
!molecule_priority          ELSE IF (rcom - molecule_list(this_locate,ispecies)%max_dcom > hardcore_max_r) THEN
!molecule_priority                  shortrange(imolecule, ispecies) = .FALSE.
!molecule_priority                  midrange(imolecule, ispecies) = .TRUE.
!molecule_priority          ELSE
!molecule_priority                  shortrange(imolecule, ispecies) = .TRUE.
!molecule_priority                  midrange(imolecule, ispecies) = .FALSE.
!molecule_priority          END IF
!molecule_priority       END DO moleculeLoop
!molecule_priority    END DO speciesLoop
!molecule_priority
!molecule_priority    speciesLoop2: DO ispecies = 1, nspecies
!molecule_priority       moleculeLoop2: DO imolecule = 1, nmols(ispecies,this_box)
!molecule_priority          IF (.NOT. shortrange(imolecule,ispecies)) CYCLE moleculeLoop2
!molecule_priority          this_locate = locate(imolecule,ispecies,this_box)
!molecule_priority
!molecule_priority          CALL Compute_MoleculePair_Energy(im,is,this_locate,ispecies, &
!molecule_priority               this_box,Eij_vdw,Eij_qq,overlap)
!molecule_priority
!molecule_priority          IF (overlap) RETURN
!molecule_priority
!molecule_priority          E_inter_vdw = E_inter_vdw + Eij_vdw
!molecule_priority          E_inter_qq  = E_inter_qq + Eij_qq
!molecule_priority
!molecule_priority       END DO moleculeLoop2
!molecule_priority    END DO speciesLoop2
!molecule_priority
!molecule_priority    speciesLoop3: DO ispecies = 1, nspecies
!molecule_priority       moleculeLoop3: DO imolecule = 1, nmols(ispecies,this_box)
!molecule_priority          IF (.NOT. midrange(imolecule,ispecies)) CYCLE moleculeLoop3
!molecule_priority          this_locate = locate(imolecule,ispecies,this_box)
!molecule_priority          CALL Compute_MoleculePair_Energy(im,is,this_locate,ispecies, &
!molecule_priority               this_box,Eij_vdw,Eij_qq,overlap)
!molecule_priority
!molecule_priority          IF (overlap) RETURN ! there shouldn't be overlap for midrange molecules
!molecule_priority
!molecule_priority          E_inter_vdw = E_inter_vdw + Eij_vdw
!molecule_priority          E_inter_qq  = E_inter_qq + Eij_qq
!molecule_priority
!molecule_priority       END DO moleculeLoop3
!molecule_priority    END DO speciesLoop3
  END SUBROUTINE Compute_Molecule_Nonbond_Inter_Energy_Widom
  !-----------------------------------------------------------------------------


  SUBROUTINE Compute_MoleculeCollection_Nonbond_Inter_Energy(n_list,lm_list,is_list, &
    E_inter_vdw,E_inter_qq,overlap)
    !***************************************************************************
    ! This subroutine computes interatomic LJ and charge interactions as well as
    ! virials associated with these interactions.
    !
    ! CALLS
    !
    ! Minimum_Image_Separation
    ! Compute_MoleculePair_Energy
    ! Clean_Abort
    !
    ! CALLED BY
    !
    ! Reaction
    !
    ! Written by Jindal Shah on 12/07/07
    !***************************************************************************

    IMPLICIT NONE

!    !$ include 'omp_lib.h'

    INTEGER, INTENT(IN):: n_list ! number of molecules in the collection
    INTEGER, INTENT(IN):: lm_list(n_list) ! locates of each molecule
    INTEGER, INTENT(IN):: is_list(n_list) ! species of each molecule
    REAL(DP), INTENT(OUT) :: E_inter_vdw, E_inter_qq
    LOGICAL :: overlap
    !---------------------------------------------------------------------------

    INTEGER  :: ibox
    INTEGER  :: is, is2, is3 ! species index
    INTEGER  :: im, im2, im3 ! molecule index
    INTEGER  :: lm, lm2, lm3 ! molecule locate for molecule_list
    INTEGER  :: locate_1, locate_2 ! molecule locate for pair_nrg arrays

    REAL(DP) :: E12_vdw, E12_qq ! pairwise energy between molecules i,j
    REAL(DP) :: eps
    REAL(DP) :: rcom, rx, ry, rz

    LOGICAL :: get_interaction

    LOGICAL :: l_pair_store
    LOGICAL :: my_overlap, shared_overlap

    E_inter_vdw = 0.0_DP
    E_inter_qq = 0.0_DP
    overlap = .FALSE.
    my_overlap = .FALSE.
    shared_overlap = .FALSE.

    l_pair_store = .FALSE.
    IF (l_pair_nrg .AND. (.NOT. cbmc_flag)) l_pair_store = .TRUE.


    ibox = molecule_list(lm_list(1),is_list(1))%which_box
    DO im = 1, n_list
      lm = lm_list(im)
      is  = is_list(im)
      IF (molecule_list(lm,is)%which_box /= ibox) THEN
        err_msg = ""
        err_msg(1) = 'Collection of molecules must be in the same box'
        CALL Clean_Abort(err_msg,'Compute_MoleculeCollection_Nonbond_Inter_Energy')
      END IF

      IF (l_pair_store) CALL Get_Position_Alive(lm,is,locate_1)

      ! loop over other molecules in the collection
      im2loop: DO im2 = im+1, n_list
        lm2 = lm_list(im2)
        is2 = is_list(im2)

        IF (overlap) CYCLE

        IF (l_pair_store) THEN
           ! find out the location correspoding to lm2 in pair_nrg
           CALL Get_Position_Alive(lm2,is2,locate_2)

          ! reset pair energy
           pair_nrg_vdw(locate_1,locate_2) = 0.0_DP
           pair_nrg_vdw(locate_2,locate_1) = 0.0_DP

           pair_nrg_qq(locate_1,locate_2) = 0.0_DP
           pair_nrg_qq(locate_2,locate_1) = 0.0_DP
        END IF

        ! Determine if any atoms of these two molecules will interact
        CALL Check_MoleculePair_Cutoff(lm,is,lm2,is2,get_interaction,rcom,rx,ry,rz)

        IF (.NOT. get_interaction) CYCLE

        CALL Compute_MoleculePair_Energy(lm,is,lm2,is2,ibox,E12_vdw,E12_qq,overlap)

        IF (overlap) RETURN

        E_inter_vdw = E_inter_vdw + E12_vdw
        E_inter_qq  = E_inter_qq + E12_qq

     END DO im2loop 

      ! loop over molecules not in the collection
      speciesLoop: DO is2 = 1, nspecies

         !$OMP PARALLEL DO DEFAULT(SHARED) &
         !$OMP PRIVATE(im2,lm2,locate_2,get_interaction) &
         !$OMP PRIVATE(rx,ry,rz,rcom,E12_vdw,E12_qq) &
         !$OMP SCHEDULE(DYNAMIC) &
         !$OMP REDUCTION(+:E_inter_vdw,E_inter_qq) &
         !$OMP REDUCTION(.OR.:my_overlap)

         moleculeLoop: DO im2 = 1, nmols(is2,ibox)

            IF(shared_overlap) CYCLE moleculeLoop

            lm2 = locate(im2,is2,ibox)
            IF (.NOT. molecule_list(lm2,is2)%live) CYCLE moleculeLoop
            ! skip molecules that are in the collection
            DO im3 = 1, n_list
              lm3 = lm_list(im3)
              is3 = is_list(im3)
              IF (is2 == is3 .AND. lm2 == lm3) CYCLE moleculeLoop
            END DO

            ! reset pair energy, if storing energies
            IF (l_pair_store) THEN
               CALL Get_Position_Alive(lm2,is2,locate_2)

               pair_nrg_vdw(locate_1,locate_2) = 0.0_DP
               pair_nrg_vdw(locate_2,locate_1) = 0.0_DP

               pair_nrg_qq(locate_1,locate_2) = 0.0_DP
               pair_nrg_qq(locate_2,locate_1) = 0.0_DP
            END IF

            ! Determine if any atoms of these two molecules will interact
            CALL Check_MoleculePair_Cutoff(lm,is,lm2,is2,get_interaction,rcom,rx,ry,rz)

            IF (.NOT. get_interaction) CYCLE moleculeLOOP

            CALL Compute_MoleculePair_Energy(lm,is,lm2,is2,ibox,E12_vdw,E12_qq,my_overlap)

            IF (my_overlap) shared_overlap = .TRUE.

            E_inter_vdw = E_inter_vdw + E12_vdw
            E_inter_qq  = E_inter_qq + E12_qq

         END DO moleculeLoop
         !$OMP END PARALLEL DO

         IF(shared_overlap) THEN
            overlap = .TRUE.
            RETURN
         ENDIF

      END DO speciesLoop
    END DO

  END SUBROUTINE Compute_MoleculeCollection_Nonbond_Inter_Energy
  !-----------------------------------------------------------------------------

  SUBROUTINE Estimate_MoleculePair_Energy(im,is,jm,js,this_box,mpnrg,overlap)
          ! Only for use during CBMC trials
          !
          !
          ! molecule i is the "solute" molecule and molecule j
          !    is the "solvent" molecule
          IMPLICIT NONE
          INTEGER, INTENT(IN) :: im, is, jm, js, this_box
          REAL(DP), INTENT(OUT) :: mpnrg
          !----
          INTEGER :: ia, ja, bsolvent, bsolute
          TYPE(Atom_Class), POINTER :: these_atoms_i(:), these_atoms_j(:)
          REAL(DP) :: rcutsq_shift, rijsq_shift
          REAL(DP) :: ixp, iyp, izp, dx, dy, dz
          REAL(DP), DIMENSION(:,:,:), POINTER :: atompair_nrg_ptr
          LOGICAL :: overlap
          !
          overlap = .TRUE.
          mpnrg = 0.0_DP

          IF (im == widom_locate .AND. is == widom_species) THEN
                  these_atoms_i => widom_atoms
          ELSE
                  these_atoms_i => atom_list(:,im,is)
          END IF
          IF (jm == widom_locate .AND. js == widom_species) THEN
                  these_atoms_j => widom_atoms
          ELSE
                  these_atoms_j => atom_list(:,jm,js)
          END IF

          bsolvent = species_list(js)%solvent_base
          bsolute = species_list(is)%solute_base
          atompair_nrg_ptr => atompair_nrg_table(:, &
                  bsolvent+1:bsolvent+natoms(js), &
                  bsolute+1:bsolute+natoms(is), &
                  this_box)
          rcutsq_shift = rcut_cbmcsq(this_box) - rsq_shifter
          DO ia = 1, natoms(is)
                IF (.NOT. these_atoms_i(ia)%exist) CYCLE
                ixp = these_atoms_i(ia)%rxp
                iyp = these_atoms_i(ia)%ryp
                izp = these_atoms_i(ia)%rzp
                DO ja = 1, natoms(js)
                        IF (.NOT. these_atoms_j(ja)%exist) CYCLE
                        CALL Minimum_Image_Separation(this_box, &
                                ixp - these_atoms_j(ja)%rxp, &
                                iyp - these_atoms_j(ja)%ryp, &
                                izp - these_atoms_j(ja)%rzp, &
                                dx, dy, dz)
                        rijsq_shift = dx*dx + dy*dy + dz*dz - rsq_shifter
                        IF (rijsq_shift >= rcutsq_shift) CYCLE
                        IF (rijsq_shift < rsq_step) RETURN
                        mpnrg = mpnrg + atompair_nrg_ptr( &
                                INT(rijsq_shift/rsq_step), ja, ia)
                END DO
          END DO
          overlap = .FALSE.
          !
  END SUBROUTINE Estimate_MoleculePair_Energy

  SUBROUTINE Compute_MoleculePair_Energy(im,is,jm,js,this_box, &
    vlj_pair,vqq_pair,overlap,Eij_qq)
    !***************************************************************************
    ! The subroutine returns the interaction energy of the input molecule with
    ! another molecule. Thus, it computes the intermolecular vdw and
    ! electrostatic interactions.
    !
    ! CALLS
    !
    ! Minimum_Image_Separation
    ! Check_AtomPair_Cutoff
    ! Compute_AtomPair_Energy
    ! Get_Position_Alive
    !
    ! CALLED BY
    !
    ! Compute_Molecule_Nonbond_Inter_Energy
    ! Compute_System_Total_Energy
    !***************************************************************************

    IMPLICIT NONE

    INTEGER, INTENT(IN) :: im, is, jm, js, this_box
    REAL(DP), INTENT(OUT) :: vlj_pair,vqq_pair
    LOGICAL, INTENT(OUT) :: overlap
    !---------------------------------------------------------------------------

    INTEGER :: ia, ja

    REAL(DP) :: rxijp, ryijp, rzijp, rxij, ryij, rzij, rijsq
    REAL(DP) :: Eij_intra_vdw, Eij_intra_qq, Eij_inter_vdw, Eij_inter_qq

    REAL(DP) :: Eij_qq_temp
    REAL(DP), OPTIONAL :: Eij_qq

    LOGICAL :: get_vdw, get_qq

    INTEGER :: locate_im, locate_jm

    TYPE(Atom_Class), POINTER :: these_atoms_i(:), these_atoms_j(:)
    REAL(DP), DIMENSION(:,:), POINTER :: smp_atompair_rsqmin
    INTEGER :: bsolvent
    LOGICAL ::  l_get_rij_min

    l_get_rij_min = .FALSE.

    IF (im == widom_locate .AND. is == widom_species) THEN
            these_atoms_i => widom_atoms
            IF (est_atompair_rminsq .AND. .NOT. cbmc_flag) THEN
                    l_get_rij_min = .TRUE.
                    bsolvent = species_list(js)%solvent_base
                    smp_atompair_rsqmin => swi_atompair_rsqmin( &
                            bsolvent+1:bsolvent+natoms(js),:) 
            END IF
    ELSE
            these_atoms_i => atom_list(:,im,is)
    END IF
    IF (jm == widom_locate .AND. js == widom_species) THEN
            ! not valid with est_atompair_rminsq==.TRUE.
            these_atoms_j => widom_atoms
    ELSE
            these_atoms_j => atom_list(:,jm,js)
    END IF

    vlj_pair = 0.0_DP
    vqq_pair = 0.0_DP
    Eij_qq_temp = 0.0_DP
    overlap = .FALSE.

    DO ia = 1, natoms(is)

      IF (.NOT. these_atoms_i(ia)%exist) CYCLE

      DO ja = 1, natoms(js)

        IF ( .NOT. these_atoms_j(ja)%exist) CYCLE

        ! Obtain the minimum image separation
        rxijp = these_atoms_i(ia)%rxp - these_atoms_j(ja)%rxp
        ryijp = these_atoms_i(ia)%ryp - these_atoms_j(ja)%ryp
        rzijp = these_atoms_i(ia)%rzp - these_atoms_j(ja)%rzp

        ! Now get the minimum image separation
        CALL Minimum_Image_Separation(this_box,rxijp,ryijp,rzijp,rxij,ryij,rzij)

        rijsq = rxij*rxij + ryij*ryij + rzij*rzij

        IF( rijsq < rcut_lowsq ) THEN
          overlap = .TRUE.
          RETURN
        END IF

        ! Now figure out what needs to be computed, then call pair_energy
        CALL Check_AtomPair_Cutoff(rijsq,get_vdw,get_qq,this_box)

        IF(cbmc_flag .AND. (.NOT. species_list(is)%L_Coul_CBMC)) THEN
          get_qq=.FALSE.
        ENDIF

        ! Compute vdw and q-q energy, if required
        IF (get_vdw .OR. get_qq) THEN

          CALL Compute_AtomPair_Energy(rxij,ryij,rzij,rijsq, &
               is,im,ia,js,jm,ja,get_vdw,get_qq, &
               Eij_intra_vdw,Eij_intra_qq,Eij_inter_vdw,Eij_inter_qq,Eij_qq)

          vlj_pair = vlj_pair + Eij_inter_vdw
          vqq_pair = vqq_pair + Eij_inter_qq

          IF (l_get_rij_min) THEN
                IF (rijsq<smp_atompair_rsqmin(ja,ia)) smp_atompair_rsqmin(ja,ia)=rijsq
          END IF

          IF (PRESENT(Eij_qq)) THEN
                  IF (widom_active .AND. .NOT. cbmc_flag) THEN
                          Eij_max = MAX(Eij_max,Eij_inter_vdw+Eij_qq)
                  END IF
                  Eij_qq_temp = Eij_qq_temp + Eij_qq
          END IF

        END IF
      END DO
    END DO
    IF (PRESENT(Eij_qq)) Eij_qq = Eij_qq_temp

    IF (l_pair_nrg) THEN
      IF ( .NOT. (cbmc_flag .OR. widom_active)) THEN
        ! if here then, there was no overlap between im and jm
        ! update the interaction energy of the pair
        ! first find out the position of each im in the pair interaction energy
        CALL Get_Position_Alive(im,is,locate_im)
        CALL Get_Position_Alive(jm,js,locate_jm)

        pair_nrg_vdw(locate_im,locate_jm) = vlj_pair
        pair_nrg_vdw(locate_jm,locate_im) = vlj_pair

        pair_nrg_qq(locate_im,locate_jm) = vqq_pair
        pair_nrg_qq(locate_jm,locate_im) = vqq_pair
      END IF
    END IF

  END SUBROUTINE Compute_MoleculePair_Energy
  !-----------------------------------------------------------------------------

  FUNCTION AtomPair_VdW_Energy_Vector(rijsq,itype,jtype,ibox)
      REAL(DP), DIMENSION(atompair_nrg_res) :: atompair_vdw_energy_vector
      REAL(DP), DIMENSION(atompair_nrg_res), INTENT(IN) :: rijsq
      INTEGER, INTENT(IN) :: itype, jtype, ibox
      REAL(DP) :: rcut_vdw
      REAL(DP) :: eps, sig, dEij_dr
      REAL(DP), DIMENSION(atompair_nrg_res) :: SigByR2, SigByR6, SigByR12
      REAL(DP) :: SigByR2_shift, SigByR6_shift, SigByR12_shift
      REAL(DP) :: roffsq_rijsq
      ! Mie potential
      REAL(DP) :: mie_coeff, mie_n, mie_m
      REAL(DP), DIMENSION(atompair_nrg_res) :: SigByR, SigByRn, SigByRm
      REAL(DP) :: SigByR_shift, SigByRn_shift, SigByRm_shift
      INTEGER :: i
      IF (int_vdw_style(ibox) == vdw_lj) THEN

           ! For now, assume all interactions are the same.
           ! Use the lookup table created in Compute_Nonbond_Table
           eps = vdw_param1_table(itype,jtype)
           sig = vdw_param2_table(itype,jtype)

           SigByR2 = (sig**2) / rijsq
           SigByR6 = SigByR2 * SigByR2 * SigByR2
           SigByR12 = SigByR6 * SigByR6

           ! use standard LJ potential
           atompair_vdw_energy_vector = 4.0_DP * eps * (SigByR12 - SigByR6)

           IF (int_vdw_sum_style(ibox) == vdw_cut_shift) THEN
                 ! shift the LJ potential
                 SigByR2_shift = sig**2/rcut_vdwsq(ibox)
                 SigByR6_shift = SigByR2_shift * SigByR2_shift * SigByR2_shift
                 SigByR12_shift = SigByR6_shift * SigByR6_shift

                 atompair_vdw_energy_vector = atompair_vdw_energy_vector &
                         - 4.0_DP * eps * (SigByR12_shift - SigByR6_shift)

           ELSE IF (int_vdw_sum_style(ibox) == vdw_cut_switch) THEN
                 DO i = 1, atompair_nrg_res
                         ! scale the LJ potential
                         IF ( rijsq(i) < ron_switch_sq(ibox) ) CYCLE
                         IF ( rijsq(i) > roff_switch_sq(ibox) ) THEN
                                 atompair_vdw_energy_vector(i) = 0.0_DP
                                 CYCLE
                         END IF
                         roffsq_rijsq = roff_switch_sq(ibox) - rijsq(i)
                         atompair_vdw_energy_vector(i) = &
                                 roffsq_rijsq*roffsq_rijsq &
                                 * (switch_factor2(ibox)+2.0_DP*rijsq(i))*switch_factor1(ibox) &
                                 * atompair_vdw_energy_vector(i)
                 END DO
           ELSE IF (int_vdw_sum_style(ibox) == vdw_charmm) THEN
                 ! use the form for modified LJ potential
                 atompair_vdw_energy_vector = eps * (SigByR12 - 2.0_DP * SigByR6)
           ELSE IF (int_vdw_sum_style(ibox) == vdw_cut_shift_force) THEN
                 ! apply the shifted-force LJ potential
                 ! u_sf(r) = u_lj(r) - u_lj(rc) - (r-rc)*du_lj/dr(rc)
                 SigByR2_shift = sig**2/rcut_vdwsq(ibox)
                 SigByR6_shift = SigByR2_shift * SigByR2_shift * SigByR2_shift
                 SigByR12_shift = SigByR6_shift * SigByR6_shift

                 rcut_vdw = SQRT(rcut_vdwsq(ibox))

                 dEij_dr = - 24.0_DP * eps * ( 2.0_DP * SigByR12_shift &
                                              - SigByR6_shift) / rcut_vdw

                 atompair_vdw_energy_vector = atompair_vdw_energy_vector &
                         - 4.0_DP * eps * (SigByR12_shift - SigByR6_shift) &
                         - (SQRT(rijsq) - rcut_vdw) * dEij_dr

           END IF

      ELSE IF (int_vdw_style(ibox) == vdw_mie) THEN
           eps = vdw_param1_table(itype,jtype)
           sig = vdw_param2_table(itype,jtype)
           mie_n = vdw_param3_table(itype,jtype) ! repulsive exponent
           mie_m = vdw_param4_table(itype,jtype) ! dispersive exponent

           rcut_vdw = SQRT(rcut_vdwsq(ibox))

           mie_coeff = mie_n/(mie_n-mie_m) * (mie_n/mie_m)**(mie_m/(mie_n-mie_m))

           SigByR = sig/SQRT(rijsq)
           SigByRn = SigByR ** mie_n
           SigByRm = SigByR ** mie_m
           atompair_vdw_energy_vector =  mie_coeff * eps * (SigByRn - SigByRm)
           !use cut-shift potential
           IF (int_vdw_sum_style(ibox) == vdw_cut_shift) THEN
                 SigByR_shift = sig/rcut_vdw
                 SigByRn_shift = SigByR_shift ** mie_n
                 SigByRm_shift = SigByR_shift ** mie_m
                 atompair_vdw_energy_vector =  atompair_vdw_energy_vector - mie_coeff * eps * (SigByRn_shift - SigByRm_shift)
           END IF

      END IF

  END FUNCTION AtomPair_VdW_Energy_Vector

  SUBROUTINE Compute_AtomPair_Energy(rxij,ryij,rzij,rijsq,is,im,ia,js,jm,ja, &
    get_vdw,get_qq,E_intra_vdw,E_intra_qq,E_inter_vdw,E_inter_qq,Eij_qq_o)

    ! Computes the vdw and q-q pair energy between atoms ia and ja of molecules
    ! im and jm and species is and js, given their separation rijsq. I have
    ! passed each component of separation but right now this is unnecessary.
    !
    ! LJ potential:
    !      Eij =  4*epsilon(i,j) * [ (sigma(i,j)/rij)^12 - (sigma(i,j)/rij)^6 ]
    !
    !

    ! It also computes the real space part of the Ewald sum if necessary.

    ! Called by:
    !   Compute_Atom_Nonbond_Energy
    !   Compute_Molecule_Nonbond_Energy
    ! Calls:
    !   Compute_AtomPair_Ewald_Real
  !----------------------------------------------------------------------------
    ! Passed to
    REAL(DP) :: rxij,ryij,rzij,rijsq
    INTEGER :: is,im,ia,js,jm,ja,ibox
    LOGICAL :: get_vdw,get_qq

    ! Returned
    REAL(DP) :: E_intra_vdw,E_intra_qq
    REAL(DP) :: E_inter_vdw,E_inter_qq

    ! Local
    ! LJ potential
    INTEGER :: itype, jtype
    REAL(DP) :: rij, rcut_vdw
    REAL(DP) :: eps, sig, Eij_vdw, dEij_dr
    REAL(DP) :: SigByR2, SigByR6, SigByR12
    REAL(DP) :: SigByR2_shift, SigByR6_shift, SigByR12_shift
    REAL(DP) :: roffsq_rijsq, roffsq_rijsq_sq, factor2, fscale
    ! Mie potential
    REAL(DP) :: mie_coeff, mie_n, mie_m
    REAL(DP) :: SigByR, SigByRn, SigByRm
    REAL(DP) :: SigByR_shift, SigByRn_shift, SigByRm_shift
    ! Coulomb potential
    REAL(DP) :: qi, qj, Eij_qq
    REAL(DP), OPTIONAL :: Eij_qq_o

    LOGICAL :: atom_i_exist, atom_j_exist

    E_intra_vdw = 0.0_DP
    E_intra_qq  = 0.0_DP
    E_inter_vdw = 0.0_DP
    E_inter_qq  = 0.0_DP
  !----------------------------------------------------------------------------
    ibox = molecule_list(im,is)%which_box

    IF (im == widom_locate .AND. is == widom_species) THEN
            atom_i_exist = widom_atoms(ia)%exist
    ELSE
            atom_i_exist = atom_list(ia,im,is)%exist
    END IF
    IF (jm == widom_locate .AND. js == widom_species) THEN
            atom_j_exist = widom_atoms(ja)%exist
    ELSE
            atom_j_exist = atom_list(ja,jm,js)%exist
    END IF

    ! If either atom is not yet present, then don't try to compute an energy
    ExistCheck: &
    IF (atom_i_exist .AND. atom_j_exist) THEN

         ! Determine atom type indices
         itype = nonbond_list(ia,is)%atom_type_number
         jtype = nonbond_list(ja,js)%atom_type_number

         VDW_calc: &
         IF (get_vdw .AND. itype /= 0 .AND. jtype /=0) THEN

              IF (int_vdw_style(ibox) == vdw_lj) THEN

                   ! For now, assume all interactions are the same.
                   ! Use the lookup table created in Compute_Nonbond_Table
                   eps = vdw_param1_table(itype,jtype)
                   sig = vdw_param2_table(itype,jtype)

                   ! Apply intramolecular scaling if necessary
                   IF (is == js .AND. im == jm) THEN
                     ! This controls 1-2, 1-3, and 1-4 interactions
                     eps = eps * vdw_intra_scale(ia,ja,is)
                   ENDIF

                   SigByR2 = (sig**2) / rijsq
                   SigByR6 = SigByR2 * SigByR2 * SigByR2
                   SigByR12 = SigByR6 * SigByR6

                   ! use standard LJ potential
                   Eij_vdw = 4.0_DP * eps * (SigByR12 - SigByR6)

                   IF (int_vdw_sum_style(ibox) == vdw_cut_shift) THEN
                         ! shift the LJ potential
                         SigByR2_shift = sig**2/rcut_vdwsq(ibox)
                         SigByR6_shift = SigByR2_shift * SigByR2_shift * SigByR2_shift
                         SigByR12_shift = SigByR6_shift * SigByR6_shift

                         Eij_vdw = Eij_vdw &
                                 - 4.0_DP * eps * (SigByR12_shift - SigByR6_shift)

                   ELSE IF (int_vdw_sum_style(ibox) == vdw_cut_switch) THEN
                         ! scale the LJ potential
                         IF ( rijsq < ron_switch_sq(ibox) ) THEN
                           fscale = 1.0_DP
                         ELSEIF ( rijsq <= roff_switch_sq(ibox) ) THEN
                           roffsq_rijsq = roff_switch_sq(ibox) - rijsq
                           roffsq_rijsq_sq = roffsq_rijsq * roffsq_rijsq
                           factor2 = switch_factor2(ibox) + 2.0_DP * rijsq
                           fscale = roffsq_rijsq_sq * factor2 * switch_factor1(ibox)
                           Eij_vdw = fscale * Eij_vdw
                         ELSE
                           fscale = 0.0_DP
                           Eij_vdw = 0.0_DP
                         END IF
                   ELSE IF (int_vdw_sum_style(ibox) == vdw_charmm) THEN
                         ! use the form for modified LJ potential
                         Eij_vdw = eps * (SigByR12 - 2.0_DP * SigByR6)
                   ELSE IF (int_vdw_sum_style(ibox) == vdw_cut_shift_force) THEN
                         ! apply the shifted-force LJ potential
                         ! u_sf(r) = u_lj(r) - u_lj(rc) - (r-rc)*du_lj/dr(rc)
                         SigByR2_shift = sig**2/rcut_vdwsq(ibox)
                         SigByR6_shift = SigByR2_shift * SigByR2_shift * SigByR2_shift
                         SigByR12_shift = SigByR6_shift * SigByR6_shift

                         Eij_vdw = Eij_vdw &
                                 - 4.0_DP * eps * (SigByR12_shift - SigByR6_shift)

                         rij = SQRT(rijsq)
                         rcut_vdw = SQRT(rcut_vdwsq(ibox))

                         dEij_dr = - 24.0_DP * eps * ( 2.0_DP * SigByR12_shift / rcut_vdw &
                                                      - SigByR6_shift / rcut_vdw )

                         Eij_vdw = Eij_vdw - (rij - rcut_vdw) * dEij_dr

                   END IF

              ELSE IF (int_vdw_style(ibox) == vdw_mie) THEN
                   eps = vdw_param1_table(itype,jtype)
                   sig = vdw_param2_table(itype,jtype)
                   mie_n = vdw_param3_table(itype,jtype) ! repulsive exponent
                   mie_m = vdw_param4_table(itype,jtype) ! dispersive exponent

                   ! Apply intramolecular scaling if necessary
                   IF (is == js .AND. im == jm) THEN
                     ! This controls 1-2, 1-3, and 1-4 interactions
                     eps = eps * vdw_intra_scale(ia,ja,is)
                   ENDIF

                   rij = SQRT(rijsq)
                   rcut_vdw = SQRT(rcut_vdwsq(ibox))

                   mie_coeff = mie_n/(mie_n-mie_m) * (mie_n/mie_m)**(mie_m/(mie_n-mie_m))

                   SigByR = sig/rij
                   SigByRn = SigByR ** mie_n
                   SigByRm = SigByR ** mie_m
                   Eij_vdw =  mie_coeff * eps * (SigByRn - SigByRm)
                   !use cut-shift potential
                   IF (int_vdw_sum_style(ibox) == vdw_cut_shift) THEN
                         SigByR_shift = sig/rcut_vdw
                         SigByRn_shift = SigByR_shift ** mie_n
                         SigByRm_shift = SigByR_shift ** mie_m
                         Eij_vdw =  Eij_vdw - mie_coeff * eps * (SigByRn_shift - SigByRm_shift)
                   END IF

              END IF

              IF (is == js .AND. im == jm) THEN
                   E_intra_vdw = Eij_vdw
                   E_inter_vdw = 0.0_DP
              ELSE
                   E_intra_vdw = 0.0_DP
                   E_inter_vdw = Eij_vdw
              ENDIF

         ENDIF VDW_calc

         qq_calc: IF (get_qq) THEN

              qi = nonbond_list(ia,is)%charge
              qj = nonbond_list(ja,js)%charge


              IF (int_charge_sum_style(ibox) == charge_ewald .AND. &
                      ( .NOT. igas_flag) ) THEN
                   ! Real space Ewald part
                   CALL Compute_AtomPair_Ewald_Real(ia,im,is,qi,ja,jm,js,qj, &
                        rijsq,E_intra_qq,E_inter_qq,ibox,Eij_qq_o)

                   ! self and reciprocal parts need to be computed as total energy
                   ! differences between original configuration and the perturbed
                   ! configuration.

              ELSEIF (int_charge_sum_style(ibox) == charge_dsf) THEN
                   CALL Compute_AtomPair_DSF_Energy(ia,im,is,qi,ja,jm,js,qj,rijsq,E_intra_qq,E_inter_qq,ibox,Eij_qq_o)

              ELSEIF (int_charge_sum_style(ibox) == charge_cut .OR. &
                  int_charge_sum_style(ibox) == charge_minimum .OR. igas_flag) THEN

                   Eij_qq = charge_factor*(qi*qj)/SQRT(rijsq)
                   ! Apply charge scaling for intramolecular energies
                   IF ( is == js .AND. im == jm ) THEN
                     Eij_qq = charge_intra_scale(ia,ja,is) * Eij_qq
                     E_intra_qq = E_intra_qq + Eij_qq
                   ELSE
                     E_inter_qq = E_inter_qq + Eij_qq
                   END IF
                   IF (PRESENT(Eij_qq_o)) Eij_qq_o = Eij_qq

             ENDIF
         ELSEIF (PRESENT(Eij_qq_o)) THEN
             Eij_qq_o = 0.0_DP
         ENDIF qq_calc

    ENDIF ExistCheck

  END SUBROUTINE Compute_AtomPair_Energy


SUBROUTINE Compute_AtomPair_DSF_Energy(ia,im,is,qi,ja,jm,js,qj,rijsq,E_intra_qq,E_inter_qq,ibox,Eij_qq_o)
USE Global_Variables
IMPLICIT NONE
INTEGER :: ia,im,is,ja,jm,js,ibox
REAL(DP), OPTIONAL :: Eij_qq_o
REAL(DP) :: qi,qj,rijsq,rij, Eij, qsc, E_intra_qq,E_inter_qq, cfqq, Eij_qq


      rij = SQRT(rijsq)
      cfqq = qi*qj*charge_factor
      Eij = dsf_factor2(ibox)*(rij-rcut_coul(ibox)) - dsf_factor1(ibox) + erfc(alpha_dsf(ibox)*rij)/rij
      Eij = Eij*cfqq

      IF (is==js .AND. im==jm) THEN
              qsc = charge_intra_scale(ia,ja,is)
              Eij_qq = cfqq/rij
              E_intra_qq = Eij - (1.0_DP-qsc)*Eij_qq
              E_inter_qq = 0.0_DP
              IF (PRESENT(Eij_qq_o)) Eij_qq_o = Eij_qq
      ELSE
              E_intra_qq = 0.0_DP
              E_inter_qq = Eij
              IF (PRESENT(Eij_qq_o)) Eij_qq_o = cfqq/rij
      END IF


END SUBROUTINE Compute_AtomPair_DSF_Energy



  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_AtomPair_Ewald_Real(ia,im,is,qi,ja,jm,js,qj,rijsq, &
    E_intra_qq,E_inter_qq,ibox,Eij_qq_o)
  !-----------------------------------------------------------------------------
    ! Real space part of the Ewald sum between atoms ia and ja with
    ! charges qi and qj.
    !
    ! Miniumum image charges interact via Coulomb's law: qi*qj/rij
    !   * Intramolecular: scaled for 1-2, 1-3 and 1-4 interactions
    !
    ! The real space part of the periodic image charge is qi*qj/rij*erf
    !
    !
    ! CALLED BY:
    !
    ! Compute_AtomPair_Energy
  !-----------------------------------------------------------------------------
    ! Arguments
    INTEGER :: ia,im,is
    REAL(DP) :: qi
    INTEGER :: ja,jm,js
    REAL(DP) :: qj
    REAL(DP) :: rijsq
    REAL(DP) :: E_intra_qq, E_inter_qq, Eij_qq
    INTEGER :: ibox
    REAL(DP), OPTIONAL :: Eij_qq_o

    ! Local variables
    REAL(DP) :: rij,erf_val

    ibox = molecule_list(im,is)%which_box

    rij = SQRT(rijsq)
    ! May need to protect against very small rijsq
    erf_val = 1.0_DP - erfc(alpha_ewald(ibox) * rij)
    Eij_qq = qi * qj / rij * charge_factor

    ! Minimum image real space energy
    IF (is == js .AND. im == jm) THEN
       ! Intramolecular charge scaling
       E_intra_qq = charge_intra_scale(ia,ja,is) * Eij_qq
       E_inter_qq = 0.0_DP
    ELSE
       E_intra_qq = 0.0_DP
       E_inter_qq = Eij_qq
    ENDIF

    ! Periodic image real space energy
    E_inter_qq = E_inter_qq - erf_val * Eij_qq

    IF (PRESENT(Eij_qq_o)) Eij_qq_o = Eij_qq


  !-----------------------------------------------------------------------------
  CONTAINS

    FUNCTION erfc(x)
      !*************************************************************************
      !
      ! Calculate the complementary error function for a number
      !
      !*************************************************************************

      REAL(DP) :: erfc
      REAL(DP), PARAMETER :: A1 = 0.254829592_DP, A2 = -0.284496736_DP
      REAL(DP), PARAMETER :: A3 = 1.421413741_DP, A4 = -1.453152027_DP
      REAL(DP), PARAMETER :: A5 = 1.061405429_DP, P = 0.3275911_DP
      REAL(DP) :: T, x, xsq, TP

      T = 1.0_DP / (1.0_DP + P*x)
      xsq = x*x

      TP = T * (A1 + T * (A2 + T * (A3 + T * (A4 + T * A5))))

      erfc = TP * EXP(-xsq)

    END FUNCTION erfc
  !-----------------------------------------------------------------------------

  END SUBROUTINE Compute_AtomPair_Ewald_Real

  !*****************************************************************************


  ELEMENTAL SUBROUTINE Extract_Kvector_Ints(kxyz,kx,ky,kz)
          !DIR$ ATTRIBUTES FORCEINLINE :: Extract_Kvector_Ints
          INTEGER, INTENT(IN) :: kxyz
          INTEGER, INTENT(OUT) :: kx, ky, kz
          INTEGER, PARAMETER :: tmask = MASKR(11)
          ky = SHIFTR(kxyz,11)
          kz = SHIFTR(kxyz,22)
          kx = IAND(kxyz,tmask)
          kx = kx - kxyz_max_allowed
          ky = IAND(ky,tmask)
          ky = ky - kxyz_max_allowed
  END SUBROUTINE Extract_Kvector_Ints

  SUBROUTINE Ewald_Reciprocal_Lattice_Vector_Setup(this_box)
    !***************************************************************************
    ! This subroutine sets up the reciprocal lattice vector constants required in the reciprocal
    ! space summation. Note that these constants need to be recomputed every time a volume
    ! change move is attempted.
    ! Based on the APSS code, ewald_setup.f90
    !
    ! Added by Jindal Shah on 12/05/07
    !
    !***************************************************************************

    USE Type_Definitions
    USE Global_Variables

    IMPLICIT NONE

    INTEGER :: nx, ny, nz, this_box, kvecs, kvecs_p4

    REAL(DP) :: const_val, const_val_2, hcutsq, x, y, z
    REAL(DP) :: hx, hy, hz, hsq
    INTEGER :: i
    LOGICAL :: l_inrange
    LOGICAL, DIMENSION(:), ALLOCATABLE, SAVE :: l_inrange_vec
    INTEGER :: nchecks
    LOGICAL :: l_ortho
    REAL(DP) :: prefactor_constant, double_prefactor_constant
    REAL(SP) :: hcutsq_sp
    INTEGER :: kxyz_max(3)
    INTEGER(INT64) :: kxyz_max_int64(3), nchecks_int64
    REAL(DP), DIMENSION(3) :: inv_l, inv_lsq
    REAL(DP), DIMENSION(3,3) :: inv_H
    REAL(SP), DIMENSION(3) :: inv_lsq_sp
    REAL(SP), DIMENSION(3,3) :: inv_H_sp
    INTEGER :: tcount
    REAL(DP) :: prefactor, factor1, factor2
    INTEGER :: kx, ky, kz, kxyz, kx_shifted, ky_shifted1, ky_shifted2, kz_shifted
    REAL(SP) :: xsq_sp,ysq_sp,zsq_sp,x_sp,y_sp,z_sp,hx_sp,hy_sp,hz_sp
    INTEGER :: ky_dimfactor, kz_dimfactor, ky_dimshift, kx_dimshift 
    INTEGER :: kx_shifted_start, ky_shifted_start, kx_shifted_end, ky_shifted_end
    INTEGER :: shiftconst
    INTEGER :: ithread, chunkstart, chunkend, chunksize, nthreads

    ky_dimfactor = kxyz_max(1)*2+1
    kz_dimfactor = ky_dimfactor*(kxyz_max(2)*2+1)
    ky_dimshift = kxyz_max(2)-kxyz_max_allowed
    kx_dimshift = kxyz_max(1)-kxyz_max_allowed + 1
    kx_shifted_start = kxyz_max_allowed - kxyz_max(1)
    ky_shifted_start = kxyz_max_allowed - kxyz_max(2)
    kx_shifted_end = kxyz_max_allowed + kxyz_max(1)
    ky_shifted_end = kxyz_max_allowed + kxyz_max(2)

    l_ortho = box_list(this_box)%int_box_shape <= int_ortho
    prefactor_constant = twoPI/box_list(this_box)%volume
    double_prefactor_constant = 2.0_DP*prefactor_constant

    ! Total number of k vectors
    !kvecs = 1

    !const_val = 1.0_DP/(4.0_DP * alpha_ewald(this_box) * alpha_ewald(this_box))
    const_val_2 = -0.5_DP/(alpha_ewald(this_box) * alpha_ewald(this_box))
    const_val = const_val_2*0.5_DP
    hcutsq = h_ewald_cut(this_box) * h_ewald_cut(this_box)
    hcutsq_sp = REAL(hcutsq,SP)

    kxyz_max = INT( h_ewald_cut(this_box) / (twoPI * box_list(this_box)%invT_face_distance)) + 1
    IF (ANY(kxyz_max>kxyz_max_allowed)) THEN
            WRITE(logunit,*) kxyz_max
            WRITE(*,*) kxyz_max
            err_msg = ""
            err_msg(1) = "At least one of the above kspace vector integer component maxima"
            err_msg(2) = "exceeds the maximum allowed value, " // TRIM(Int_To_String(kxyz_max_allowed))
            CALL Clean_Abort(err_msg,'Ewald_Reciprocal_Lattice_Vector_Setup')
    END IF
    kxyz_max_int64 = INT(kxyz_max,INT64)
    box_list(this_box)%kxyz_maxmax = MAXVAL(kxyz_max)
    box_list(this_box)%kxyz_max = kxyz_max
    nchecks_int64 = PRODUCT((/2_INT64,2_INT64,1_INT64/)*kxyz_max_int64+1_INT64)
    IF (nchecks_int64 >= HUGE(nchecks)) THEN
            err_msg = ""
            err_msg(1) = 'Too many kspace vectors to check'
            CALL Clean_Abort(err_msg,'Ewald_Reciprocal_Lattice_Vector_Setup')
    END IF
    nchecks = INT(nchecks_int64,INT32) ! PRODUCT((/2,2,1/)*kxyz_max+1)
    IF (l_ortho) THEN
            inv_l(1) = twoPI/box_list(this_box)%length(1,1)
            inv_l(2) = twoPI/box_list(this_box)%length(2,2)
            inv_l(3) = twoPI/box_list(this_box)%length(3,3)
            inv_lsq = inv_l*inv_l
            inv_lsq_sp = REAL(inv_lsq,SP)
    ELSE
            inv_H = twoPI*box_list(this_box)%length_inv
            inv_H_sp = REAL(inv_H,SP)
    END IF
    kvecs = -1 ! exclude central box
    IF (ALLOCATED(box_list(this_box)%kspace_vector_ints)) THEN
            IF (UBOUND(box_list(this_box)%kspace_vector_ints,1) < nchecks) DEALLOCATE(box_list(this_box)%kspace_vector_ints)
    END IF
    IF (.NOT. ALLOCATED(box_list(this_box)%kspace_vector_ints)) THEN
            ALLOCATE(box_list(this_box)%kspace_vector_ints(nchecks))
    END IF
    IF (ALLOCATED(l_inrange_vec)) THEN
            IF (UBOUND(l_inrange_vec,1) < nchecks) DEALLOCATE(l_inrange_vec)
    END IF
    IF (.NOT. ALLOCATED(l_inrange_vec)) THEN
            ALLOCATE(l_inrange_vec(nchecks))
    END IF
    ky_dimfactor = kxyz_max(1)*2+1
    kz_dimfactor = ky_dimfactor*(kxyz_max(2)*2+1)
    ky_dimshift = kxyz_max(2)-kxyz_max_allowed
    kx_dimshift = kxyz_max(1)-kxyz_max_allowed + 1
    kx_shifted_start = kxyz_max_allowed - kxyz_max(1)
    ky_shifted_start = kxyz_max_allowed - kxyz_max(2)
    kx_shifted_end = kxyz_max_allowed + kxyz_max(1)
    ky_shifted_end = kxyz_max_allowed + kxyz_max(2)
    ! The most general definition for a wave-vector is h = 2*pi*TRANSPOSE(cell_matrix)^-1)*n
    ! where h is the wave vector and n is a vector of integers

    ! We will use symmetry to calculate only half the wave vectors

    !$OMP PARALLEL PRIVATE(kz,ky,kx,kxyz,x,y,z,hx,hy,hz,hsq,l_inrange,i) &
    !$OMP PRIVATE(prefactor,factor1,factor2) &
    !$OMP PRIVATE(xsq_sp,ysq_sp,zsq_sp,x_sp,y_sp,z_sp,hx_sp,hy_sp,hz_sp) &
    !$OMP PRIVATE(kx_shifted,ky_shifted1,kz_shifted,ky_shifted2,shiftconst) &
    !$OMP PRIVATE(ithread,chunkstart,chunkend)
    !$OMP DO SCHEDULE(STATIC)
    DO ky_shifted1 = ky_shifted_start, ky_shifted_end
        ky_shifted2 = SHIFTL(ky_shifted1,11)
        shiftconst = (ky_shifted1 + ky_dimshift)*ky_dimfactor + kx_dimshift
        !$OMP SIMD
        DO kx_shifted = kx_shifted_start, kx_shifted_end
                box_list(this_box)%kspace_vector_ints(shiftconst+kx_shifted) = IOR(kx_shifted,ky_shifted2)
        END DO
        !$OMP END SIMD
    END DO
    !$OMP END DO
    !$OMP DO SCHEDULE(STATIC)
    DO kz = 1, kxyz_max(3)
        kz_shifted = SHIFTL(kz,22)
        shiftconst = kz*kz_dimfactor
        !$OMP SIMD
        DO i = 1, kz_dimfactor
                box_list(this_box)%kspace_vector_ints(shiftconst+i) = &
                        IOR(box_list(this_box)%kspace_vector_ints(i),kz_shifted)
        END DO
        !$OMP END SIMD
        !box_list(this_box)%kspace_vector_ints(kz*kz_dimfactor+1:(kz+1)*kz_dimfactor) = &
        !        IOR(box_list(this_box)%kspace_vector_ints(:kz_dimfactor),kz_shifted)
    END DO
    !$OMP END DO
    IF (l_ortho) THEN
            ! if it is an orthogonal box, then h vectors are simply hx = twoPI * kx / Lx and so on
            !DIR$ VECTOR ALIGNED
            !$OMP DO SIMD SCHEDULE(SIMD:STATIC) &
            !$OMP PRIVATE(kxyz,kx,ky,kz,xsq_sp,ysq_sp,zsq_sp,l_inrange) &
            !$OMP REDUCTION(+:kvecs)
            DO i = 1, nchecks
                kxyz = box_list(this_box)%kspace_vector_ints(i)
                CALL Extract_Kvector_Ints(kxyz,kx,ky,kz) ! Should be inlined by compiler
                kx = kx*kx
                ky = ky*ky
                kz = kz*kz
                xsq_sp = REAL(kx,SP)
                ysq_sp = REAL(ky,SP)
                zsq_sp = REAL(kz,SP)
                l_inrange = inv_lsq_sp(1)*xsq_sp + inv_lsq_sp(2)*ysq_sp + inv_lsq_sp(3)*zsq_sp < hcutsq_sp
                l_inrange_vec(i) = l_inrange
                IF (l_inrange) kvecs = kvecs + 1
            END DO
            !$OMP END DO SIMD
    ELSE
            !DIR$ VECTOR ALIGNED
            !$OMP DO SIMD SCHEDULE(SIMD:STATIC) &
            !$OMP PRIVATE(kxyz,kx,ky,kz,x_sp,y_sp,z_sp,hx_sp,hy_sp,hz_sp,l_inrange) &
            !$OMP REDUCTION(+:kvecs)
            DO i = 1, nchecks
                kxyz = box_list(this_box)%kspace_vector_ints(i)
                CALL Extract_Kvector_Ints(kxyz,kx,ky,kz) ! Should be inlined by compiler
                x_sp = REAL(kx,SP)
                y_sp = REAL(ky,SP)
                z_sp = REAL(kz,SP)
                hx_sp = inv_H_sp(1,1)*x_sp + inv_H_sp(2,1)*y_sp + inv_H_sp(3,1)*z_sp
                hy_sp = inv_H_sp(1,2)*x_sp + inv_H_sp(2,2)*y_sp + inv_H_sp(3,2)*z_sp
                hz_sp = inv_H_sp(1,3)*x_sp + inv_H_sp(2,3)*y_sp + inv_H_sp(3,3)*z_sp
                l_inrange = hx_sp*hx_sp + hy_sp*hy_sp + hz_sp*hz_sp < hcutsq_sp
                l_inrange_vec(i) = l_inrange
                IF (l_inrange) kvecs = kvecs + 1
            END DO
            !$OMP END DO SIMD
    END IF
    !$OMP SECTIONS
    !$OMP SECTION
    l_inrange_vec(1+kxyz_max(2)*(kxyz_max(1)*2+1)+kxyz_max(1)) = .FALSE. ! Exclude central box (0,0,0)
    tcount = 0
    i = 0
    DO WHILE (tcount < kvecs)
        i = i + 1
        IF (l_inrange_vec(i)) THEN
                tcount = tcount + 1
                box_list(this_box)%kspace_vector_ints(tcount) = box_list(this_box)%kspace_vector_ints(i)
        END IF
    END DO
    !$OMP SECTION
    nvecs(this_box) = kvecs
    kvecs_p4 = IAND(kvecs+3,NOT(3))
    IF (ALLOCATED(box_list(this_box)%kspace_vectors)) THEN
            IF (UBOUND(box_list(this_box)%kspace_vectors,1) < kvecs) DEALLOCATE(box_list(this_box)%kspace_vectors)
    END IF
    IF (.NOT. ALLOCATED(box_list(this_box)%kspace_vectors)) THEN
            ALLOCATE(box_list(this_box)%kspace_vectors(kvecs_p4,5))
    END IF
    IF (ALLOCATED(box_list(this_box)%sincos_sum)) THEN
            IF (UBOUND(box_list(this_box)%sincos_sum,1) < kvecs) DEALLOCATE(box_list(this_box)%sincos_sum)
    END IF
    IF (.NOT. ALLOCATED(box_list(this_box)%sincos_sum)) THEN
            ALLOCATE(box_list(this_box)%sincos_sum(kvecs_p4,2))
    END IF
    !$ nthreads = OMP_GET_NUM_THREADS()
    !$ chunksize = IAND((kvecs+nthreads-1)/nthreads+7,NOT(7))
    !$OMP END SECTIONS
    chunkstart = 1
    chunkend = kvecs
    !$ ithread = OMP_GET_THREAD_NUM()
    !$ chunkstart = ithread*chunksize+1
    !$ chunkend = MIN((ithread+1)*chunksize,kvecs)
    IF (l_ortho) THEN
            !DIR$ VECTOR ALIGNED
            !$OMP SIMD PRIVATE(kxyz,kx,ky,kz,x,y,z,prefactor)
            DO i = chunkstart, chunkend
                kxyz = box_list(this_box)%kspace_vector_ints(i)
                CALL Extract_Kvector_Ints(kxyz,kx,ky,kz) ! Should be inlined by compiler
                z = REAL(kz,DP)
                x = REAL(kx,DP)
                y = REAL(ky,DP)
                prefactor = MERGE(prefactor_constant,double_prefactor_constant,kz==0)
                box_list(this_box)%kspace_vectors(i,1) = x
                box_list(this_box)%kspace_vectors(i,2) = y
                box_list(this_box)%kspace_vectors(i,3) = z
                box_list(this_box)%kspace_vectors(i,5) = prefactor
            END DO
            !$OMP END SIMD
            ! if it is an orthogonal box, then h vectors are simply hx = twoPI * kx / Lx and so on
            !DIR$ VECTOR ALIGNED
            !$OMP SIMD PRIVATE(x,y,z,hx,hy,hz,hsq)
            DO i = chunkstart, chunkend
                x = box_list(this_box)%kspace_vectors(i,1)
                y = box_list(this_box)%kspace_vectors(i,2)
                z = box_list(this_box)%kspace_vectors(i,3)
                hx = inv_l(1)*x
                hy = inv_l(2)*y
                hz = inv_l(3)*z
                hsq = hx*hx + hy*hy + hz*hz
                box_list(this_box)%kspace_vectors(i,1) = hx
                box_list(this_box)%kspace_vectors(i,2) = hy
                box_list(this_box)%kspace_vectors(i,3) = hz
                box_list(this_box)%kspace_vectors(i,4) = hsq
            END DO
            !$OMP END SIMD
    ELSE
            !DIR$ VECTOR ALIGNED
            !$OMP SIMD PRIVATE(kxyz,kx,ky,kz,x,y,z,prefactor)
            DO i = chunkstart, chunkend
                kxyz = box_list(this_box)%kspace_vector_ints(i)
                CALL Extract_Kvector_Ints(kxyz,kx,ky,kz) ! Should be inlined by compiler
                z = REAL(kz,DP)
                x = REAL(kx,DP)
                y = REAL(ky,DP)
                prefactor = MERGE(prefactor_constant,double_prefactor_constant,kz==0)
                box_list(this_box)%kspace_vectors(i,1) = x
                box_list(this_box)%kspace_vectors(i,2) = y
                box_list(this_box)%kspace_vectors(i,3) = z
                box_list(this_box)%kspace_vectors(i,5) = prefactor
            END DO
            !$OMP END SIMD
            !DIR$ VECTOR ALIGNED
            !$OMP SIMD PRIVATE(x,y,z,hx,hy,hz,hsq)
            DO i = chunkstart, chunkend
                x = box_list(this_box)%kspace_vectors(i,1)
                y = box_list(this_box)%kspace_vectors(i,2)
                z = box_list(this_box)%kspace_vectors(i,3)
                hx = inv_H(1,1)*x + inv_H(2,1)*y + inv_H(3,1)*z
                hy = inv_H(1,2)*x + inv_H(2,2)*y + inv_H(3,2)*z
                hz = inv_H(1,3)*x + inv_H(2,3)*y + inv_H(3,3)*z
                hsq = hx*hx + hy*hy + hz*hz
                box_list(this_box)%kspace_vectors(i,1) = hx
                box_list(this_box)%kspace_vectors(i,2) = hy
                box_list(this_box)%kspace_vectors(i,3) = hz
                box_list(this_box)%kspace_vectors(i,4) = hsq
            END DO
            !$OMP END SIMD
    END IF
    !DIR$ VECTOR ALIGNED
    !$OMP SIMD PRIVATE(hsq,prefactor,factor1,factor2)
    DO i = chunkstart, chunkend
             hsq = box_list(this_box)%kspace_vectors(i,4)
             prefactor = box_list(this_box)%kspace_vectors(i,5)
             factor2 = 1.0_DP/hsq
             prefactor = prefactor*factor2
             factor1 = EXP(hsq*const_val)
             factor1 = prefactor*factor1
             factor2 = const_val_2 - 2.0_DP*factor2
             factor2 = factor2*factor1
             box_list(this_box)%kspace_vectors(i,4) = factor1
             box_list(this_box)%kspace_vectors(i,5) = factor2
    END DO
    !$OMP END SIMD
    !$OMP END PARALLEL

  END SUBROUTINE Ewald_Reciprocal_Lattice_Vector_Setup
  !*****************************************************************************

  SUBROUTINE Update_System_Ewald_Reciprocal_Energy(im,is,ibox, &
    move_flag,E_reciprocal)
    !***************************************************************************
    ! The subroutine computes the difference in Ewald reciprocal space energy
    ! for a given move.
    !
    ! We will develop this routine for a number of moves.
    !
    ! Translation of COM
    ! Rotation about COM
    ! Angle distortion
    ! Rigid dihedral rotation
    ! Molecule insertion
    ! Molecule deletion
    !***************************************************************************

    USE Type_Definitions
    USE Global_Variables

    IMPLICIT NONE

!    !$ include 'omp_lib.h'

    ! Arguments
    INTEGER, INTENT(IN) :: ibox   ! box index, 1...nbr_boxes
    INTEGER, INTENT(IN) :: is     ! species index, 1...nspecies
    INTEGER, INTENT(IN) :: im     ! molecule 'locate', index to atom_list
    INTEGER, INTENT(IN) :: move_flag

    ! Returns
    REAL(DP), INTENT(OUT) :: E_reciprocal

    ! Local variables
    REAL(DP) :: q, hx, hy, hz, sin_sum_i, cos_sum_i, factor
    INTEGER :: i, ia, jm, js, kvecs, kvecs_p4
    INTEGER :: n_charged_atoms
    REAL(DP), DIMENSION(4,natoms(is)) :: rpq
    REAL(DP) :: charge

    REAL(DP) :: hdotr

    REAL(DP) :: cos_mol_im, cos_mol_im_o, sin_mol_im, sin_mol_im_o

    ! storage stuff
    INTEGER :: im_locate  ! index to cos_mol, sin_mol

    ! Initialize variables
    E_reciprocal = 0.0_DP

    kvecs = nvecs(ibox)
    kvecs_p4 = IAND(kvecs+3,NOT(3))

    IF (ALLOCATED(box_list(ibox)%sincos_sum_old)) THEN
            IF (UBOUND(box_list(ibox)%sincos_sum_old,1) .NE. &
                    UBOUND(box_list(ibox)%sincos_sum,1)) THEN
                    DEALLOCATE(box_list(ibox)%sincos_sum_old)
            END IF
    END IF
    IF (.NOT. ALLOCATED(box_list(ibox)%sincos_sum_old)) THEN
        ALLOCATE(box_list(ibox)%sincos_sum_old(UBOUND(box_list(ibox)%sincos_sum,1),2))
    END IF


    ! get the location of im for cos_mol, sin_mol arrays
    IF (is==1) THEN
      im_locate = im
    ELSE
      im_locate = SUM(max_molecules(1:is-1)) + im
    END IF
    n_charged_atoms = 0
    DO ia = 1, natoms(is)
        charge = nonbond_list(ia,is)%charge
        IF (charge == 0.0_DP) CYCLE
        n_charged_atoms = n_charged_atoms+1
        rpq(1,n_charged_atoms) = atom_list(ia,im,is)%rxp
        rpq(2,n_charged_atoms) = atom_list(ia,im,is)%ryp
        rpq(3,n_charged_atoms) = atom_list(ia,im,is)%rzp
        rpq(4,n_charged_atoms) = charge
    END DO

    !$OMP PARALLEL DEFAULT(SHARED) PRIVATE(ia) &
    !$OMP PRIVATE(cos_mol_im,sin_mol_im) &
    !$OMP PRIVATE(cos_mol_im_o, sin_mol_im_o) &
    !$OMP PRIVATE(hdotr, q, hx, hy, hz, sin_sum_i, cos_sum_i, factor)
    SELECT CASE(move_flag)
    CASE(int_translation,int_rotation,int_intra)
            !DIR$ VECTOR ALIGNED
            !$OMP DO SIMD SCHEDULE(SIMD:STATIC) &
            !$OMP PRIVATE(cos_mol_im,sin_mol_im) &
            !$OMP PRIVATE(cos_mol_im_o, sin_mol_im_o) &
            !$OMP PRIVATE(hdotr, q, hx, hy, hz, sin_sum_i, cos_sum_i, factor) &
            !$OMP REDUCTION(+:E_reciprocal)
            DO i = 1, nvecs(ibox)

              cos_mol_im = 0.0_DP
              sin_mol_im = 0.0_DP
              hx = box_list(ibox)%kspace_vectors(i,1)
              hy = box_list(ibox)%kspace_vectors(i,2)
              hz = box_list(ibox)%kspace_vectors(i,3)

              DO ia = 1, n_charged_atoms
                ! compute the new hdotr
                hdotr = hx * rpq(1,ia) + &
                        hy * rpq(2,ia) + &
                        hz * rpq(3,ia)

                q = rpq(4,ia)
                cos_mol_im = cos_mol_im + q*COS(hdotr)
                sin_mol_im = sin_mol_im + q*SIN(hdotr)
              END DO

              sin_sum_i = box_list(ibox)%sincos_sum(i,1)
              cos_sum_i = box_list(ibox)%sincos_sum(i,2)
              factor = box_list(ibox)%kspace_vectors(i,4)
              box_list(ibox)%sincos_sum_old(i,1) = sin_sum_i
              box_list(ibox)%sincos_sum_old(i,2) = cos_sum_i
              cos_mol_im_o = cos_mol(i,im_locate)
              sin_mol_im_o = sin_mol(i,im_locate)
              cos_mol(i,0) = cos_mol_im_o
              sin_mol(i,0) = sin_mol_im_o
              cos_sum_i = cos_sum_i + (cos_mol_im - cos_mol_im_o)
              sin_sum_i = sin_sum_i + (sin_mol_im - sin_mol_im_o)
              ! set the molecule's cos and sin terms to the one calculated here
              cos_mol(i,im_locate) = cos_mol_im
              sin_mol(i,im_locate) = sin_mol_im

              box_list(ibox)%sincos_sum(i,1) = sin_sum_i
              box_list(ibox)%sincos_sum(i,2) = cos_sum_i

              E_reciprocal = E_reciprocal + factor &
                           * (cos_sum_i * cos_sum_i &
                           + sin_sum_i * sin_sum_i)


            END DO
            !$OMP END DO SIMD
    CASE(int_insertion)
            !DIR$ VECTOR ALIGNED
            !$OMP DO SIMD SCHEDULE(SIMD:STATIC) &
            !$OMP PRIVATE(cos_mol_im,sin_mol_im) &
            !$OMP PRIVATE(cos_mol_im_o, sin_mol_im_o) &
            !$OMP PRIVATE(hdotr, q, hx, hy, hz, sin_sum_i, cos_sum_i, factor) &
            !$OMP REDUCTION(+:E_reciprocal)
            DO i = 1, nvecs(ibox)

              cos_mol_im = 0.0_DP
              sin_mol_im = 0.0_DP
              hx = box_list(ibox)%kspace_vectors(i,1)
              hy = box_list(ibox)%kspace_vectors(i,2)
              hz = box_list(ibox)%kspace_vectors(i,3)

              DO ia = 1, n_charged_atoms
                ! compute the new hdotr
                hdotr = hx * rpq(1,ia) + &
                        hy * rpq(2,ia) + &
                        hz * rpq(3,ia)

                q = rpq(4,ia)
                cos_mol_im = cos_mol_im + q*COS(hdotr)
                sin_mol_im = sin_mol_im + q*SIN(hdotr)
              END DO

              sin_sum_i = box_list(ibox)%sincos_sum(i,1)
              cos_sum_i = box_list(ibox)%sincos_sum(i,2)
              factor = box_list(ibox)%kspace_vectors(i,4)
              box_list(ibox)%sincos_sum_old(i,1) = sin_sum_i
              box_list(ibox)%sincos_sum_old(i,2) = cos_sum_i
              cos_sum_i = cos_sum_i + cos_mol_im
              sin_sum_i = sin_sum_i + sin_mol_im
              ! set the molecule's cos and sin terms to the one calculated here
              cos_mol(i,im_locate) = cos_mol_im
              sin_mol(i,im_locate) = sin_mol_im

              box_list(ibox)%sincos_sum(i,1) = sin_sum_i
              box_list(ibox)%sincos_sum(i,2) = cos_sum_i

              E_reciprocal = E_reciprocal + factor &
                           * (cos_sum_i * cos_sum_i &
                           + sin_sum_i * sin_sum_i)


            END DO
            !$OMP END DO SIMD
    CASE(int_deletion)
            !DIR$ VECTOR ALIGNED
            !$OMP DO SIMD &
            !$OMP PRIVATE(factor, cos_sum_i, sin_sum_i) &
            !$OMP PRIVATE(cos_mol_im_o,sin_mol_im_o) &
            !$OMP SCHEDULE(SIMD:STATIC) &
            !$OMP REDUCTION(+:E_reciprocal)
            DO i = 1, nvecs(ibox)
              sin_sum_i = box_list(ibox)%sincos_sum(i,1)
              cos_sum_i = box_list(ibox)%sincos_sum(i,2)
              box_list(ibox)%sincos_sum_old(i,1) = sin_sum_i
              box_list(ibox)%sincos_sum_old(i,2) = cos_sum_i
              sin_mol_im_o = sin_mol(i,im_locate)
              cos_mol_im_o = cos_mol(i,im_locate)
              sin_sum_i = sin_sum_i - sin_mol_im_o
              cos_sum_i = cos_sum_i - cos_mol_im_o
              sin_mol(i,0) = sin_mol_im_o
              cos_mol(i,0) = cos_mol_im_o
              box_list(ibox)%sincos_sum(i,1) = sin_sum_i
              box_list(ibox)%sincos_sum(i,2) = cos_sum_i
              factor = box_list(ibox)%kspace_vectors(i,4)


              E_reciprocal = E_reciprocal + factor &
                           * ( cos_sum_i * cos_sum_i &
                             + sin_sum_i * sin_sum_i )

            END DO
            !$OMP END DO SIMD
    END SELECT
    !$OMP END PARALLEL
    E_reciprocal = E_reciprocal * charge_factor

  END SUBROUTINE Update_System_Ewald_Reciprocal_Energy
  !*****************************************************************************

  SUBROUTINE Update_System_Ewald_Reciprocal_Energy_Widom(im,is,ibox, &
    E_reciprocal)
    !***************************************************************************
    ! The subroutine computes the difference in Ewald reciprocal space energy
    ! for a Widom insertion.
    !
    !***************************************************************************

    USE Type_Definitions
    USE Global_Variables

    IMPLICIT NONE

!    !$ include 'omp_lib.h'

    ! Arguments
    INTEGER, INTENT(IN) :: ibox   ! box index, 1...nbr_boxes
    INTEGER, INTENT(IN) :: is     ! species index, 1...nspecies
    INTEGER, INTENT(IN) :: im     ! molecule 'locate', index to atom_list

    ! Returns
    REAL(DP), INTENT(OUT) :: E_reciprocal

    ! Local variables
    REAL(DP) :: charge
    REAL(DP), DIMENSION(4,natoms(is)) :: rpq
    INTEGER :: i, ia, n_charged_atoms

    n_charged_atoms = 0
    DO ia = 1, natoms(is)
        charge = nonbond_list(ia,is)%charge
        IF (charge == 0.0_DP) CYCLE
        n_charged_atoms = n_charged_atoms+1
        rpq(1,n_charged_atoms) = widom_atoms(ia)%rxp
        rpq(2,n_charged_atoms) = widom_atoms(ia)%ryp
        rpq(3,n_charged_atoms) = widom_atoms(ia)%rzp
        rpq(4,n_charged_atoms) = charge
    END DO


    ! Initialize variables
    E_reciprocal = 0.0_DP

    ! Multiversion inner loop nested in vectorized loop
    SELECT CASE(n_charged_atoms)
    CASE(1)
            E_reciprocal = Compute_E_reciprocal(1)
    CASE(2)
            E_reciprocal = Compute_E_reciprocal(2)
    CASE(3)
            E_reciprocal = Compute_E_reciprocal(3)
    CASE(4)
            E_reciprocal = Compute_E_reciprocal(4)
    CASE(5)
            E_reciprocal = Compute_E_reciprocal(5)
    CASE(6)
            E_reciprocal = Compute_E_reciprocal(6)
    CASE(7)
            E_reciprocal = Compute_E_reciprocal(7)
    CASE(8)
            E_reciprocal = Compute_E_reciprocal(8)
    CASE DEFAULT
            E_reciprocal = Compute_E_reciprocal(n_charged_atoms)
    END SELECT


    E_reciprocal = E_reciprocal * charge_factor

    CONTAINS
            FUNCTION Compute_E_reciprocal(na) RESULT(E_reciprocal_redux)
                    !DIR$ ATTRIBUTES FORCEINLINE :: Compute_E_reciprocal
                    INTEGER, INTENT(IN) :: na
                    REAL(DP) :: E_reciprocal_redux
                    REAL(DP) :: hdotr, q, hx, hy, hz, sin_sum_i, cos_sum_i, factor
                    INTEGER :: i, ia
                    E_reciprocal_redux = 0.0_DP
                    !DIR$ VECTOR ALIGNED
                    !$OMP SIMD &
                    !$OMP PRIVATE(hdotr, q, hx, hy, hz, sin_sum_i, cos_sum_i, factor) &
                    !$OMP REDUCTION(+:E_reciprocal_redux)
                    DO i = 1, nvecs(ibox)

                      hx = box_list(ibox)%kspace_vectors(i,1)
                      hy = box_list(ibox)%kspace_vectors(i,2)
                      hz = box_list(ibox)%kspace_vectors(i,3)
                      sin_sum_i = box_list(ibox)%sincos_sum(i,1)
                      cos_sum_i = box_list(ibox)%sincos_sum(i,2)
                      factor = box_list(ibox)%kspace_vectors(i,4)

                      DO ia = 1, na
                        ! compute the new hdotr
                        hdotr = hx * rpq(1,ia) + &
                                hy * rpq(2,ia) + &
                                hz * rpq(3,ia)

                        q = rpq(4,ia)
                        sin_sum_i = sin_sum_i + q*SIN(hdotr)
                        cos_sum_i = cos_sum_i + q*COS(hdotr)
                      END DO

                      sin_sum_i = sin_sum_i * sin_sum_i
                      sin_sum_i = sin_sum_i + cos_sum_i*cos_sum_i


                      E_reciprocal_redux = E_reciprocal_redux + factor*sin_sum_i


                    END DO
                    !$OMP END SIMD
            END FUNCTION Compute_E_reciprocal

  END SUBROUTINE Update_System_Ewald_Reciprocal_Energy_Widom
  !*****************************************************************************

  SUBROUTINE Compute_System_Self_Energy(this_box)
    !***************************************************************************
    ! This subroutine calculates the constant term that arises from particles
    ! interacting with themselves in the reciprocal space. The subroutine needs
    ! to be called only once as it is a constant term as long as the particles
    ! and their charges remain the same.
    !***************************************************************************

    USE Type_Definitions
    USE Global_Variables

    IMPLICIT NONE

    ! Arguments
    INTEGER :: this_box

    ! Returns
    ! energy(this_box)%self, global variable

    ! Local Variables
    INTEGER :: is,im, this_locate, ia
    REAL(DP) :: q, E_self

    E_self = 0.0_DP


   DO is = 1, nspecies
     imLOOP: DO im = 1, nmols(is,this_box)

       this_locate = locate(im,is,this_box)
       IF (.NOT. molecule_list(this_locate,is)%live) CYCLE imLOOP

       DO ia = 1, natoms(is)
         ! obtain the charge
         q = nonbond_list(ia,is)%charge
         E_self = E_self + q * q
       END DO
     END DO imLOOP
   END DO

    IF (int_charge_sum_style(this_box) == charge_ewald) THEN
           E_self = - E_self * charge_factor * alpha_ewald(this_box) / rootPI
           energy(this_box)%self = E_self
    ELSE IF (int_charge_sum_style(this_box) == charge_dsf) THEN
           E_self = E_self * (alpha_dsf(this_box) / rootPI + dsf_factor1(this_box)/2.0_DP)
           energy(this_box)%self = - E_self * charge_factor
    END IF

END SUBROUTINE Compute_System_Self_Energy


!*****************************************************************************

SUBROUTINE Compute_Molecule_Self_Energy(im,is,this_box,E_self)
  !***************************************************************************
  ! This subroutine calculates the self Ewald energy for the
  ! input molecule.
  !
  ! CALLED BY:
  !
  ! GEMC_Particle_Transfer
  ! Insertion
  ! Deletion
  ! Reaction
  !
  !***************************************************************************

  USE Type_Definitions
  USE Global_Variables

  IMPLICIT NONE

  ! Arguments
  INTEGER, INTENT(IN) :: im, is, this_box

  ! Returns
  REAL(DP), INTENT(OUT) :: E_self

  ! Local variables
  REAL(DP) :: q(natoms(is))

  ! Initialize variables
  E_self = 0.0_DP
  q = nonbond_list(1:natoms(is),is)%charge

  IF (int_charge_sum_style(this_box) == charge_ewald) THEN
          E_self = - DOT_PRODUCT(q,q) * charge_factor * alpha_ewald(this_box) / rootPI
  ELSE IF (int_charge_sum_style(this_box) == charge_dsf) THEN
          E_self = - DOT_PRODUCT(q,q) * (alpha_dsf(this_box) / rootPI + dsf_factor1(this_box)/2.0_DP) * charge_factor
  END IF

END SUBROUTINE Compute_Molecule_Self_Energy
  !*****************************************************************************

  SUBROUTINE Compute_System_Total_Energy(this_box,intra_flag,overlap)
    !***************************************************************************
    ! The subroutine calculates the total energy of a given box. The identity of
    ! the box is passed to the routine along with the intra_flag to indicate
    ! whether intramolecular computation is required. The flag will mostly be
    ! set to true except in the case of volume change move that is designed so
    ! that the intramolecular DOFs do not change.
    !***************************************************************************

    IMPLICIT NONE

    INTEGER, INTENT(IN) :: this_box
    LOGICAL, INTENT(IN) :: intra_flag
    LOGICAL, INTENT(OUT) :: overlap

    !---------------------------------------------------------------------------

    INTEGER :: im, is, this_im, im_1, im_2, is_1, is_2, this_im_1, this_im_2

    REAL(DP) :: v_mol_bond, v_mol_angle, v_mol_dihedral, v_mol_improper
    REAL(DP) :: v_mol_intra_vdw, v_mol_intra_qq, v_mol_inter_qq
    REAL(DP) :: vlj_pair, vqq_pair, e_lrc
    REAL(DP) :: rcom, rx, ry, rz
    REAL(DP) :: E_inter_vdw, E_inter_qq
    REAL(DP) :: v_mol_self
    REAL(DP) :: rijsq
    REAL(DP) :: v_bond, v_angle, v_dihedral, v_intra, v_improper
    REAL(DP) :: v_intra_vdw, v_intra_qq, v_inter_qq

    LOGICAL :: get_interaction,intra_overlap

    INTEGER :: locate_1, locate_2
    LOGICAL :: l_pair_store, my_overlap, shared_overlap

    my_overlap = .FALSE.
    shared_overlap = .FALSE.
    overlap = .FALSE.

    ! Initialize the energies

    energy(this_box)%total = 0.0_DP
    energy(this_box)%inter = 0.0_DP
    energy(this_box)%inter_vdw = 0.0_DP
    energy(this_box)%lrc = 0.0_DP
    energy(this_box)%inter_q = 0.0_DP
    energy(this_box)%reciprocal = 0.0_DP
    ! Compute the intramolecular energy of the system if the flag is set.

    IF (intra_flag) THEN

       energy(this_box)%intra = 0.0_DP
       energy(this_box)%bond  = 0.0_DP
       energy(this_box)%angle = 0.0_DP
       energy(this_box)%dihedral = 0.0_DP
       energy(this_box)%improper = 0.0_DP
       energy(this_box)%intra_vdw = 0.0_DP
       energy(this_box)%intra_q = 0.0_DP
       energy(this_box)%self = 0.0_DP

       DO is = 1, nspecies
          v_intra = 0.0_DP
          v_bond= 0.0_DP
          v_angle= 0.0_DP
          v_dihedral= 0.0_DP
          v_improper = 0.0_DP
          v_intra_vdw= 0.0_DP
          v_intra_qq = 0.0_DP
          v_inter_qq = 0.0_DP
          !$OMP PARALLEL DO DEFAULT(SHARED) &
          !$OMP SCHEDULE(DYNAMIC) &
          !$OMP PRIVATE(im, this_im, v_mol_bond, v_mol_angle, v_mol_dihedral) &
          !$OMP PRIVATE(v_mol_improper,v_mol_intra_vdw,v_mol_intra_qq, v_mol_inter_qq, intra_overlap) &
          !$OMP REDUCTION(+:v_intra,v_bond, v_angle, v_dihedral,v_improper, v_intra_vdw, v_intra_qq, v_inter_qq)
          imLoop:DO im = 1, nmols(is,this_box)

             this_im = locate(im,is,this_box)
             IF (.NOT. molecule_list(this_im,is)%live) CYCLE imLoop

             IF (SHARED_OVERLAP) CYCLE imLOOP

             CALL Compute_Molecule_Bond_Energy(this_im,is,v_mol_bond)
             CALL Compute_Molecule_Angle_Energy(this_im,is,v_mol_angle)
             CALL Compute_Molecule_Dihedral_Energy(this_im,is,v_mol_dihedral)
             CALL Compute_Molecule_Improper_Energy(this_im,is,v_mol_improper)

             intra_overlap = .FALSE.
             CALL Compute_Molecule_Nonbond_Intra_Energy(this_im,is, &
                     v_mol_intra_vdw,v_mol_intra_qq,v_mol_inter_qq, &
                     intra_overlap)

             IF (intra_overlap) THEN
                SHARED_OVERLAP = .TRUE.
             END IF

             v_intra = v_intra + v_mol_bond + v_mol_angle &
                     + v_mol_dihedral + v_mol_improper &
                     + v_mol_intra_qq + v_mol_intra_vdw
             v_bond = v_bond + v_mol_bond
             v_angle = v_angle + v_mol_angle
             v_dihedral = v_dihedral + v_mol_dihedral
             v_improper = v_improper + v_mol_improper
             v_intra_vdw = v_intra_vdw + v_mol_intra_vdw
             v_intra_qq = v_intra_qq + v_mol_intra_qq
             ! electrostatic energy between this molecule and its periodic image
             v_inter_qq = v_inter_qq + v_mol_inter_qq

          END DO imLoop
          !$OMP END PARALLEL DO
          IF (SHARED_OVERLAP) THEN
             overlap = .TRUE.
             RETURN
          END IF

          energy(this_box)%intra = energy(this_box)%intra + v_intra
          energy(this_box)%bond = energy(this_box)%bond + v_bond
          energy(this_box)%angle = energy(this_box)%angle + v_angle
          energy(this_box)%dihedral = energy(this_box)%dihedral + v_dihedral
          energy(this_box)%improper = energy(this_box)%improper + v_improper
          energy(this_box)%intra_vdw = energy(this_box)%intra_vdw + v_intra_vdw
          energy(this_box)%intra_q   = energy(this_box)%intra_q   + v_intra_qq
          energy(this_box)%inter_q = energy(this_box)%inter_q + v_inter_qq
       END DO

    END IF

    ! Calculate the total intermolecular energy of the system. The calculation
    ! is divided into two parts. The first part computes the interaction between
    ! the molecules of the same species, while the second
    ! bit obtains the interaction between molecules of different species.

    l_pair_store = .FALSE.
    IF (l_pair_nrg .AND. (.NOT. cbmc_flag)) l_pair_store = .TRUE.

    DO is = 1, nspecies
       imLOOP1: DO im_1 = 1, nmols(is,this_box)
          this_im_1 = locate(im_1,is,this_box)
          IF (.NOT. molecule_list(this_im_1,is)%live) CYCLE imLOOP1

          IF (l_pair_store) THEN
                  CALL Get_Position_Alive(this_im_1, is, locate_1)
                  pair_nrg_vdw(locate_1,locate_1) = 0.0_DP
                  pair_nrg_qq(locate_1,locate_1) = 0.0_DP
          END IF

          E_inter_vdw = 0.0_DP
          E_inter_qq  = 0.0_DP

          !$OMP PARALLEL DO DEFAULT(SHARED) &
          !$OMP SCHEDULE(DYNAMIC) &
          !$OMP PRIVATE(im_2, this_im_2, locate_2, get_interaction) &
          !$OMP PRIVATE(rcom, rx, ry, rz, vlj_pair, vqq_pair) &
          !$OMP PRIVATE(my_overlap) &
          !$OMP REDUCTION(+: E_inter_vdw, E_inter_qq)

          imLOOP2: DO im_2 = im_1 + 1, nmols(is,this_box)
             this_im_2 = locate(im_2,is,this_box)
             IF (.NOT. molecule_list(this_im_2,is)%live) CYCLE imLOOP2

             IF (SHARED_OVERLAP) CYCLE imLOOP2

             IF (l_pair_store) THEN
                CALL Get_Position_Alive(this_im_2,is,locate_2)

                pair_nrg_vdw(locate_1,locate_2) = 0.0_DP
                pair_nrg_vdw(locate_2,locate_1) = 0.0_DP

                pair_nrg_qq(locate_1,locate_2) = 0.0_DP
                pair_nrg_qq(locate_2,locate_1) = 0.0_DP

             END IF

             CALL Check_MoleculePair_Cutoff(this_im_1,is,this_im_2,is,get_interaction, &
                  rcom,rx,ry,rz)

            ! rijsq = rcom * rcom

             IF (.NOT. get_interaction) CYCLE imLoop2
             ! Compute the intermolecular interactions between these two molecules

             CALL Compute_MoleculePair_Energy(this_im_1,is,this_im_2,is, &
                  this_box,vlj_pair,vqq_pair,my_overlap)

             !             IF (overlap) RETURN
             IF (my_overlap) THEN
                SHARED_OVERLAP = .true.
             END IF

             E_inter_vdw  = E_inter_vdw + vlj_pair
             E_inter_qq   = E_inter_qq  + vqq_pair

          END DO imLOOP2
          !$OMP END PARALLEL DO
          IF (SHARED_OVERLAP) THEN
             overlap = .true.
             RETURN
          ENDIF

          energy(this_box)%inter_vdw = energy(this_box)%inter_vdw + E_inter_vdw
          energy(this_box)%inter_q = energy(this_box)%inter_q + E_inter_qq

       END DO imLOOP1
    END DO

    ! Now compute the interaction with the molecules between different species
    DO is_1 = 1, nspecies
       imLOOP3: DO im_1 = 1, nmols(is_1,this_box)
          this_im_1 = locate(im_1,is_1,this_box)
          IF (.NOT. molecule_list(this_im_1,is_1)%live) CYCLE imLOOP3

          IF (l_pair_store) CALL Get_Position_Alive(this_im_1,is_1,locate_1)

          DO is_2 = is_1 + 1, nspecies
             E_inter_vdw = 0.0_DP
             E_inter_qq  = 0.0_DP

             !$OMP PARALLEL DO DEFAULT(SHARED) &
             !$OMP SCHEDULE(DYNAMIC) &
             !$OMP PRIVATE(im_2, this_im_2, locate_2, get_interaction) &
             !$OMP PRIVATE(rcom, rx, ry, rz, vlj_pair, vqq_pair) &
             !$OMP PRIVATE(my_overlap) &
             !$OMP REDUCTION(+: E_inter_vdw, E_inter_qq)

             imLOOP4: DO im_2 = 1, nmols(is_2,this_box)
                this_im_2 = locate(im_2,is_2,this_box)
                IF (.NOT. molecule_list(this_im_2,is_2)%live) CYCLE imLOOP4

                IF (SHARED_OVERLAP) CYCLE imLOOP4

                IF (l_pair_store) THEN
                   CALL Get_Position_Alive(this_im_2,is_2,locate_2)

                   pair_nrg_vdw(locate_1,locate_2) = 0.0_DP
                   pair_nrg_vdw(locate_2,locate_1) = 0.0_DP

                   pair_nrg_qq(locate_1,locate_2) = 0.0_DP
                   pair_nrg_qq(locate_2,locate_1) = 0.0_DP

                END IF

                ! Check to see if the interaction needs to be computed between
                ! the molecules
                CALL Check_MoleculePair_Cutoff(this_im_1,is_1,this_im_2,is_2, &
                     get_interaction,rcom,rx,ry,rz)
!                rijsq = rcom * rcom

                IF (.NOT. get_interaction ) CYCLE imLOOP4

                ! Note that this call will modify the pair interaction energies
                ! if l_pair_nrg variable is .TRUE.

                CALL Compute_MoleculePair_Energy(this_im_1,is_1,this_im_2,is_2,&
                     this_box,vlj_pair,vqq_pair,my_overlap)

                IF (my_overlap) THEN
                   SHARED_OVERLAP = .true.
                END IF

                E_inter_vdw  = E_inter_vdw + vlj_pair
                E_inter_qq   = E_inter_qq  + vqq_pair

             END DO imLOOP4
             !$OMP END PARALLEL DO
             IF (SHARED_OVERLAP) THEN
                overlap = .true.
                RETURN
             ENDIF

             energy(this_box)%inter_vdw = energy(this_box)%inter_vdw + E_inter_vdw
             energy(this_box)%inter_q = energy(this_box)%inter_q + E_inter_qq

          END DO

       END DO imLOOP3
    END DO

    energy(this_box)%inter = energy(this_box)%inter_q + energy(this_box)%inter_vdw

    ! Compute the reciprocal and self energy terms of the electrostatic energies if flag for Ewald is set.
    IF (int_charge_style(this_box) == charge_coul) THEN
       IF (int_charge_sum_style(this_box) == charge_ewald) THEN

            CALL Compute_System_Ewald_Reciprocal_Energy(this_box)

            energy(this_box)%inter = energy(this_box)%inter &
                                   + energy(this_box)%reciprocal

       END IF

       CALL Compute_System_Self_Energy(this_box)

       energy(this_box)%inter = energy(this_box)%inter &
                              + energy(this_box)%self

    END IF

    ! Long range correction if it is required
    IF (int_vdw_sum_style(this_box) == vdw_cut_tail) THEN
       CALL Compute_LR_Correction(this_box,e_lrc)
       ! add to the correction to the inter energy of the system
       energy(this_box)%lrc = e_lrc
       energy(this_box)%inter = energy(this_box)%inter + energy(this_box)%lrc
    END IF

    ! The total system energy. Note that intra_flag is not used for this
    ! calculation, beacuse, if the flag is true, we already computed the energy,
    ! if not we are using the old global energy (the routine
    ! did not modify the energy).
    energy(this_box)%total = energy(this_box)%intra + energy(this_box)%inter

  END SUBROUTINE Compute_System_Total_Energy
  !*****************************************************************************

  SUBROUTINE Compute_LR_Correction(this_box, e_lrc)
    !***************************************************************************
    ! The subroutine calculates the long range correction for the given box.
    !
    !***************************************************************************
    INTEGER, INTENT(IN) :: this_box
    REAL(DP), INTENT(OUT) :: e_lrc

    INTEGER ::  ia, ja, is, js
    REAL(DP) :: epsij, sigij, sigij2, sigij6, sigij12, mie_n, mie_m, mie_coeff
    REAL(DP) :: SigOverRcut, SigOverRn, SigOverRm
    REAL(DP) :: e_lrc_ia_ja

    e_lrc = 0.0_DP

    IF (int_vdw_style(this_box) == vdw_lj) THEN

      DO ia = 1, nbr_atomtypes

         e_lrc_ia_ja = 0.0_DP

         DO ja = 1, nbr_atomtypes

            epsij = vdw_param1_table(ia,ja)
            sigij = vdw_param2_table(ia,ja)

            sigij2 = sigij*sigij

            sigij6 = sigij2*sigij2*sigij2

            sigij12 = sigij6*sigij6

            e_lrc_ia_ja = e_lrc_ia_ja + nint_beads(ja,this_box) * &
                 4.0_DP * epsij * (sigij12 /(9.0_DP*rcut9(this_box)) - &
                 (sigij6 / (3.0_DP*rcut3(this_box))))
         END DO

         e_lrc = e_lrc + REAL( nint_beads(ia,this_box), DP ) * e_lrc_ia_ja
      END DO

      e_lrc = 2.0_DP * PI * e_lrc/box_list(this_box)%volume

    ELSE IF (int_vdw_style(this_box) == vdw_mie) THEN
      DO ia = 1, nbr_atomtypes
          e_lrc_ia_ja = 0.0_DP

          DO ja = 1, nbr_atomtypes

             epsij = vdw_param1_table(ia,ja)
             sigij = vdw_param2_table(ia,ja)
             mie_n = vdw_param3_table(ia,ja) ! repulsive exponent
             mie_m = vdw_param4_table(ia,ja) ! dispersive exponent
             mie_coeff = mie_n/(mie_n-mie_m)*(mie_n/mie_m)**(mie_m/(mie_n-mie_m))
             SigOverRcut = sigij/rcut_vdw(this_box)
             SigOverRn = SigOverRcut ** mie_n
             SigOverRm = SigOverRcut ** mie_m

             e_lrc_ia_ja = e_lrc_ia_ja + nint_beads(ja,this_box) * &
                   mie_coeff * epsij * rcut_vdw(this_box)**3.0_DP * ((SigOverRn/(3.0_DP-mie_n)) + &
                  (SigOverRm / (mie_m -3.0_DP)))
          END DO
          e_lrc = e_lrc + REAL( nint_beads(ia,this_box), DP ) * e_lrc_ia_ja

      END DO
      e_lrc = - 2.0_DP * PI * e_lrc/box_list(this_box)%volume
    END IF

  END SUBROUTINE Compute_LR_Correction

  !*****************************************************************************

  SUBROUTINE Check_MoleculePair_Cutoff(im_1,is_1,im_2,is_2,get_interaction, &
    rcom,rxcom,rycom,rzcom)

    REAL(DP) :: rxijp, ryijp, rzijp, rcom, rxcom, rycom, rzcom, rinteraction

    INTEGER :: this_box
    INTEGER :: im_1,is_1,im_2,is_2

    LOGICAL :: get_interaction

    TYPE(Molecule_Class), POINTER :: molecule_1, molecule_2

    IF (im_1 == widom_locate .AND. is_1 == widom_species) THEN
            molecule_1 => widom_molecule
    ELSE
            molecule_1 => molecule_list(im_1,is_1)
    END IF
    IF (im_2 == widom_locate .AND. is_2 == widom_species) THEN
            molecule_2 => widom_molecule
    ELSE
            molecule_2 => molecule_list(im_2,is_2)
    END IF

    ! Initially set the interaction to true.

    get_interaction = .TRUE.

    ! Figure out the box to be used later.

    this_box = molecule_1%which_box

    IF(int_vdw_sum_style(this_box) == vdw_minimum) RETURN

    ! Parent separation

    rxijp = molecule_1%xcom - molecule_2%xcom
    ryijp = molecule_1%ycom - molecule_2%ycom
    rzijp = molecule_1%zcom - molecule_2%zcom

    ! Compute the minimum image distance

    CALL Minimum_Image_Separation(this_box,rxijp,ryijp,rzijp,rxcom,rycom,rzcom)

    rcom = DSQRT(rxcom*rxcom + rycom*rycom + rzcom*rzcom)

    IF (CBMC_flag) THEN

       rinteraction = rcut_cbmc(this_box) + molecule_1%max_dcom &
            + molecule_2%max_dcom

       IF (rcom > rinteraction) get_interaction = .FALSE.

    ELSE

       rinteraction = rcut_max(this_box) + molecule_1%max_dcom &
            + molecule_2%max_dcom

       IF (rcom > rinteraction) get_interaction = .FALSE.

    END IF

 END SUBROUTINE Check_MoleculePair_Cutoff
!*******************************************************************************

!*******************************************************************************
 SUBROUTINE Check_AtomPair_Cutoff(rijsq,get_vdw,get_qq,this_box)

   INTEGER  :: this_box
   REAL(DP) :: rijsq
   LOGICAL  :: get_vdw, get_qq

   get_vdw = .FALSE.
   get_qq = .FALSE.

   VDW_Test2: IF (int_vdw_style(this_box) == vdw_none) THEN
      get_vdw = .FALSE.

   ELSEIF (int_vdw_style(this_box) == vdw_lj) THEN

      IF (CBMC_flag) THEN
         IF (rijsq <= rcut_cbmcsq(this_box)) THEN
            get_vdw = .TRUE.
         ELSE
            get_vdw = .FALSE.
         ENDIF
      ELSEIF (int_vdw_sum_style(this_box) == vdw_cut .OR. int_vdw_sum_style(this_box) &
              == vdw_cut_shift .OR. int_vdw_sum_style(this_box) == vdw_cut_tail &
              .OR. int_vdw_sum_style(this_box) == vdw_cut_shift_force ) THEN

         IF (rijsq <= rcut_vdwsq(this_box)) THEN
            get_vdw = .TRUE.
         ELSE
            get_vdw = .FALSE.
         ENDIF

      ELSEIF (int_vdw_sum_style(this_box) == vdw_minimum) THEN
         get_vdw = .TRUE.

      ELSEIF (int_vdw_sum_style(this_box) == vdw_charmm) THEN
         get_vdw = .TRUE.

      ELSEIF (int_vdw_sum_style(this_box) == vdw_cut_switch) THEN

         IF (rijsq <= roff_switch_sq(this_box)) THEN
            get_vdw = .TRUE.
         ELSE
            get_vdw = .FALSE.
         END IF

      ENDIF


   ELSEIF (int_vdw_style(this_box) == vdw_mie) THEN

      IF (CBMC_flag) THEN
         IF (rijsq <= rcut_cbmcsq(this_box)) THEN
            get_vdw = .TRUE.
         ELSE
            get_vdw = .FALSE.
         ENDIF
      ELSEIF (int_vdw_sum_style(this_box) == vdw_cut .OR. int_vdw_sum_style(this_box) &
           == vdw_cut_shift .OR. int_vdw_sum_style(this_box) == vdw_cut_tail) THEN

         IF (rijsq <= rcut_vdwsq(this_box)) THEN
            get_vdw = .TRUE.
         ELSE
            get_vdw = .FALSE.
         ENDIF
      END IF

   ELSE
      err_msg = ""
      err_msg(1) = 'vdw_style must be NONE, LJ or Mie'
      CALL Clean_Abort(err_msg,'Compute_Atom_Nonbond_Energy')

   ENDIF VDW_Test2

   ! Charge sum tests
   IF (int_charge_style(this_box) == charge_none) THEN
      get_qq = .FALSE.
   ELSEIF (int_charge_style(this_box) == charge_coul) THEN

      IF (int_charge_sum_style(this_box) == charge_cut .OR. &
          int_charge_sum_style(this_box) == charge_ewald .OR. &
          int_charge_sum_style(this_box) == charge_dsf) THEN

         IF(CBMC_flag) THEN
            IF (rijsq <= rcut_cbmcsq(this_box)) THEN
               get_qq = .TRUE.
            ELSE
               get_qq = .FALSE.
            ENDIF
         ELSE
            IF (rijsq <= rcut_coulsq(this_box)) THEN
               get_qq = .TRUE.
            ELSE
               get_qq = .FALSE.
            ENDIF
         ENDIF
      ELSEIF (int_charge_sum_style(this_box) == charge_minimum) THEN
         get_qq = .TRUE.

      END IF

   ENDIF

   RETURN

 END SUBROUTINE Check_AtomPair_Cutoff

 SUBROUTINE Compute_System_Total_Force(this_box)

   !****************************************************************************
   ! The subroutine calculates the total forces of a given box.
   ! The identity of the box is passed to the routine.
   ! The forces are then used to compute the pressure tensor.
   !
   ! CALLS
   !
   ! CALLED BY
   !
   ! Compute_Pressure
   !
   !****************************************************************************

   IMPLICIT NONE

   INTEGER, INTENT(IN) :: this_box

   !----------------------------------------------------------------------------

   INTEGER ::  is, im_1, im_2, is_1, is_2, this_im_1, this_im_2

   REAL(DP) :: rcom, rx, ry, rz, w_lrc

   REAL(DP),DIMENSION(3,3) :: tv_pair, tc_pair, w_inter_vdw, w_inter_charge

   LOGICAL :: get_interaction

   W_tensor_vdw(:,:,this_box) = 0.0_DP
   W_tensor_charge(:,:,this_box) = 0.0_DP
   W_tensor_recip(:,:,this_box) = 0.0_DP
   W_tensor_elec(:,:,this_box) =  0.0_DP

   DO is = 1, nspecies
      imLOOP1: DO im_1 = 1, nmols(is,this_box)
         this_im_1 = locate(im_1,is,this_box)
         IF (.NOT. molecule_list(this_im_1,is)%live) CYCLE imLOOP1

         w_inter_vdw(:,:) = 0.0_DP
         w_inter_charge(:,:) = 0.0_DP

         !$OMP PARALLEL DO DEFAULT(SHARED) &
         !$OMP SCHEDULE(DYNAMIC) &
         !$OMP PRIVATE(im_2, this_im_2, get_interaction) &
         !$OMP PRIVATE(rcom, rx, ry, rz, tv_pair, tc_pair) &
         !$OMP REDUCTION(+:w_inter_vdw, w_inter_charge)
         imLOOP2: DO im_2 = im_1 + 1, nmols(is,this_box)
            this_im_2 = locate(im_2,is,this_box)
            IF (.NOT. molecule_list(this_im_2,is)%live) CYCLE imLOOP2

            CALL Check_MoleculePair_Cutoff(this_im_1,is,this_im_2,is,get_interaction, &
                                   rcom,rx,ry,rz)

            IF (.NOT. Get_Interaction) CYCLE imLOOP2

            CALL Compute_MoleculePair_Force(this_im_1,is,this_im_2,is, &
                   this_box,tv_pair,tc_pair,rx,ry,rz)

            w_inter_vdw(:,:) = w_inter_vdw(:,:) + tv_pair(:,:)
            w_inter_charge(:,:) = w_inter_charge(:,:) + tc_pair(:,:)

         END DO imLOOP2
         !$OMP END PARALLEL DO

         W_tensor_vdw(:,:,this_box) = W_tensor_vdw(:,:,this_box) + w_inter_vdw(:,:)
         W_tensor_charge(:,:,this_box) = W_tensor_charge(:,:,this_box) + w_inter_charge(:,:)

      END DO imLOOP1
   END DO

   DO is_1 = 1, nspecies
      imLOOP3: DO im_1 = 1, nmols(is_1,this_box)
         this_im_1 = locate(im_1,is_1,this_box)
         IF (.NOT. molecule_list(this_im_1,is_1)%live) CYCLE imLOOP3

         DO is_2 = is_1 + 1, nspecies

            w_inter_vdw(:,:) = 0.0_DP
            w_inter_charge(:,:) = 0.0_DP

            !$OMP PARALLEL DO DEFAULT(SHARED) &
            !$OMP SCHEDULE(DYNAMIC) &
            !$OMP PRIVATE(im_2, this_im_2, get_interaction) &
            !$OMP PRIVATE(rcom, rx, ry, rz, tv_pair, tc_pair) &
            !$OMP REDUCTION(+:w_inter_vdw,w_inter_charge)
            imLOOP4: DO im_2 = 1, nmols(is_2,this_box)
               this_im_2 = locate(im_2,is_2,this_box)
               IF (.NOT. molecule_list(this_im_2,is_2)%live) CYCLE imLOOP4

               ! Check to see if the interaction needs to be computed between the molecules
               CALL Check_MoleculePair_Cutoff(this_im_1,is_1,this_im_2,is_2,get_interaction,rcom,rx,ry,rz)

               IF (.NOT. get_interaction ) CYCLE imLOOP4

               CALL Compute_MoleculePair_Force(this_im_1,is_1,this_im_2,is_2,this_box,tv_pair,tc_pair,rx,ry,rz)

               !                W_tensor_vdw(:,:,this_box) = W_tensor_vdw(:,:,this_box) + tv_pair(:,:)
!                W_tensor_charge(:,:,this_box) = W_tensor_charge(:,:,this_box) + tc_pair(:,:)

               w_inter_vdw(:,:) = w_inter_vdw(:,:) + tv_pair(:,:)
               w_inter_charge(:,:) = w_inter_charge(:,:) + tc_pair(:,:)

            END DO imLOOP4

            W_tensor_vdw(:,:,this_box) = W_tensor_vdw(:,:,this_box) + w_inter_vdw(:,:)
            W_tensor_charge(:,:,this_box) = W_tensor_charge(:,:,this_box) + w_inter_charge(:,:)
         END DO

      END DO imLOOP3
    END DO

    IF (int_charge_sum_style(this_box) == charge_ewald) THEN

       CALL Compute_System_Ewald_Reciprocal_Force(this_box)
       W_tensor_elec(:,:,this_box) =  W_tensor_recip(:,:,this_box)
    END IF

    IF (int_vdw_sum_style(this_box) == vdw_cut_tail) THEN

       CALL Compute_LR_Force(this_box,w_lrc)
       virial(this_box)%lrc = w_lrc

    END IF

    W_tensor_elec(:,:,this_box) = (W_tensor_elec(:,:,this_box) + W_tensor_charge(:,:,this_box)) * charge_factor
    W_tensor_total(:,:,this_box) = W_tensor_vdw(:,:,this_box) + W_tensor_elec(:,:,this_box)

  END SUBROUTINE Compute_System_Total_Force
  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_MoleculePair_Force(im,is,jm,js,this_box,tens_vdw,tens_charge,rabx,raby,rabz)
    !***************************************************************************
    ! The subroutine returns the interaction force of the input molecule with
    ! another molecule. Thus,
    ! it computes the intermolecular vdw and electrostatic interactions.
    !
    ! CALLED BY
    !
    ! Added by Jindal Shah on 12/10/07
    !***************************************************************************

    IMPLICIT NONE

    INTEGER, INTENT(IN) :: im, is, jm, js, this_box
    !---------------------------------------------------------------------------

    INTEGER :: ia, ja

    REAL(DP) :: rxijp, ryijp, rzijp, rxij, ryij, rzij, rijsq, wij_vdw, wij_qq
    REAL(DP) :: rabx, raby, rabz
    REAL(DP),DIMENSION(3,3) :: tens_vdw, tens_charge

    REAL(DP) :: ffc, wxy, wxz, wyz

    LOGICAL :: get_vdw, get_qq

    tens_vdw(:,:) = 0.0_DP
    tens_charge(:,:) = 0.0_DP

    DO ia = 1, natoms(is)
       DO ja = 1, natoms(js)

          ! Obtain the minimum image separation
          rxijp = atom_list(ia,im,is)%rxp - atom_list(ja,jm,js)%rxp
          ryijp = atom_list(ia,im,is)%ryp - atom_list(ja,jm,js)%ryp
          rzijp = atom_list(ia,im,is)%rzp - atom_list(ja,jm,js)%rzp

          ! Now get the minimum image separation
          CALL Minimum_Image_Separation(this_box,rxijp,ryijp,rzijp, &
                  rxij,ryij,rzij)

          rijsq = rxij*rxij + ryij*ryij + rzij*rzij

          ! Now figure out what needs to be computed, then call pair_energy
          CALL Check_AtomPair_Cutoff(rijsq,get_vdw,get_qq,this_box)

          ! Compute vdw and q-q energy using if required
          IF (get_vdw .OR. get_qq) THEN

             CALL Compute_AtomPair_Force(rijsq,is,im,ia,js,jm,ja,&
                  get_vdw,get_qq,Wij_vdw,Wij_qq)

             ffc = Wij_vdw/rijsq

             wxy = ffc*(0.5_DP*(rxij*raby+ryij*rabx))
             wxz = ffc*(0.5_DP*(rxij*rabz+rzij*rabx))
             wyz = ffc*(0.5_DP*(ryij*rabz+rzij*raby))

             tens_vdw(1,1) = tens_vdw(1,1) + ffc*rxij*rabx
             tens_vdw(1,2) = tens_vdw(1,2) + wxy
             tens_vdw(1,3) = tens_vdw(1,3) + wxz
             tens_vdw(2,1) = tens_vdw(2,1) + wxy
             tens_vdw(2,2) = tens_vdw(2,2) + ffc*ryij*raby
             tens_vdw(2,3) = tens_vdw(2,3) + wyz
             tens_vdw(3,1) = tens_vdw(3,1) + wxz
             tens_vdw(3,2) = tens_vdw(3,2) + wyz
             tens_vdw(3,3) = tens_vdw(3,3) + ffc*rzij*rabz

             ffc = Wij_qq/rijsq

             wxy = ffc*(0.5_DP*(rxij*raby+ryij*rabx))
             wxz = ffc*(0.5_DP*(rxij*rabz+rzij*rabx))
             wyz = ffc*(0.5_DP*(ryij*rabz+rzij*raby))

             tens_charge(1,1) = tens_charge(1,1) + ffc*rxij*rabx
             tens_charge(1,2) = tens_charge(1,2) + wxy
             tens_charge(1,3) = tens_charge(1,3) + wxz
             tens_charge(2,1) = tens_charge(2,1) + wxy
             tens_charge(2,2) = tens_charge(2,2) + ffc*ryij*raby
             tens_charge(2,3) = tens_charge(2,3) + wyz
             tens_charge(3,1) = tens_charge(3,1) + wxz
             tens_charge(3,2) = tens_charge(3,2) + wyz
             tens_charge(3,3) = tens_charge(3,3) + ffc*rzij*rabz

          END IF

       END DO

    END DO

  END SUBROUTINE Compute_MoleculePair_Force
  !-----------------------------------------------------------------------------
  SUBROUTINE Compute_AtomPair_Force &
       (rijsq,is,im,ia,js,jm,ja,get_vdw,get_qq,Wij_vdw,Wij_qq)

    ! LJ potential:  Wij = -rij/3 * d Eij / d rij.
    ! Use the virial in: P = NkT + < W >

    ! Computes the vdw and q-q pair force between atoms ia and ja of molecules
    ! im and jm and species is and js, given their separation rijsq. I have
    ! passed each component of separation but right now this is unnecessary.
    ! It also computes the real space part of the Ewald sum if necessary.

    ! Called by: Compute_System_Total_Force
  !-----------------------------------------------------------------------------
    ! Passed to
    REAL(DP) :: rxij,ryij,rzij,rijsq
    INTEGER :: is,im,ia,js,jm,ja
    LOGICAL :: get_vdw,get_qq

    ! Returned
    REAL(DP) :: Wij_vdw,Wij_qq

    ! Local
    INTEGER :: ibox
    ! LJ potential
    INTEGER :: itype, jtype
    REAL(DP) :: eps, sig, Eij_vdw
    REAL(DP) :: rij, rcut_vdw
    REAL(DP) :: SigByR2,SigByR6,SigByR12
    REAL(DP) :: SigByR2_shift,SigByR6_shift,SigByR12_shift
    REAL(DP) :: roffsq_rijsq, roffsq_rijsq_sq, factor2, fscale
    ! Mie potential
    REAL(DP) :: SigByR, SigByRn, SigByRm, mie_coeff, mie_n, mie_m
    ! Coulomb potential
    REAL(DP) :: qi, qj, erfc_val, prefactor
    REAL(DP) :: ewald_constant, exp_const

    Wij_vdw = 0.0_DP
    Wij_qq = 0.0_DP
  !-----------------------------------------------------------------------------
    ibox = molecule_list(im,is)%which_box

    ! If either atom is not yet present, then don't try to compute an energy
    ExistCheck: &
    IF (atom_list(ia,im,is)%exist .AND. atom_list(ja,jm,js)%exist) THEN

       ! Determine atom type indices
       itype = nonbond_list(ia,is)%atom_type_number
       jtype = nonbond_list(ja,js)%atom_type_number

       VDW_calc: &
       IF (get_vdw .AND. itype /= 0 .AND. jtype /=0) THEN

         IF (int_vdw_style(ibox) == vdw_lj) THEN
           ! For now, assume all interactions are the same.
           ! Use the lookup table created in Compute_Nonbond_Table
           eps = vdw_param1_table(itype,jtype)
           sig = vdw_param2_table(itype,jtype)

           SigByR2 = (sig**2.0_DP) / rijsq
           SigByR6  = SigByR2 * SigByR2 * SigByR2
           SigByR12 = SigByR6 * SigByR6

           ! Default potential for vdw_cut, vdw_cut_tail, vdw_cut_shift
           Wij_vdw = (24.0_DP * eps) * (2.0_DP*SigByR12 - SigByR6)

           IF (int_vdw_sum_style(ibox) == vdw_cut_switch) THEN
             IF (rijsq > ron_switch_sq(ibox) .AND. &
                 rijsq <= roff_switch_sq(ibox)) THEN
               roffsq_rijsq = roff_switch_sq(ibox) - rijsq
               roffsq_rijsq_sq = roffsq_rijsq * roffsq_rijsq
               factor2 = switch_factor2(ibox) + 2.0_DP * rijsq
               fscale = roffsq_rijsq_sq * factor2 * switch_factor1(ibox)
               Eij_vdw = 4.0_DP * eps * (SigByR12 - SigByR6)
               Eij_vdw = fscale * Eij_vdw
               Wij_vdw = fscale / 3.0_DP * Wij_vdw
               Wij_vdw = Wij_vdw + 8.0_DP * rijsq * rijsq * roffsq_rijsq &
                       * Eij_vdw * switch_factor1(ibox) / 3.0_DP
             ELSE IF (rijsq > roff_switch_sq(ibox)) THEN
               Wij_vdw = 0.0_DP
             END IF
           ELSEIF (int_vdw_sum_style(ibox) == vdw_charmm) THEN
             ! Use the CHARMM LJ potential
             Wij_vdw = (12.0_DP * eps) * (SigByR12 - SigByR6)
           ELSEIF (int_vdw_sum_style(ibox) == vdw_cut_shift_force) THEN
             ! shifted-force lj potential
             ! u_sf(r) = u_lj(r) - u_lj(rc) - (r-rc)*du_lj/dr(rc)
             SigByR2_shift = sig**2/rcut_vdwsq(ibox)
             SigByR6_shift = SigByR2_shift * SigByR2_shift * SigByR2_shift
             SigByR12_shift = SigByR6_shift * SigByR6_shift
             rij = SQRT(rijsq)
             rcut_vdw = SQRT(rcut_vdwsq(ibox))

             Wij_vdw = Wij_vdw &
                       - rij * (24.0_DP * eps) &
                       * (2.0_DP * SigByR12_shift / rcut_vdw &
                       - SigByR6_shift / rcut_vdw)
           END IF
         ELSE IF (int_vdw_style(ibox) == vdw_mie) THEN
           eps = vdw_param1_table(itype,jtype)
           sig = vdw_param2_table(itype,jtype)
           mie_n = vdw_param3_table(itype,jtype) ! repulsive exponent
           mie_m = vdw_param4_table(itype,jtype) ! dispersive exponent
           rij = SQRT(rijsq)

           mie_coeff = mie_n/(mie_n-mie_m)*(mie_n/mie_m)**(mie_m/(mie_n-mie_m))
           SigByR = sig/rij
           SigByRn = SigByR ** mie_n
           SigByRm = SigByR ** mie_m
           Wij_vdw = (mie_coeff * eps) *(mie_n * SigByRn - mie_m * SigByRm)

         ! Add other potential types here
         ENDIF

       ENDIF VDW_calc

       qq_calc: IF (get_qq) THEN

         qi = nonbond_list(ia,is)%charge
         qj = nonbond_list(ja,js)%charge

         rij = SQRT(rijsq)
         prefactor = qi * qj / rij
         IF (int_charge_sum_style(ibox) == charge_ewald) THEN
           ewald_constant = 2.0_DP * alpha_ewald(ibox) / rootPI
           exp_const = DEXP(-alpha_ewald(ibox)*alpha_ewald(ibox)*rijsq)
           ! May need to protect against very small rij
           erfc_val = erfc(alpha_ewald(ibox) * rij)
           Wij_qq = ( prefactor * erfc_val &
                  + qi * qj * ewald_constant * exp_const )

         ELSE IF (int_charge_sum_style(ibox) == charge_dsf) THEN

           Wij_qq = erfc(alpha_dsf(ibox)*rij)/(rijsq) + &
                    2.0_DP * alpha_dsf(ibox)/rootPI * &
                    DEXP(-alpha_dsf(ibox)*alpha_dsf(ibox) * rijsq) / rij - &
                    dsf_factor2(ibox)
           Wij_qq = qi*qj*Wij_qq*rij


         ELSE IF (int_charge_sum_style(ibox) == charge_cut) THEN
           Wij_qq = prefactor * charge_factor
         ENDIF

       ENDIF qq_calc

    ENDIF ExistCheck
!------------------------------------------------------------------------------
  CONTAINS

    FUNCTION erfc(x)
      !*************************************************************************
      !
      ! Calculate the complementary error function for  a number
      !
      !*************************************************************************

      REAL(DP) :: erfc
      REAL(DP), PARAMETER :: A1 = 0.254829592_DP, A2 = -0.284496736_DP
      REAL(DP), PARAMETER :: A3 = 1.421413741_DP, A4 = -1.453152027_DP
      REAL(DP), PARAMETER :: A5 = 1.061405429_DP, P = 0.3275911_DP
      REAL(DP) :: T, x, xsq, TP

      T = 1.0_DP / (1.0_DP + P*x)
      xsq = x*x

      TP = T * (A1 + T * (A2 + T * (A3 + T * (A4 + T * A5))))

      erfc = TP * EXP(-xsq)

    END FUNCTION erfc
!------------------------------------------------------------------------------

  END SUBROUTINE Compute_AtomPair_Force

  !-----------------------------------------------------------------------------
  SUBROUTINE Compute_LR_Force(this_box, w_lrc)
    !***************************************************************************
    ! The subroutine calculates the long range correction for the given box.
    !
    ! Called by
    !
    ! First written by Jindal Shah on 01/10/08
    !
    !
    !***************************************************************************

    INTEGER, INTENT(IN) :: this_box
    REAL(DP), INTENT(OUT) :: w_lrc

    INTEGER ::   is, js, ia, ja
    REAL(DP) :: mie_n, mie_m, mie_coeff
    REAL(DP) :: SigOverR, SigOverRn, SigOverRm

    REAL(DP) :: epsij, sigij
    REAL(DP) :: w_lrc_ia_ja

    w_lrc = 0.0_DP

    IF (int_vdw_style(this_box) == vdw_lj) THEN
      DO ia = 1, nbr_atomtypes

         w_lrc_ia_ja = 0.0_DP

         DO ja = 1, nbr_atomtypes

            epsij = vdw_param1_table(ia,ja)
            sigij = vdw_param2_table(ia,ja)

            w_lrc_ia_ja = w_lrc_ia_ja + nint_beads(ja,this_box) * epsij * ((2.0_DP / 3.0_DP * &
                          sigij**12 / rcut9(this_box)) - (sigij**6 / rcut3(this_box)))

         END DO

         w_lrc = w_lrc + nint_beads(ia,this_box) * w_lrc_ia_ja

      END DO

      w_lrc = 16.0_DP / 3.0_DP * PI * w_lrc / box_list(this_box)%volume

    ELSEIF (int_vdw_style(this_box) == vdw_mie) THEN

      DO ia = 1, nbr_atomtypes

         w_lrc_ia_ja = 0.0_DP
         DO ja = 1, nbr_atomtypes
            epsij = vdw_param1_table(ia,ja)
            sigij = vdw_param2_table(ia,ja)
            mie_n = vdw_param3_table(ia,ja) ! repulsive exponent
            mie_m = vdw_param4_table(ia,ja) ! dispersive exponent
            mie_coeff = mie_n/(mie_n-mie_m)*(mie_n/mie_m)**(mie_m/(mie_n-mie_m))
            SigOverR = sigij/rcut_vdw(this_box)
            SigOverRn = SigOverR**mie_n
            SigOverRm = SigOverR**mie_m

            w_lrc_ia_ja = w_lrc_ia_ja + nint_beads(ja,this_box) * mie_coeff * epsij &
               *rcut3(this_box) * (mie_n/(mie_n-3.0_DP) * SigOverRn + mie_m/(3.0_DP-mie_m) * SigOverRm)

         END DO

         w_lrc = w_lrc + nint_beads(ia,this_box) * w_lrc_ia_ja
      END DO

      w_lrc =  2.0_DP / 3.0_DP * PI * w_lrc / box_list(this_box)%volume
    END IF
  END SUBROUTINE Compute_LR_Force

  SUBROUTINE Compute_System_Ewald_Reciprocal_Force(this_box)
    !***************************************************************************
    ! This subroutine computes the long range forces due to electrostatics
    !
    ! Based on APSS code reciprocal_ewald.f90
    !
    ! Added by Tom Rosch on 06/11/09
    ! (See Wheeler, Mol. Phys. 1997 Vol. 92 pg. 55)
    ! Drastically refactored by Ryan Smith in 2024
    !
    !***************************************************************************

    USE Type_Definitions
    USE Global_Variables

    IMPLICIT NONE

!    !$ include 'omp_lib.h'

    INTEGER :: i, is, im, ia, this_locate, this_box

    REAL(DP) :: un, const_val
    REAL(DP) :: piix, piiy, piiz, arg, factor
    REAL(DP) :: recip_11, recip_21, recip_31, recip_22, recip_23, recip_33
    REAL(DP) :: qw1,qw2,qw3,qw5,qw6,qw9
    REAL(DP) :: hxhy,hxhz,hyhz,rxp,ryp,rzp
    REAL(DP) :: hxsq, hysq, hzsq, hx, hy, hz

    INTEGER :: nlive, n_charged_atoms, n_charged_live, n_charged_live_p4
    INTEGER, DIMENSION(MAXVAL(nmols(:,this_box))) :: live_locates
    REAL(DP), PARAMETER :: inv_charge_factor = 1.0_DP/charge_factor
    REAL(DP) :: diag_initializer
    REAL(DP), DIMENSION(IAND(SUM(nmols(:,this_box)*natoms)+3,NOT(3)),3) :: qpii, rp
    REAL(DP), DIMENSION(IAND(SUM(nmols(:,this_box)*natoms)+3,NOT(3))) :: charges
    REAL(DP), DIMENSION(3,3) :: H_inv
    REAL(DP), DIMENSION(MAXVAL(natoms)) :: species_charges
    INTEGER, DIMENSION(MAXVAL(natoms)) :: which_charged_atoms
    REAL(DP), DIMENSION(:,:,:,:), ALLOCATABLE :: sincos
    REAL(DP), DIMENSION(IAND(nvecs(this_box)+3,NOT(3)),3,2) :: qpii_sincos_sum
    REAL(DP) :: qpiix, qpiiy, qpiiz
    REAL(DP) :: qpiix_sin_sum, qpiix_cos_sum, qpiiy_sin_sum, qpiiy_cos_sum, qpiiz_sin_sum, qpiiz_cos_sum
    INTEGER :: kxyz_max(3), kxyz_maxmax, kxyz, kx, ky, kz, this_kxyz_max, hxp, hyp, hzp
    REAL(DP) :: charge, xcom, ycom, zcom
    REAL(DP) :: ihp, sin1, cos1, nsin1, ncos1, nsin2, ncos2, sin2, cos2, sin12, cos12, sin3, cos3
    REAL(DP) :: sin_sum_i, cos_sum_i
    INTEGER :: istart, iend, i_dim, ni
    LOGICAL :: l_ortho
    INTEGER :: chunkstart,chunkend,chunksize,ithread,nthreads
    REAL(DP), DIMENSION(6) :: qw_vec

    l_ortho = box_list(this_box)%int_box_shape <= int_ortho
    diag_initializer = energy(this_box)%reciprocal * inv_charge_factor
    !qw1 = diag_initializer
    !qw2 = 0.0_DP
    !qw3 = 0.0_DP
    !qw5 = diag_initializer
    !qw6 = 0.0_DP
    !qw9 = diag_initializer
    !recip_11 = 0.0_DP
    !recip_21 = 0.0_DP
    !recip_31 = 0.0_DP
    !recip_22 = 0.0_DP
    !recip_23 = 0.0_DP
    !recip_33 = 0.0_DP
    qw_vec = 0.0_DP

    H_inv = twoPI*box_list(this_box)%length_inv
    kxyz_maxmax = box_list(this_box)%kxyz_maxmax
    kxyz_max = box_list(this_box)%kxyz_max

    !$OMP PARALLEL DEFAULT(SHARED) &
    !$OMP PRIVATE(i,cos_sum_i,sin_sum_i,hxsq,hysq,hzsq) &
    !$OMP PRIVATE(hxhy,hxhz,hyhz,factor) &
    !$OMP PRIVATE(is,im,ia,this_locate,istart,iend,ni,i_dim) &
    !$OMP PRIVATE(xcom,ycom,zcom,rxp,ryp,rzp,charge) &
    !$OMP PRIVATE(ihp, sin1, cos1, nsin1, ncos1, nsin2, ncos2, sin2, cos2, sin12, cos12, sin3, cos3) &
    !$OMP PRIVATE(qpiix_sin_sum, qpiix_cos_sum, qpiiy_sin_sum, qpiiy_cos_sum, qpiiz_sin_sum, qpiiz_cos_sum) &
    !$OMP PRIVATE(piix,piiy,piiz,qpiix,qpiiy,qpiiz) &
    !$OMP PRIVATE(hx,hy,hz,hxp,hyp,hzp,this_kxyz_max) &
    !$OMP PRIVATE(chunkstart,chunkend,chunksize,ithread,nthreads) &
    !$OMP PRIVATE(qw1,qw2,qw3,qw5,qw6,recip_11,recip_21,recip_31,recip_22,recip_23,recip_33) &
    !$OMP REDUCTION(+:qw_vec)

    !$ nthreads = OMP_GET_NUM_THREADS()
    !$ ithread = OMP_GET_THREAD_NUM()

    istart = 1
    DO is = 1, nspecies
       IF (nmols(is,this_box)==0 .OR. .NOT. has_charge(is)) CYCLE
       !$OMP SINGLE
       nlive = 0
       DO im = 1, nmols(is,this_box)
                this_locate = locate(im,is,this_box)
                IF (.NOT. molecule_list(this_locate,is)%live) CYCLE
                nlive = nlive + 1
                live_locates(nlive) = this_locate
       END DO
       n_charged_atoms = 0
       DO ia = 1, natoms(is)
                charge = nonbond_list(ia,is)%charge
                IF (charge == 0.0_DP) CYCLE
                n_charged_atoms = n_charged_atoms + 1
                which_charged_atoms(n_charged_atoms) = ia
                species_charges(n_charged_atoms) = charge
       END DO
       n_charged_live = nlive*n_charged_atoms
       !$OMP END SINGLE
       IF (n_charged_live == 0) CYCLE
       iend = istart + n_charged_live - 1
       !$OMP WORKSHARE
       charges(istart:iend) = RESHAPE(SPREAD(species_charges(1:n_charged_atoms),1,nlive), (/ n_charged_live /))
       qpii(istart:iend,1) = RESHAPE(SPREAD(molecule_list(live_locates(1:nlive),is)%xcom,2,n_charged_atoms), &
               (/ n_charged_live /))
       qpii(istart:iend,2) = RESHAPE(SPREAD(molecule_list(live_locates(1:nlive),is)%ycom,2,n_charged_atoms), &
               (/ n_charged_live /))
       qpii(istart:iend,3) = RESHAPE(SPREAD(molecule_list(live_locates(1:nlive),is)%zcom,2,n_charged_atoms), &
               (/ n_charged_live /))
       rp(istart:iend,1) = RESHAPE(TRANSPOSE(atom_list(which_charged_atoms(1:n_charged_atoms),live_locates(1:nlive),is)%rxp), &
               (/ n_charged_live /))
       rp(istart:iend,2) = RESHAPE(TRANSPOSE(atom_list(which_charged_atoms(1:n_charged_atoms),live_locates(1:nlive),is)%ryp), &
               (/ n_charged_live /))
       rp(istart:iend,3) = RESHAPE(TRANSPOSE(atom_list(which_charged_atoms(1:n_charged_atoms),live_locates(1:nlive),is)%rzp), &
               (/ n_charged_live /))
       !$OMP END WORKSHARE
       istart = istart + n_charged_live
    END DO
    !$OMP SINGLE
    n_charged_live = iend
    n_charged_live_p4 = IAND(n_charged_live+3,NOT(3))
    ALLOCATE(sincos(n_charged_live_p4,2,-kxyz_maxmax:kxyz_maxmax,3))
    !$OMP END SINGLE
    chunkstart = 1
    chunkend = n_charged_live
    !$ chunksize = IAND((n_charged_live+nthreads-1)/nthreads+3,NOT(3))
    !$ chunkstart = ithread*chunksize+1
    !$ chunkend = MIN((ithread+1)*chunksize,n_charged_live)
    IF (l_ortho) THEN
            !DIR$ VECTOR ALIGNED
            !$OMP SIMD PRIVATE(xcom,ycom,zcom,rxp,ryp,rzp,charge)
            DO i = chunkstart, chunkend
                xcom = qpii(i,1)
                rxp = rp(i,1)
                ycom = qpii(i,2)
                ryp = rp(i,2)
                zcom = qpii(i,3)
                rzp = rp(i,3)
                charge = charges(i)
                xcom = rxp-xcom
                ycom = ryp-ycom
                zcom = rzp-zcom
                rxp = H_inv(1,1)*rxp
                ryp = H_inv(2,2)*ryp
                rzp = H_inv(3,3)*rzp
                xcom = xcom*charge
                ycom = ycom*charge
                zcom = zcom*charge
                rp(i,1) = rxp
                rp(i,2) = ryp
                rp(i,3) = rzp
                qpii(i,1) = xcom
                qpii(i,2) = ycom
                qpii(i,3) = zcom
            END DO
            !$OMP END SIMD
    ELSE
            !DIR$ VECTOR ALIGNED
            !$OMP SIMD PRIVATE(xcom,ycom,zcom,rxp,ryp,rzp,charge)
            DO i = chunkstart, chunkend
                xcom = qpii(i,1)
                rxp = rp(i,1)
                ycom = qpii(i,2)
                ryp = rp(i,2)
                zcom = qpii(i,3)
                rzp = rp(i,3)
                charge = charges(i)
                rxp = rxp-xcom
                ryp = ryp-ycom
                rzp = rzp-zcom
                rxp = rxp*charge
                ryp = ryp*charge
                rzp = rzp*charge
                qpii(i,1) = rxp
                qpii(i,2) = ryp
                qpii(i,3) = rzp
            END DO
            !$OMP END SIMD
            !DIR$ VECTOR ALIGNED
            !$OMP SIMD PRIVATE(hxp,hyp,hzp,rxp,ryp,rzp)
            DO i = chunkstart, chunkend
                rxp = rp(i,1)
                ryp = rp(i,2)
                rzp = rp(i,3)
                hxp = H_inv(1,1)*rxp + H_inv(2,1)*ryp + H_inv(3,1)*rzp
                hyp = H_inv(1,2)*rxp + H_inv(2,2)*ryp + H_inv(3,2)*rzp
                hzp = H_inv(1,3)*rxp + H_inv(2,3)*ryp + H_inv(3,3)*rzp
                rp(i,1) = hxp
                rp(i,2) = hyp
                rp(i,3) = hzp
            END DO
            !$OMP END SIMD
    END IF
    DO i_dim = 1, 3
        this_kxyz_max = kxyz_max(i_dim)
        !DIR$ VECTOR ALIGNED
        !$OMP SIMD PRIVATE(ihp,sin1,cos1)
        DO i = chunkstart, chunkend
                 ihp = rp(i,i_dim)
                 sincos(i,1,0,i_dim) = 0.0_DP
                 sincos(i,2,0,i_dim) = 1.0_DP
                 sin1 = SIN(ihp)
                 cos1 = COS(ihp)
                 sincos(i,1, 1,i_dim) = sin1
                 sincos(i,2, 1,i_dim) = cos1
        END DO
        !$OMP END SIMD
        IF (i_dim == 3) THEN
                !DIR$ VECTOR ALIGNED
                !$OMP SIMD PRIVATE(sin1,cos1,nsin1,ncos1,nsin2,ncos2)
                DO i = chunkstart, chunkend
                        sin1 = sincos(i,1,1,3)
                        cos1 = sincos(i,2,1,3)
                        nsin1 = sin1
                        ncos1 = cos1
                        ! Ptolemy's identities
                        DO ni = 2, this_kxyz_max
                                nsin2 = nsin1*cos1 + ncos1*sin1
                                ncos2 = ncos1*cos1 - nsin1*sin1
                                sincos(i,1, ni,3) = nsin2
                                sincos(i,2, ni,3) = ncos2
                                nsin1 = nsin2
                                ncos1 = ncos2
                        END DO
                END DO
                !$OMP END SIMD
        ELSE
                !DIR$ VECTOR ALIGNED
                !$OMP SIMD PRIVATE(sin1,cos1,nsin1,ncos1,nsin2,ncos2)
                DO i = chunkstart, chunkend
                        sin1 = sincos(i,1,1,i_dim)
                        cos1 = sincos(i,2,1,i_dim)
                        sincos(i,1,-1,i_dim) = -sin1
                        sincos(i,2,-1,i_dim) = cos1
                        nsin1 = sin1
                        ncos1 = cos1
                        ! Ptolemy's identities
                        DO ni = 2, this_kxyz_max
                                nsin2 = nsin1*cos1 + ncos1*sin1
                                ncos2 = ncos1*cos1 - nsin1*sin1
                                sincos(i,1, ni,i_dim) = nsin2
                                sincos(i,1,-ni,i_dim) = -nsin2
                                sincos(i,2, ni,i_dim) = ncos2
                                sincos(i,2,-ni,i_dim) = ncos2
                                nsin1 = nsin2
                                ncos1 = ncos2
                        END DO
                END DO
                !$OMP END SIMD
        END IF
    END DO
    IF (n_charged_live_p4 .NE. n_charged_live) THEN
            !$OMP SINGLE
            sincos(n_charged_live+1:n_charged_live_p4,:,:,:) = 0.0_DP
            qpii(n_charged_live+1:n_charged_live_p4,:) = 0.0_DP
            !$OMP END SINGLE NOWAIT
    END IF
    !$OMP BARRIER
    !$OMP DO SCHEDULE(STATIC)
    DO i = 1, nvecs(this_box)
        kxyz = box_list(this_box)%kspace_vector_ints(i)
        CALL Extract_Kvector_Ints(kxyz,kx,ky,kz)
        qpiix_cos_sum = 0.0_DP
        qpiix_sin_sum = 0.0_DP
        qpiiy_cos_sum = 0.0_DP
        qpiiy_sin_sum = 0.0_DP
        qpiiz_cos_sum = 0.0_DP
        qpiiz_sin_sum = 0.0_DP
        !DIR$ ASSUME (MOD(n_charged_live_p4,4) .EQ. 0)
        !DIR$ VECTOR ALIGNED
        !$OMP SIMD PRIVATE(sin1,cos1,sin2,cos2,sin3,cos3,sin12,cos12,qpiix,qpiiy,qpiiz) &
        !$OMP REDUCTION(+:qpiix_sin_sum,qpiix_cos_sum,qpiiy_sin_sum,qpiiy_cos_sum,qpiiz_sin_sum,qpiiz_cos_sum)
        DO ia = 1, n_charged_live_p4
                sin1 = sincos(ia,1,kx,1)
                cos1 = sincos(ia,2,kx,1)
                sin2 = sincos(ia,1,ky,2)
                cos2 = sincos(ia,2,ky,2)
                sin3 = sincos(ia,1,kz,3)
                cos3 = sincos(ia,2,kz,3)
                sin12 = sin1*cos2 + cos1*sin2
                cos12 = cos1*cos2 - sin1*sin2
                sin1 = sin12*cos3 + cos12*sin3
                cos1 = cos12*cos3 - sin12*sin3
                qpiix = qpii(ia,1)
                qpiiy = qpii(ia,2)
                qpiiz = qpii(ia,3)
                qpiix_sin_sum = qpiix_sin_sum + qpiix*sin1
                qpiix_cos_sum = qpiix_cos_sum + qpiix*cos1
                qpiiy_sin_sum = qpiiy_sin_sum + qpiiy*sin1
                qpiiy_cos_sum = qpiiy_cos_sum + qpiiy*cos1
                qpiiz_sin_sum = qpiiz_sin_sum + qpiiz*sin1
                qpiiz_cos_sum = qpiiz_cos_sum + qpiiz*cos1
        END DO
        !$OMP END SIMD
        qpii_sincos_sum(i,1,1) = qpiix_sin_sum
        qpii_sincos_sum(i,1,2) = qpiix_cos_sum
        qpii_sincos_sum(i,2,1) = qpiiy_sin_sum
        qpii_sincos_sum(i,2,2) = qpiiy_cos_sum
        qpii_sincos_sum(i,3,1) = qpiiz_sin_sum
        qpii_sincos_sum(i,3,2) = qpiiz_cos_sum
    END DO
    !$OMP END DO
    chunkstart = 1
    chunkend = nvecs(this_box)
    !$ chunksize = IAND((nvecs(this_box)+nthreads-1)/nthreads+3,NOT(3))
    !$ chunkstart = ithread*chunksize+1
    !$ chunkend = MIN((ithread+1)*chunksize,nvecs(this_box))
    !DIR$ VECTOR ALIGNED
    !$OMP SIMD &
    !$OMP PRIVATE(cos_sum_i,sin_sum_i,qpiix_sin_sum,qpiix_cos_sum) &
    !$OMP PRIVATE(qpiiy_sin_sum,qpiiy_cos_sum,qpiiz_sin_sum,qpiiz_cos_sum)
    DO i = chunkstart, chunkend
        sin_sum_i = box_list(this_box)%sincos_sum(i,1)
        cos_sum_i = box_list(this_box)%sincos_sum(i,2)
        qpiix_sin_sum = qpii_sincos_sum(i,1,1)
        qpiix_cos_sum = qpii_sincos_sum(i,1,2)
        qpiiy_sin_sum = qpii_sincos_sum(i,2,1)
        qpiiy_cos_sum = qpii_sincos_sum(i,2,2)
        qpiiz_sin_sum = qpii_sincos_sum(i,3,1)
        qpiiz_cos_sum = qpii_sincos_sum(i,3,2)
        qpiix_cos_sum = qpiix_cos_sum*sin_sum_i
        qpiix_cos_sum = qpiix_cos_sum - qpiix_sin_sum*cos_sum_i
        qpiiy_cos_sum = qpiiy_cos_sum*sin_sum_i
        qpiiy_cos_sum = qpiiy_cos_sum - qpiiy_sin_sum*cos_sum_i
        qpiiz_cos_sum = qpiiz_cos_sum*sin_sum_i
        qpiiz_cos_sum = qpiiz_cos_sum - qpiiz_sin_sum*cos_sum_i
        qpii_sincos_sum(i,1,1) = qpiix_cos_sum
        qpii_sincos_sum(i,2,1) = qpiiy_cos_sum
        qpii_sincos_sum(i,3,1) = qpiiz_cos_sum
    END DO
    !$OMP END SIMD
    recip_11 = 0.0_DP
    recip_21 = 0.0_DP
    recip_31 = 0.0_DP
    recip_22 = 0.0_DP
    recip_23 = 0.0_DP
    recip_33 = 0.0_DP
    !DIR$ VECTOR ALIGNED
    !$OMP SIMD &
    !$OMP PRIVATE(factor,hx,hy,hz,piix,piiy,piiz) &
    !$OMP REDUCTION(+:recip_11,recip_21,recip_31,recip_22,recip_23,recip_33)
    DO i = chunkstart, chunkend
        factor = box_list(this_box)%kspace_vectors(i,4)
        hx = box_list(this_box)%kspace_vectors(i,1)
        hy = box_list(this_box)%kspace_vectors(i,2)
        hz = box_list(this_box)%kspace_vectors(i,3)
        piix = qpii_sincos_sum(i,1,1)
        piiy = qpii_sincos_sum(i,2,1)
        piiz = qpii_sincos_sum(i,3,1)
        hx = hx*factor
        hy = hy*factor
        hz = hz*factor
        recip_11 = recip_11 + hx*piix
        recip_21 = recip_21 + hy*piix
        recip_31 = recip_31 + hz*piix
        recip_21 = recip_21 + hx*piiy
        recip_22 = recip_22 + hy*piiy
        recip_23 = recip_23 + hz*piiy
        recip_31 = recip_31 + hx*piiz
        recip_23 = recip_23 + hy*piiz
        recip_33 = recip_33 + hz*piiz
    END DO
    !$OMP END SIMD
    qw1 = 0.0_DP
    qw2 = 0.0_DP
    qw3 = 0.0_DP
    qw5 = 0.0_DP
    qw6 = 0.0_DP
    qw9 = 0.0_DP
    !DIR$ VECTOR ALIGNED
    !$OMP SIMD &
    !$OMP PRIVATE(cos_sum_i,sin_sum_i,hxsq,hysq,hzsq) &
    !$OMP PRIVATE(hxhy,hxhz,hyhz,factor) &
    !$OMP REDUCTION(+:qw1,qw2,qw3,qw5,qw6,qw9)
    DO i = chunkstart, chunkend
       sin_sum_i = box_list(this_box)%sincos_sum(i,1)
       cos_sum_i = box_list(this_box)%sincos_sum(i,2)
       factor = cos_sum_i*cos_sum_i+sin_sum_i*sin_sum_i
       factor = factor*box_list(this_box)%kspace_vectors(i,5)
       hxsq = box_list(this_box)%kspace_vectors(i,1) ! not squared yet
       hysq = box_list(this_box)%kspace_vectors(i,2) ! not squared yet
       hzsq = box_list(this_box)%kspace_vectors(i,3) ! not squared yet
       hxhy = hxsq*hysq
       hxhz = hxsq*hzsq
       hyhz = hysq*hzsq
       hxsq = hxsq*hxsq
       hysq = hysq*hysq
       hzsq = hzsq*hzsq
       qw1 = qw1 + factor*hxsq
       qw2 = qw2 + factor*hxhy
       qw3 = qw3 + factor*hxhz
       qw5 = qw5 + factor*hysq
       qw6 = qw6 + factor*hyhz
       qw9 = qw9 + factor*hzsq


    END DO
    !$OMP END SIMD
    qw1 = qw1 + 2.0_DP*recip_11
    qw2 = qw2 + recip_21
    qw3 = qw3 + recip_31
    qw5 = qw5 + 2.0_DP*recip_22
    qw6 = qw6 + recip_23
    qw9 = qw9 + 2.0_DP*recip_33
    qw_vec(1) = qw1
    qw_vec(2) = qw2
    qw_vec(3) = qw3
    qw_vec(4) = qw5
    qw_vec(5) = qw6
    qw_vec(6) = qw9
    !$OMP END PARALLEL
    qw1 = qw_vec(1) + diag_initializer
    qw2 = qw_vec(2)
    qw3 = qw_vec(3)
    qw5 = qw_vec(4) + diag_initializer
    qw6 = qw_vec(5)
    qw9 = qw_vec(6) + diag_initializer
    !qw1 = qw1 + 2.0_DP*recip_11
    !qw2 = qw2 + recip_21
    !qw3 = qw3 + recip_31
    !qw5 = qw5 + 2.0_DP*recip_22
    !qw6 = qw6 + recip_23
    !qw9 = qw9 + 2.0_DP*recip_33
    W_tensor_recip(1,1,this_box) = qw1
    W_tensor_recip(2,1,this_box) = qw2
    W_tensor_recip(1,2,this_box) = qw2
    W_tensor_recip(1,3,this_box) = qw3
    W_tensor_recip(3,1,this_box) = qw3
    W_tensor_recip(2,2,this_box) = qw5
    W_tensor_recip(3,2,this_box) = qw6
    W_tensor_recip(2,3,this_box) = qw6
    W_tensor_recip(3,3,this_box) = qw9




  END SUBROUTINE Compute_System_Ewald_Reciprocal_Force

  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_Ring_Fragment_Energy(this_frag,this_im,is,this_box, &
    nrg_ring_frag)
    !***************************************************************************
    !
    ! This subroutine calculates the energy of a ring fragment in its old
    ! conformation
    !
    ! CALLED BY:
    !       fragment_growth.f90
    !
    ! CALLS :
    !       Compute_Molecule_Dihedral_Energy
    !       Compute_Molecule_Nonbond_Intra_Energy
    !
    ! Written by Jindal Shah on 10/03/09
    !
    !***************************************************************************

    INTEGER, INTENT(IN) :: this_frag, this_im, is
    REAL(DP), INTENT(OUT) :: nrg_ring_frag
    INTEGER :: this_box

    ! local variables

    INTEGER :: i, this_atom

!    REAL(DP) :: rcut_vdwsq_box, rcut_coulsq_box, alpha_ewald_box
    REAL(DP) :: e_dihed,  e_improper, nrg_vdw, nrg_qq, nrg_inter_qq

    LOGICAL :: intra_overlap
    LOGICAL :: exist_flag_old(natoms(is))

    nrg_ring_frag = 0.0_DP

    !!! Note for now, keep this_box == 1. For flexible ring
    ! molecule change this

    this_box = molecule_list(this_im,is)%which_box


    ! first store the exist flag of the molecule

    exist_flag_old = atom_list(1:natoms(is),this_im,is)%exist

    atom_list(1:natoms(is),this_im,is)%exist = .FALSE.
    ! Now turn on the exist flag of the ring fragment

    DO i = 1,frag_list(this_frag,is)%natoms

       this_atom = frag_list(this_frag,is)%atoms(i)
       atom_list(this_atom,this_im,is)%exist = .TRUE.

    END DO

    ! Now set the cutoffs for VDW and charge interactions along with
    ! the Ewald parameters. For now switch off the LJ and electrostatic
    ! interactions.

    ! store old cutoffs

!!$    rcut_vdwsq_box = rcut_vdwsq(this_box)
!!$
!!$    rcut_vdwsq(this_box) = frag_list(this_frag,is)%rcut_vdwsq
!!$
!!$    IF (int_charge_sum_style(this_box) == charge_ewald ) THEN
!!$
!!$       rcut_coulsq_box = rcut_coulsq(this_box)
!!$       alpha_ewald_box = alpha_ewald(this_box)
!!$
!!$       rcut_coulsq(this_box) = frag_list(this_frag,is)%rcut_coulsq
!!$       alpha_ewald(this_box) = frag_list(this_frag,is)%alpha_ewald
!!$
!!$    END IF

    ! Now compute the intramolecular energy of the fragment

    CALL Compute_Molecule_Dihedral_Energy(this_im,is,e_dihed)
    CALL Compute_Molecule_Improper_Energy(this_im,is,e_improper)
    CALL Compute_Molecule_Nonbond_Intra_Energy(this_im,is,nrg_vdw,nrg_qq, &
         nrg_inter_qq,intra_overlap)


    nrg_ring_frag = nrg_vdw + nrg_qq + nrg_inter_qq + e_dihed + e_improper

    ! Now reset all the cutoffs back
!!$
!!$    IF (int_charge_sum_style(this_box) == charge_ewald) THEN
!!$
!!$       alpha_ewald(this_box) = alpha_ewald_box
!!$       rcut_coulsq(this_box) = rcut_coulsq_box
!!$
!!$    END IF
!!$
!!$    rcut_vdwsq(this_box) = rcut_vdwsq_box

    ! Turn the original exist flag for the atoms on

    atom_list(1:natoms(is),this_im,is)%exist = exist_flag_old


  END SUBROUTINE Compute_Ring_Fragment_Energy

  !-----------------------------------------------------------------------------

  SUBROUTINE Check_System_Energy(ibox,check_inp)

     USE Global_Variables
     USE IO_Utilities

     INTEGER, INTENT(IN) :: ibox
     LOGICAL, OPTIONAL :: check_inp

     LOGICAL :: overlap, check

     TYPE(Energy_Class) :: e_check
     TYPE(Energy_Class) :: e_diff

     IF (present(check_inp)) THEN
        check = check_inp
     ELSE
        check = .TRUE.
     END IF

     IF (check) THEN
        e_check%total = energy(ibox)%total
        e_check%intra = energy(ibox)%intra
        e_check%inter = energy(ibox)%inter
        e_check%bond = energy(ibox)%bond
        e_check%angle = energy(ibox)%angle
        e_check%dihedral = energy(ibox)%dihedral
        e_check%improper = energy(ibox)%improper
        e_check%intra_vdw = energy(ibox)%intra_vdw
        e_check%intra_q = energy(ibox)%intra_q
        e_check%inter_vdw = energy(ibox)%inter_vdw
        e_check%inter_q = energy(ibox)%inter_q
        e_check%lrc = energy(ibox)%lrc
        e_check%reciprocal = energy(ibox)%reciprocal
        e_check%self = energy(ibox)%self
        e_diff%total = 0.0_DP
        e_diff%intra = 0.0_DP
        e_diff%inter = 0.0_DP
        e_diff%bond = 0.0_DP
        e_diff%angle = 0.0_DP
        e_diff%dihedral = 0.0_DP
        e_diff%improper = 0.0_DP
        e_diff%intra_vdw = 0.0_DP
        e_diff%intra_q = 0.0_DP
        e_diff%inter_vdw = 0.0_DP
        e_diff%inter_q = 0.0_DP
        e_diff%lrc = 0.0_DP
        e_diff%reciprocal = 0.0_DP
        e_diff%self = 0.0_DP
     END IF

     CALL Compute_System_Total_Energy(ibox,.TRUE.,overlap)

     IF (overlap) THEN
        ! overlap was detected between two atoms so abort the program
        err_msg = ''
        err_msg(1) = 'Atomic overlap in the configuration'
        CALL Clean_Abort(err_msg,'Check_System_Energy')
     END IF

     ! Compare recomputed energies to original
     IF (check) THEN
        e_diff%total = ABS(energy(ibox)%total - e_check%total)
        IF (ABS(energy(ibox)%total) > tiny_number) THEN
           e_diff%total = e_diff%total / energy(ibox)%total
        END IF
        e_diff%intra = ABS(energy(ibox)%intra - e_check%intra)
        IF (ABS(energy(ibox)%intra) > tiny_number) THEN
           e_diff%intra = e_diff%intra / energy(ibox)%intra
        END IF
        e_diff%inter = ABS(energy(ibox)%inter - e_check%inter)
        IF (ABS(energy(ibox)%inter) > tiny_number) THEN
           e_diff%inter = e_diff%inter / energy(ibox)%inter
        END IF
        e_diff%bond = ABS(energy(ibox)%bond - e_check%bond)
        IF (ABS(energy(ibox)%bond) > tiny_number) THEN
           e_diff%bond = e_diff%bond / energy(ibox)%bond
        END IF
        e_diff%angle = ABS(energy(ibox)%angle - e_check%angle)
        IF (ABS(energy(ibox)%angle) > tiny_number) THEN
           e_diff%angle = e_diff%angle / energy(ibox)%angle
        END IF
        e_diff%dihedral = ABS(energy(ibox)%dihedral - e_check%dihedral)
        IF (ABS(energy(ibox)%dihedral) > tiny_number) THEN
           e_diff%dihedral = e_diff%dihedral / energy(ibox)%dihedral
        END IF
        e_diff%improper = ABS(energy(ibox)%improper - e_check%improper)
        IF (ABS(energy(ibox)%improper) > tiny_number) THEN
           e_diff%improper = e_diff%improper / energy(ibox)%improper
        END IF
        e_diff%intra_vdw = ABS(energy(ibox)%intra_vdw - e_check%intra_vdw)
        IF (ABS(energy(ibox)%intra_vdw) > tiny_number) THEN
           e_diff%intra_vdw = e_diff%intra_vdw / energy(ibox)%intra_vdw
        END IF
        e_diff%intra_q = ABS(energy(ibox)%intra_q - e_check%intra_q)
        IF (ABS(energy(ibox)%intra_q) > tiny_number) THEN
           e_diff%intra_q = e_diff%intra_q / energy(ibox)%intra_q
        END IF
        e_diff%inter_vdw = ABS(energy(ibox)%inter_vdw - e_check%inter_vdw)
        IF (ABS(energy(ibox)%inter_vdw) > tiny_number) THEN
           e_diff%inter_vdw = e_diff%inter_vdw / energy(ibox)%inter_vdw
        END IF
        e_diff%inter_q = ABS(energy(ibox)%inter_q - e_check%inter_q)
        IF (ABS(energy(ibox)%inter_q) > tiny_number) THEN
           e_diff%inter_q = e_diff%inter_q / energy(ibox)%inter_q
        END IF
        e_diff%lrc = ABS(energy(ibox)%lrc - e_check%lrc)
        IF (ABS(energy(ibox)%lrc) > tiny_number) THEN
           e_diff%lrc = e_diff%lrc / energy(ibox)%lrc
        END IF
        e_diff%reciprocal = ABS(energy(ibox)%reciprocal - e_check%reciprocal)
        IF (ABS(energy(ibox)%reciprocal) > tiny_number) THEN
           e_diff%reciprocal = e_diff%reciprocal / energy(ibox)%reciprocal
        END IF
        e_diff%self = ABS(energy(ibox)%self - e_check%self)
        IF (ABS(energy(ibox)%self) > tiny_number) THEN
           e_diff%self = e_diff%self / energy(ibox)%self
        END IF
     END IF

     ! Write the recomputed energy components to log
     WRITE(logunit,*)
     WRITE(logunit,'(X,A,X,I1,T30,A20)',ADVANCE='NO') 'Energy components for box', ibox, 'kJ/mol-Extensive'
     IF (check) WRITE(logunit,'(X,A20)',ADVANCE='NO') 'Relative_Error'
     WRITE(logunit,*)
     WRITE(logunit,'(X,A)') '---------------------------------------------------------------------'
     WRITE(logunit,'(X,A,T30,F20.3)',ADVANCE='NO') 'Total system energy', energy(ibox)%total*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%total
     WRITE(logunit,*)
     WRITE(logunit,'(X,A,T30,F20.3)',ADVANCE='NO') 'Intra molecular energy', energy(ibox)%intra*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%intra
     WRITE(logunit,*)
     WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Bond energy',energy(ibox)%bond*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%bond
     WRITE(logunit,*)
     WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Bond angle energy',energy(ibox)%angle*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%angle
     WRITE(logunit,*)
     WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Dihedral angle energy', energy(ibox)%dihedral*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%dihedral
     WRITE(logunit,*)
     WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Improper angle energy', energy(ibox)%improper*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%improper
     WRITE(logunit,*)
     WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Intra molecule vdw', energy(ibox)%intra_vdw*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%intra_vdw
     WRITE(logunit,*)
     WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Intra molecule q',energy(ibox)%intra_q*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%intra_q
     WRITE(logunit,*)
     WRITE(logunit,'(X,A,T30,F20.3)',ADVANCE='NO') 'Inter molecular energy', energy(ibox)%inter*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%inter
     WRITE(logunit,*)
     WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Inter molecule vdw', energy(ibox)%inter_vdw*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%inter_vdw
     WRITE(logunit,*)
     IF (int_vdw_sum_style(ibox) == vdw_cut_tail) THEN
        WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Long range correction', energy(ibox)%lrc*atomic_to_kjmol
        IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%lrc
        WRITE(logunit,*)
     END IF
     WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Inter molecule q',energy(ibox)%inter_q*atomic_to_kjmol
     IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%inter_q
     WRITE(logunit,*)
     IF (int_charge_sum_style(ibox) == charge_ewald) THEN
        WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Reciprocal ewald',energy(ibox)%reciprocal*atomic_to_kjmol
        IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%reciprocal
        WRITE(logunit,*)
        WRITE(logunit,'(3X,A,T30,F20.3)',ADVANCE='NO') 'Self ewald',energy(ibox)%self*atomic_to_kjmol
        IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%self
        WRITE(logunit,*)
     ELSE IF (int_charge_sum_style(ibox) == charge_dsf) THEN
        WRITE(logunit,'(X,A,T30,F20.3)',ADVANCE='NO') 'Self DSF',energy(ibox)%self*atomic_to_kjmol
        IF (check) WRITE(logunit,'(X,E20.3)',ADVANCE='NO') e_diff%self
        WRITE(logunit,*)
     END IF
     WRITE(logunit,'(X,A)') '---------------------------------------------------------------------'
     IF (int_charge_sum_style(ibox) == charge_ewald) &
        WRITE(logunit,'(3X,A,T33,I17)') 'Number of reciprocal vectors',nvecs(ibox)
     WRITE(logunit,*)

     IF (check) THEN
        energy(ibox)%total = e_check%total
        energy(ibox)%intra = e_check%intra
        energy(ibox)%inter = e_check%inter
        energy(ibox)%bond = e_check%bond
        energy(ibox)%angle = e_check%angle
        energy(ibox)%dihedral = e_check%dihedral
        energy(ibox)%improper = e_check%improper
        energy(ibox)%intra_vdw = e_check%intra_vdw
        energy(ibox)%intra_q = e_check%intra_q
        energy(ibox)%inter_vdw = e_check%inter_vdw
        energy(ibox)%inter_q = e_check%inter_q
        energy(ibox)%lrc = e_check%lrc
        energy(ibox)%reciprocal = e_check%reciprocal
        energy(ibox)%self = e_check%self
     END IF

  END SUBROUTINE Check_System_Energy

  !-----------------------------------------------------------------------------

  SUBROUTINE Compute_System_Ewald_Reciprocal_Energy(this_box)
    !***************************************************************************
    ! This subroutine computes the sin and cos sum terms for the calculation of
    ! reciprocal energy of the input box.
    !***************************************************************************

    USE Type_Definitions
    USE Global_Variables

    IMPLICIT NONE

!   !$ include 'omp_lib.h'

    ! Arguments
    INTEGER :: this_box

    ! Returns
    ! GLOBAL VARIABLE :: energy(this_box)%reciprocal

    ! Local Variables
    INTEGER :: i, is, im, ia, this_locate
    REAL(DP) :: un, const_val
    REAL(DP) :: charge, hdotr, E_reciprocal

    INTEGER :: i_dim
    REAL(DP) :: cos_sum_i,sin_sum_i,this_cos_mol,this_sin_mol
    REAL(DP) :: sin1,cos1,sin2,cos2,sin3,cos3,sin12,cos12
    REAL(DP) :: trigsum, factor
    REAL(DP), DIMENSION(3,3) :: H_inv
    INTEGER :: im_locate_shift, im_locate_shift_vec(nspecies)
    INTEGER :: nlive, nlive_p4, n_charged_atoms, n_charged_atoms_p4
    REAL(DP), DIMENSION(IAND(MAXVAL(natoms)+3,NOT(3))) :: charges
    INTEGER, DIMENSION(MAXVAL(natoms)) :: which_charged_atoms
    INTEGER, DIMENSION(MAXVAL(nmols(:,this_box))) :: live_locates
    LOGICAL :: molvectorized, l_ortho
    REAL(DP), DIMENSION(:,:,:), ALLOCATABLE :: rp
    REAL(DP), DIMENSION(:,:,:,:,:), ALLOCATABLE :: sincos
    REAL(DP), DIMENSION(:,:), ALLOCATABLE :: species_cos_mol, species_sin_mol
    INTEGER :: kxyz,kx,ky,kz,kxyz_maxmax,kxyz_max(3)

    !! individual k-space vector stuff
    !INTEGER ::  position
    !INTEGER, ALLOCATABLE :: im_locate(:,:)


    ! Initialize variables
    E_reciprocal = 0.0_DP
    l_ortho = box_list(this_box)%int_box_shape <= int_ortho
    kxyz_maxmax = box_list(this_box)%kxyz_maxmax
    kxyz_max = box_list(this_box)%kxyz_max
    H_inv = twoPI*box_list(this_box)%length_inv
    im_locate_shift_vec(1) = 0
    im_locate_shift = max_molecules(1)
    DO is = 2, nspecies
        im_locate_shift_vec(is) = im_locate_shift
        im_locate_shift = im_locate_shift + max_molecules(is)
    END DO
    !$OMP PARALLEL DEFAULT(SHARED) &
    !$OMP PRIVATE(i,is,im,i_dim,ia,this_locate,kxyz,kx,ky,kz) &
    !$OMP PRIVATE(cos_sum_i,sin_sum_i,this_cos_mol,this_sin_mol) &
    !$OMP PRIVATE(sin1,cos1,sin2,cos2,sin3,cos3,sin12,cos12,charge) &
    !$OMP PRIVATE(trigsum,factor)



    !$OMP WORKSHARE
    box_list(this_box)%sincos_sum = 0.0_DP
    !$OMP END WORKSHARE


    ! Loop over each species, molecule
    DO is = 1, nspecies
       ! skip nonpolar species
       IF (nmols(is,this_box) == 0 .OR. .NOT. has_charge(is)) CYCLE
       !$OMP SINGLE
       nlive = 0
       DO im = 1, nmols(is,this_box)
                this_locate = locate(im,is,this_box)
                IF (.NOT. molecule_list(this_locate,is)%live) CYCLE
                nlive = nlive + 1
                live_locates(nlive) = this_locate
       END DO
       nlive_p4 = IAND(nlive+3,NOT(3))
       n_charged_atoms = 0
       charges = 0.0_DP
       DO ia = 1, natoms(is)
                charge = nonbond_list(ia,is)%charge
                IF (charge == 0.0_DP) CYCLE
                n_charged_atoms = n_charged_atoms + 1
                which_charged_atoms(n_charged_atoms) = ia
                charges(n_charged_atoms) = charge
       END DO
       n_charged_atoms_p4 = IAND(n_charged_atoms+3,NOT(3))
       molvectorized = nlive > n_charged_atoms ! vectorize over molecules instead of atoms
       IF (ALLOCATED(rp)) DEALLOCATE(rp)
       IF (ALLOCATED(sincos)) DEALLOCATE(sincos)
       IF (ALLOCATED(species_cos_mol)) DEALLOCATE(species_cos_mol)
       IF (ALLOCATED(species_sin_mol)) DEALLOCATE(species_sin_mol)
       IF (molvectorized) THEN
               ALLOCATE(rp(nlive_p4,3,n_charged_atoms))
               ALLOCATE(sincos(nlive_p4,n_charged_atoms,2,-kxyz_maxmax:kxyz_maxmax,3))
               ALLOCATE(species_cos_mol(nlive_p4,nvecs(this_box)))
               ALLOCATE(species_sin_mol(nlive_p4,nvecs(this_box)))
       ELSE
               ALLOCATE(rp(n_charged_atoms_p4,3,nlive))
               ALLOCATE(sincos(n_charged_atoms_p4,nlive,2,-kxyz_maxmax:kxyz_maxmax,3))
       END IF
       im_locate_shift = im_locate_shift_vec(is)
       !$OMP END SINGLE
       IF (molvectorized) THEN
                !$OMP WORKSHARE
                sincos = 0.0_DP
                sincos(:,:,2,0,:) = 1.0_DP
                rp = 0.0_DP
                rp(1:nlive,1,1:n_charged_atoms) = TRANSPOSE(&
                        atom_list(which_charged_atoms(1:n_charged_atoms),live_locates(1:nlive),is)%rxp)
                rp(1:nlive,2,1:n_charged_atoms) = TRANSPOSE(&
                        atom_list(which_charged_atoms(1:n_charged_atoms),live_locates(1:nlive),is)%ryp)
                rp(1:nlive,3,1:n_charged_atoms) = TRANSPOSE(&
                        atom_list(which_charged_atoms(1:n_charged_atoms),live_locates(1:nlive),is)%rzp)
                !$OMP END WORKSHARE
                IF (l_ortho) THEN
                       !$OMP DO COLLAPSE(2) SCHEDULE(STATIC)
                       DO ia = 1, n_charged_atoms
                               DO i_dim = 1, 3
                                        CALL Fill_sincos_ortho(nlive_p4,ia,i_dim)
                               END DO
                       END DO
                       !$OMP END DO
                ELSE
                       !$OMP DO COLLAPSE(2) SCHEDULE(STATIC)
                       DO ia = 1, n_charged_atoms
                               DO i_dim = 1, 3
                                        CALL Fill_sincos_nonortho(nlive_p4,ia,i_dim)
                               END DO
                       END DO
                       !$OMP END DO
                END IF
                IF (nlive_p4 > nlive) THEN
                        !$OMP WORKSHARE
                        sincos(nlive+1:nlive_p4,:,:,:,:) = 0.0_DP
                        !$OMP END WORKSHARE
                END IF
                SELECT CASE(n_charged_atoms)
                CASE(1)
                        !$OMP DO SCHEDULE(STATIC)
                        DO i = 1, nvecs(this_box)
                                CALL Molvectorized_Loop(i,1)
                        END DO
                        !$OMP END DO
                CASE(2)
                        !$OMP DO SCHEDULE(STATIC)
                        DO i = 1, nvecs(this_box)
                                CALL Molvectorized_Loop(i,2)
                        END DO
                        !$OMP END DO
                CASE(3)
                        !$OMP DO SCHEDULE(STATIC)
                        DO i = 1, nvecs(this_box)
                                CALL Molvectorized_Loop(i,3)
                        END DO
                        !$OMP END DO
                CASE(4)
                        !$OMP DO SCHEDULE(STATIC)
                        DO i = 1, nvecs(this_box)
                                CALL Molvectorized_Loop(i,4)
                        END DO
                        !$OMP END DO
                CASE(5)
                        !$OMP DO SCHEDULE(STATIC)
                        DO i = 1, nvecs(this_box)
                                CALL Molvectorized_Loop(i,5)
                        END DO
                        !$OMP END DO
                CASE(6)
                        !$OMP DO SCHEDULE(STATIC)
                        DO i = 1, nvecs(this_box)
                                CALL Molvectorized_Loop(i,6)
                        END DO
                        !$OMP END DO
                CASE(7)
                        !$OMP DO SCHEDULE(STATIC)
                        DO i = 1, nvecs(this_box)
                                CALL Molvectorized_Loop(i,7)
                        END DO
                        !$OMP END DO
                CASE(8)
                        !$OMP DO SCHEDULE(STATIC)
                        DO i = 1, nvecs(this_box)
                                CALL Molvectorized_Loop(i,8)
                        END DO
                        !$OMP END DO
                CASE DEFAULT
                        !$OMP DO SCHEDULE(STATIC)
                        DO i = 1, nvecs(this_box)
                                CALL Molvectorized_Loop(i,n_charged_atoms)
                        END DO
                        !$OMP END DO
                END SELECT
                !$OMP WORKSHARE
                cos_mol(1:nvecs(this_box),im_locate_shift+live_locates(1:nlive)) = &
                        TRANSPOSE(species_cos_mol(1:nlive,1:nvecs(this_box)))
                sin_mol(1:nvecs(this_box),im_locate_shift+live_locates(1:nlive)) = &
                        TRANSPOSE(species_sin_mol(1:nlive,1:nvecs(this_box)))
                !$OMP END WORKSHARE
       ELSE ! Vectorized over atoms
                !$OMP WORKSHARE
                sincos = 0.0_DP
                sincos(:,:,2,0,:) = 1.0_DP
                rp = 0.0_DP
                rp(1:n_charged_atoms,1,1:nlive) = &
                        atom_list(which_charged_atoms(1:n_charged_atoms),live_locates(1:nlive),is)%rxp
                rp(1:n_charged_atoms,2,1:nlive) = &
                        atom_list(which_charged_atoms(1:n_charged_atoms),live_locates(1:nlive),is)%ryp
                rp(1:n_charged_atoms,3,1:nlive) = &
                        atom_list(which_charged_atoms(1:n_charged_atoms),live_locates(1:nlive),is)%rzp
                !$OMP END WORKSHARE
                IF (l_ortho) THEN
                        !$OMP DO COLLAPSE(2) SCHEDULE(STATIC)
                        DO im = 1, nlive
                                DO i_dim = 1, 3
                                        CALL Fill_sincos_ortho(n_charged_atoms_p4,im,i_dim)
                                END DO
                        END DO
                        !$OMP END DO
                ELSE
                        !$OMP DO COLLAPSE(2) SCHEDULE(STATIC)
                        DO im = 1, nlive
                                DO i_dim = 1, 3
                                        CALL Fill_sincos_nonortho(n_charged_atoms_p4,im,i_dim)
                                END DO
                        END DO
                        !$OMP END DO
                END IF
                !$OMP DO SCHEDULE(STATIC)
                DO i = 1, nvecs(this_box)
                        kxyz = box_list(this_box)%kspace_vector_ints(i)
                        CALL Extract_Kvector_Ints(kxyz,kx,ky,kz)
                        sin_sum_i = box_list(this_box)%sincos_sum(i,1)
                        cos_sum_i = box_list(this_box)%sincos_sum(i,2)
                        DO im = 1, nlive
                                this_cos_mol = 0.0_DP
                                this_sin_mol = 0.0_DP
                                !DIR$ ASSUME (MOD(n_charged_atoms_p4,4) .EQ. 0)
                                !DIR$ VECTOR ALIGNED
                                !$OMP SIMD &
                                !$OMP PRIVATE(sin1,cos1,sin2,cos2,sin3,cos3,sin12,cos12,charge) &
                                !$OMP REDUCTION(+:this_cos_mol,this_sin_mol)
                                DO ia = 1, n_charged_atoms_p4
                                        sin1 = sincos(ia,im,1,kx,1)
                                        cos1 = sincos(ia,im,2,kx,1)
                                        sin2 = sincos(ia,im,1,ky,2)
                                        cos2 = sincos(ia,im,2,ky,2)
                                        sin3 = sincos(ia,im,1,kz,3)
                                        cos3 = sincos(ia,im,2,kz,3)
                                        sin12 = sin1*cos2 + cos1*sin2
                                        cos12 = cos1*cos2 - sin1*sin2
                                        sin1 = sin12*cos3 + cos12*sin3
                                        cos1 = cos12*cos3 - sin12*sin3
                                        charge = charges(ia)
                                        this_cos_mol = this_cos_mol + charge*cos1
                                        this_sin_mol = this_sin_mol + charge*sin1
                                END DO
                                !$OMP END SIMD
                                this_locate = im_locate_shift + live_locates(im)
                                cos_mol(i,this_locate) = this_cos_mol
                                sin_mol(i,this_locate) = this_sin_mol
                                cos_sum_i = cos_sum_i + this_cos_mol
                                sin_sum_i = sin_sum_i + this_sin_mol
                        END DO
                        box_list(this_box)%sincos_sum(i,1) = sin_sum_i
                        box_list(this_box)%sincos_sum(i,2) = cos_sum_i
                END DO
                !$OMP END DO
       END IF
    END DO

    ! At the end of all the loops we have computed cos_sum, sin_sum, cos_mol and
    ! sin_mol for each of the k-vectors. Now let us calculate the reciprocal
    ! space energy

    !DIR$ VECTOR ALIGNED
    !$OMP DO SIMD SCHEDULE(SIMD:STATIC) &
    !$OMP PRIVATE(sin_sum_i,cos_sum_i,factor,trigsum) &
    !$OMP REDUCTION(+:E_reciprocal)
    DO i = 1, nvecs(this_box)
            sin_sum_i = box_list(this_box)%sincos_sum(i,1)
            cos_sum_i = box_list(this_box)%sincos_sum(i,2)
            factor = box_list(this_box)%kspace_vectors(i,4)
            trigsum = sin_sum_i*sin_sum_i + cos_sum_i*cos_sum_i
            E_reciprocal = E_reciprocal + factor*trigsum
    END DO
    !$OMP END DO SIMD
    !$OMP END PARALLEL

    energy(this_box)%reciprocal = E_reciprocal * charge_factor

    CONTAINS
            SUBROUTINE Molvectorized_Loop(i,nca)
                    !DIR$ ATTRIBUTES FORCEINLINE :: Molvectorized_Loop
                    INTEGER, INTENT(IN) :: i, nca
                    INTEGER :: im,ia
                    REAL(DP) :: sin1,cos1,sin2,cos2,sin3,cos3,sin12,cos12,charge
                    REAL(DP) :: cos_sum_i, sin_sum_i, this_cos_mol, this_sin_mol
                    kxyz = box_list(this_box)%kspace_vector_ints(i)
                    CALL Extract_Kvector_Ints(kxyz,kx,ky,kz)
                    sin_sum_i = box_list(this_box)%sincos_sum(i,1)
                    cos_sum_i = box_list(this_box)%sincos_sum(i,2)
                    !DIR$ VECTOR ALIGNED
                    !$OMP SIMD PRIVATE(this_cos_mol,this_sin_mol) &
                    !$OMP PRIVATE(sin1,cos1,sin2,cos2,sin3,cos3,sin12,cos12,charge) &
                    !$OMP REDUCTION(+:cos_sum_i,sin_sum_i)
                    DO im = 1, nlive_p4
                            this_cos_mol = 0.0_DP
                            this_sin_mol = 0.0_DP
                            DO ia = 1, nca
                                    sin1 = sincos(im,ia,1,kx,1)
                                    cos1 = sincos(im,ia,2,kx,1)
                                    sin2 = sincos(im,ia,1,ky,2)
                                    cos2 = sincos(im,ia,2,ky,2)
                                    sin3 = sincos(im,ia,1,kz,3)
                                    cos3 = sincos(im,ia,2,kz,3)
                                    sin12 = sin1*cos2 + cos1*sin2
                                    cos12 = cos1*cos2 - sin1*sin2
                                    sin1 = sin12*cos3 + cos12*sin3
                                    cos1 = cos12*cos3 - sin12*sin3
                                    charge = charges(ia)
                                    this_cos_mol = this_cos_mol + charge*cos1
                                    this_sin_mol = this_sin_mol + charge*sin1
                            END DO
                            species_cos_mol(im,i) = this_cos_mol
                            species_sin_mol(im,i) = this_sin_mol
                            cos_sum_i = cos_sum_i + this_cos_mol
                            sin_sum_i = sin_sum_i + this_sin_mol
                    END DO
                    !$OMP END SIMD
                    box_list(this_box)%sincos_sum(i,1) = sin_sum_i
                    box_list(this_box)%sincos_sum(i,2) = cos_sum_i
            END SUBROUTINE Molvectorized_Loop
            SUBROUTINE Fill_sincos_ortho(imax,j,i_dim)
                    !DIR$ ATTRIBUTES FORCEINLINE :: Fill_sincos_ortho
                    INTEGER, INTENT(IN) :: imax, j, i_dim
                    INTEGER :: ni, i
                    REAL(DP) :: ki,sin1,cos1,nsin1,nsin2,ncos1,ncos2
                    !DIR$ ASSUME (MOD(imax,4) .EQ. 0)
                    !DIR$ VECTOR ALIGNED
                    !$OMP SIMD PRIVATE(ki,sin1,cos1,nsin1,nsin2,ncos1,ncos2)
                    DO i = 1, imax
                             ki = H_inv(i_dim,i_dim)*rp(i,i_dim,j)
                             sin1 = SIN(ki)
                             cos1 = COS(ki)
                             sincos(i,j,1, 1,i_dim) = sin1
                             sincos(i,j,1,-1,i_dim) = -sin1
                             sincos(i,j,2, 1,i_dim) = cos1
                             sincos(i,j,2,-1,i_dim) = cos1
                             nsin1 = sin1
                             ncos1 = cos1
                             ! Ptolemy's identities
                             DO ni = 2, kxyz_max(i_dim)
                                     nsin2 = nsin1*cos1 + ncos1*sin1
                                     ncos2 = ncos1*cos1 - nsin1*sin1
                                     nsin1 = nsin2
                                     ncos1 = ncos2
                                     sincos(i,j,1, ni,i_dim) = nsin2
                                     sincos(i,j,1,-ni,i_dim) = -nsin2
                                     sincos(i,j,2, ni,i_dim) = ncos2
                                     sincos(i,j,2,-ni,i_dim) = ncos2
                             END DO
                    END DO
                    !$OMP END SIMD
            END SUBROUTINE Fill_sincos_ortho
            SUBROUTINE Fill_sincos_nonortho(imax,j,i_dim)
                    !DIR$ ATTRIBUTES FORCEINLINE :: Fill_sincos_nonortho
                    INTEGER, INTENT(IN) :: imax, j, i_dim
                    INTEGER :: ni, i
                    REAL(DP) :: ki,sin1,cos1,nsin1,nsin2,ncos1,ncos2
                    REAL(DP) :: rxp,ryp,rzp
                    !DIR$ ASSUME (MOD(imax,4) .EQ. 0)
                    !DIR$ VECTOR ALIGNED
                    !$OMP SIMD PRIVATE(rxp,ryp,rzp,ki,sin1,cos1,nsin1,nsin2,ncos1,ncos2)
                    DO i = 1, imax
                             rxp = rp(i,1,j)
                             ryp = rp(i,2,j)
                             rzp = rp(i,3,j)
                             ki = H_inv(1,i_dim)*rxp + H_inv(2,i_dim)*ryp + H_inv(3,i_dim)*rzp
                             sin1 = SIN(ki)
                             cos1 = COS(ki)
                             sincos(i,j,1, 1,i_dim) = sin1
                             sincos(i,j,1,-1,i_dim) = -sin1
                             sincos(i,j,2, 1,i_dim) = cos1
                             sincos(i,j,2,-1,i_dim) = cos1
                             nsin1 = sin1
                             ncos1 = cos1
                             ! Ptolemy's identities
                             DO ni = 2, kxyz_max(i_dim)
                                     nsin2 = nsin1*cos1 + ncos1*sin1
                                     ncos2 = ncos1*cos1 - nsin1*sin1
                                     nsin1 = nsin2
                                     ncos1 = ncos2
                                     sincos(i,j,1, ni,i_dim) = nsin2
                                     sincos(i,j,1,-ni,i_dim) = -nsin2
                                     sincos(i,j,2, ni,i_dim) = ncos2
                                     sincos(i,j,2,-ni,i_dim) = ncos2
                             END DO
                    END DO
                    !$OMP END SIMD
            END SUBROUTINE Fill_sincos_nonortho

  END SUBROUTINE Compute_System_Ewald_Reciprocal_Energy

  !-----------------------------------------------------------------------------

END MODULE Energy_Routines
