c -*- Fortran -*-
c
c ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c
c  PyLith by Charles A. Williams, Brad Aagaard, and Matt Knepley
c
c  Copyright (c) 2004-2006 Rensselaer Polytechnic Institute
c
c  Permission is hereby granted, free of charge, to any person obtaining
c  a copy of this software and associated documentation files (the
c  "Software"), to deal in the Software without restriction, including
c  without limitation the rights to use, copy, modify, merge, publish,
c  distribute, sublicense, and/or sell copies of the Software, and to
c  permit persons to whom the Software is furnished to do so, subject to
c  the following conditions:
c
c  The above copyright notice and this permission notice shall be
c  included in all copies or substantial portions of the Software.
c
c  THE  SOFTWARE IS  PROVIDED  "AS  IS", WITHOUT  WARRANTY  OF ANY  KIND,
c  EXPRESS OR  IMPLIED, INCLUDING  BUT NOT LIMITED  TO THE  WARRANTIES OF
c  MERCHANTABILITY,    FITNESS    FOR    A   PARTICULAR    PURPOSE    AND
c  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
c  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
c  OF CONTRACT, TORT OR OTHERWISE,  ARISING FROM, OUT OF OR IN CONNECTION
c  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
c
c ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
c
c...  Program segment to define material model 6:
c
c       Model number:                      6
c       Model name:                        IsotropicPowerLawMaxwellViscoelastic
c       Number material properties:        5
c       Number state variables:            3
c       Tangent matrix varies with state:  True
c       Material properties:               Density
c                                          Young's modulus
c                                          Poisson's ratio
c                                          Power-law exponent
c                                          Viscosity coefficient
c
      subroutine mat_prt_6(prop,nprop,matnum,idout,idsk,kw,kp,
     & ierr,errstrng)
c
c...  subroutine to output material properties for material model 6.
c
c     Error codes:
c         4:  Write error
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "nconsts.inc"
c
c...  subroutine arguments
c
      integer nprop,matnum,idout,idsk,kw,kp,ierr
      double precision prop(nprop)
      character errstrng*(*)
c
c...  local constants
c
      character labelp(5)*21,modelname*40
      data labelp/"Density",
     &            "Young's modulus",
     &            "Poisson's ratio",
     &            "Power-law exponent",
     &            "Viscosity coefficient"/
      parameter(modelname="Isotropic Power-Law Maxwell Viscoelastic")
      integer mattype
      parameter(mattype=6)
c
c...  local variables
c
      integer i
c
cdebug      write(6,*) "Hello from mat_prt_6_f!"
c
c...  output plot results
c
      if(idsk.eq.ione) then
	write(kp,"(3i7)",err=10) matnum,mattype,nprop
	write(kp,"(1pe15.8,20(2x,1pe15.8))",err=10) (prop(i),i=1,nprop)
      else if(idsk.eq.itwo) then
	write(kp,err=10) matnum,mattype,nprop
	write(kp,err=10) prop
      end if
c
c...  output ascii results, if desired
c
      if(idout.gt.izero) then
	write(kw,700,err=10) matnum,modelname,nprop
	do i=1,nprop
	  write(kw,710,err=10) labelp(i),prop(i)
        end do
      end if
c
      return
c
c...  error writing to output file
c
 10   continue
        ierr=4
        errstrng="mat_prt_6"
        return
c
 700  format(/,5x,"Material number:       ",i7,/,5x,
     &            "Material type:         ",a40,/,5x,
     &            "Number of properties:  ",i7,/)
 710  format(15x,a21,3x,1pe15.8)
c
      end
c
c
      subroutine elas_mat_6(dmat,prop,iddmat,nprop,ierr,errstrng)
c
c...  subroutine to form the material matrix for an integration point
c     for the elastic solution.  The material matrix is assumed to be
c     independent of the state variables in this case.
c     Note also that only the upper triangle is used (or available), as
c     dmat is assumed to always be symmetric.
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "ndimens.inc"
      include "rconsts.inc"
c
c...  subroutine arguments
c
      integer nprop,ierr
      integer iddmat(nstr,nstr)
      character errstrng*(*)
      double precision dmat(nddmat),prop(nprop)
c
c...  local variables
c
      integer i,j
      double precision e,pr,pr1,pr2,pr3,fac,dd,od,ss
c
cdebug      write(6,*) "Hello from elas_mat_6_f!"
c
      call fill(dmat,zero,nddmat)
      e=prop(2)
      pr=prop(3)
      pr1=one-pr
      pr2=one+pr
      pr3=one-two*pr
      fac=e/(pr2*pr3)
      dd=pr1*fac
      od=pr*fac
      ss=half*pr3*fac
      do i=1,3
        dmat(iddmat(i,i))=dd
        dmat(iddmat(i+3,i+3))=ss
        do j=i+1,3
          dmat(iddmat(i,j))=od
        end do
      end do
      return
      end
c
c
      subroutine elas_strs_6(prop,nprop,state,state0,ee,scur,dmat,tmax,
     & nstate,nstate0,ierr,errstrng)
c
c...  subroutine to compute stresses for the elastic solution. For this
c     material, there are 3 sets of state variables:  total stress,
c     total strain, and viscous strain. The Maxwell time is computed,
c     even though this is the elastic solution, as an aid in determining
c     the proper time step size for the next step.
c     The current total strain is contained in ee and the computed
c     total stress should be copied to scur.
c
c     state(1:6)   = Cauchy stress
c     state(7:12)  = linear strain
c     state(13:18) = viscous strain
c
c     The state0 array contains initial stresses.
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "ndimens.inc"
      include "nconsts.inc"
      include "rconsts.inc"
c
c...  subroutine arguments
c
      integer nprop,nstate,nstate0,ierr
      double precision prop(nprop),state(nstate),state0(nstate0)
      double precision ee(nstr),scur(nstr)
      double precision dmat(nddmat)
      character errstrng*(*)
c
c...  local variables
c
      double precision e,pr,anpwr,emhu,rmu
      double precision sdev(nstr),sinv1,steff
c
cdebug      write(6,*) "Hello from elas_strs_6_f!"
c
      call dcopy(nstr,ee,ione,state(7),ione)
      call dcopy(nstr,state0,ione,state,ione)
      call dspmv("u",nstr,one,dmat,state(7),ione,one,state,ione)
      call dcopy(nstr,state,ione,scur,ione)
c
c...  compute Maxwell time for current stress state
c
      e=prop(2)
      pr=prop(3)
      anpwr=prop(4)
      emhu=prop(5)
      rmu=half*e/(one+pr)
      call invar(sdev,sinv1,steff,scur)
      tmax=big
      if(steff.ne.zero) tmax=(emhu/steff)**(anpwr-one)*emhu/rmu
      return
      end
c
c
      subroutine td_matinit_6(state,dstate,state0,dmat,prop,rtimdat,
     & rgiter,ntimdat,iddmat,tmax,nstate,nstate0,nprop,matchg,ierr,
     & errstrng)
c
c...  subroutine to form the material matrix for an integration point
c     for the time-dependent solution.  This routine is meant to be
c     called at the beginning of a time step, before strains have been
c     computed.  Thus, for some time-dependent materials, the material
c     matrix will only be an approximation of the material matrix for
c     the current iteration.
c     Note that only the upper triangle is used (or available), as
c     dmat is assumed to always be symmetric.
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "ndimens.inc"
      include "rconsts.inc"
c
c...  subroutine arguments
c
      integer nstate,nstate0,nprop,ierr
      integer iddmat(nstr,nstr)
      character errstrng*(*)
      double precision state(nstate),dstate(nstate)
      double precision state0(nstate0),dmat(nddmat),prop(nprop),tmax
      logical matchg
c
c...  included dimension and type statements
c
      include "rtimdat_dim.inc"
      include "rgiter_dim.inc"
      include "ntimdat_dim.inc"
c
c...  local variables
c
      double precision e,pr,anpwr,emhu,f1,f2,gam,ae
      double precision sdev(nstr),sinv1,steff
c
c...  included variable definitions
c
      include "rtimdat_def.inc"
      include "rgiter_def.inc"
      include "ntimdat_def.inc"
c
cdebug      write(6,*) "Hello from td_matinit_6_f!"
c
      call fill(dmat,zero,nddmat)
      tmax=big
      e=prop(2)
      pr=prop(3)
      anpwr=prop(4)
      emhu=prop(5)
      ae=(one+pr)/e
      f1=third*e/(one-two*pr)
      call invar(sdev,sinv1,steff,state)
      gam=half*(steff/emhu)**(anpwr-one)/emhu
      f2=third/(ae+deltp*gam)
      dmat(iddmat(1,1))=f1+two*f2
      dmat(iddmat(2,2))=dmat(iddmat(1,1))
      dmat(iddmat(3,3))=dmat(iddmat(1,1))
      dmat(iddmat(1,2))=f1-f2
      dmat(iddmat(1,3))=dmat(iddmat(1,2))
      dmat(iddmat(2,3))=dmat(iddmat(1,2))
      dmat(iddmat(4,4))=half*three*f2
      dmat(iddmat(5,5))=dmat(iddmat(4,4))
      dmat(iddmat(6,6))=dmat(iddmat(4,4))
      return
      end
c
c
      subroutine td_strs_6(state,dstate,state0,ee,scur,dmat,prop,
     & rtimdat,rgiter,ntimdat,iddmat,tmax,nstate,nstate0,nprop,matchg,
     & ierr,errstrng)
c
c...  subroutine to compute the current values for stress, total strain,
c     and viscous strain increment for the time-dependent solution.
c     Note that only the upper triangle is used (or available), as
c     dmat is assumed to always be symmetric.
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "ndimens.inc"
      include "nconsts.inc"
      include "rconsts.inc"
      integer nrpar,nipar
      parameter(nrpar=10,nipar=0)
c
c...  subroutine arguments
c
      integer nstate,nstate0,nprop,ierr
      integer iddmat(nstr,nstr)
      character errstrng*(*)
      logical matchg
      double precision state(nstate),dstate(nstate),state0(nstate0)
      double precision ee(nstr),scur(nstr),dmat(nddmat),prop(nprop),tmax
c
c...  included dimension and type statements
c
      include "rtimdat_dim.inc"
      include "rgiter_dim.inc"
      include "ntimdat_dim.inc"
c
c...  local constants
c
      double precision diag(6)
      data diag/one,one,one,zero,zero,zero/
      double precision eng(6)
      data eng/one,one,one,half,half,half/
c
c...  local variables
c
      integer i
      integer ipar(nipar)
      double precision rpar(nrpar)
      double precision e,pr,anpwr,emhu,rmu,ae,tf
      double precision emeantdt,smeant,smeantdt
      double precision sinv1t,sefft,sinv10,seff0
      double precision epptdt(6),sdevt(6),sdev0(6),sdevtdt(6)
      double precision sdev,sdevtp,smean0,sdev0
      double precision eett(6)

c
c...  included variable definitions
c
      include "rtimdat_def.inc"
      include "rgiter_def.inc"
      include "ntimdat_def.inc"
c
cdebug      write(6,*) "Hello from td_strs_6!"
c
      ierr=0
c
c...  define material properties
c
      e=prop(2)
      pr=prop(3)
      anpwr=prop(4)
      emhu=prop(5)
      rmu=half*e/(one+pr)
      ae=(one+pr)/e
      tf=deltp*(one-alfap)
c
c...  define stress and strain quantities
c
      emeantdt=third*(ee(1)+ee(2)+ee(3))
      smeantdt=e*emean/(one-two*pr)
      call invar(sdevt,sinv1t,sefft,state)
      smeant=third*sinv1t
      call invar(sdev0,sinv10,seff0,state0)
      smean0=third*sinv10
      do i=1,nstr
        epptdt(i)=eng(i)*ee(i)-diag(i)*emeantdt-state(i+12)
      end do
c
c...  define parameters needed by effective stress function
c
      rpar(1)=ae
      rpar(2)=anpwr
      rpar(3)=emhu
      rpar(4)=sprod(epptdt,epptdt)+two*ae*sprod(epptdt,sdev0)+
     & ae*ae*seff0
      rpar(5)=two*tf*(sprod(epptdt,sdevt)+ae*sprod(sdevt,sdev0))
      rpar(6)=sefft
c
c...  call effective stress driver routine
c
      call esfcomp_6(sefftdt,rpar,nrpar,ipar,nipar,ierr,errstrng)

      
      call dcopy(nstr,ee,ione,eett,ione)
      eett(4)=half*eett(4)
      eett(5)=half*eett(5)
      eett(6)=half*eett(6)

c
      return
      end
c
c
      subroutine esfcomp_6(sefftdt,rpar,nrpar,ipar,nipar,ierr,errstrng)
c
c...  driver routine to compute the effective stress at the current
c     time step.
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "rconsts.inc"
      double precision brac
c...  This value is arbitrary, but has worked OK in the past.
      parameter(brac=5000.0d0)
c
c...  subroutine arguments
c
      integer nrpar,nipar,ierr
      integer ipar(nipar)
      double precision sefftdt,rpar(nrpar)
      character errstrng*(*)
c
c...  included dimension and type statements
c
      include "rtimdat_dim.inc"
      include "rgiter_dim.inc"
      include "ntimdat_dim.inc"
c
c...  external routines
c
      external esf_6
c
c...  local variables
c
      double precision add,sefflo,seffhi
c
c...  included variable definitions
c
      include "rtimdat_def.inc"
      include "rgiter_def.inc"
      include "ntimdat_def.inc"
c
cdebug      write(6,*) "Hello from esfcomp_6!"
c
c********  decide whether to use current stress or elastic stress
c          computed from current strains as initial value.  This
c          would just be scalar product of eppdtd/ae.
      add=brac*stol*



c
c
      subroutine esf_6(seffcur,f,df,rpar,nrpar,ipar,nipar)
c
c...  subroutine to compute the effective stress function and it's
c     derivative for a given effective stress for a Maxwell power-law
c     viscoelastic material.
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "rconsts.inc"
c
c...  subroutine arguments
c
      integer nrpar,nipar
      integer ipar(nipar)
      double precision seffcur,f,df,rpar(nrpar)
c
c...  included dimension and type statements
c
      include "rtimdat_dim.inc"
c
c...  local variables
c
      double precision ae,anpwr,emhu,b,c,sefft
      double precision f1,tf
      double precision gamtau,sefftau
c
c...  included variable definitions
c
      include "rtimdat_def.inc"
c
cdebug      write(6,*) "Hello from esf_6!"
c
c
c...  handy constants
c
      f1=one-alfap
      tf=deltp*f1
c
c...  values from parameter list
c
      ae=rpar(1)
      anpwr=rpar(2)
      emhu=rpar(3)
      b=rpar(4)
      c=rpar(5)
      sefft=rpar(6)
      d=tf*sefft
c
c...  additional values dependent on current effective stress
c
      sefftau=f1*sefft+alfap*seffcur
      gamtau=half*(sefftau/emhu)**(anpwr-one)/emhu
      a=ae+alfap*deltp*gamtau
c
c...  effective stress function and it's derivative
c
      f=a*a*seffcur*seffcur-b+c*gamtau-d*d*gamtau*gamtau
      df=two*a*a*seffcur+(two*a*alfap*deltp*seffcur*seffcur+
     & c-two*d*d*gamtau)*
     & (half*alfap*(anpwr-one)*(sefftau/emhu)**anpwr-two)/(emhu*emhu)
c
      return
      end

c
c
      subroutine td_strs_mat_6(state,dstate,state0,ee,scur,dmat,prop,
     & rtimdat,rgiter,ntimdat,iddmat,tmax,nstate,nstate0,nprop,matchg,
     & ierr,errstrng)
c
c...  subroutine to compute the current stress and updated material
c     matrix for the time-dependent solution.  Since this is a purely
c     elastic material, the material matrix should not change unless the
c     material properties have changed for a time step.
c     Note that only the upper triangle is used (or available), as
c     dmat is assumed to always be symmetric.
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "ndimens.inc"
      include "nconsts.inc"
      include "rconsts.inc"
c
c...  subroutine arguments
c
      integer nstate,nstate0,nprop,ierr
      integer iddmat(nstr,nstr)
      character errstrng*(*)
      logical matchg
      double precision state(nstate),dstate(nstate),state0(nstate0)
      double precision ee(nstr),scur(nstr),dmat(nddmat),prop(nprop),tmax
c
c...  included dimension and type statements
c
      include "rtimdat_dim.inc"
      include "rgiter_dim.inc"
      include "ntimdat_dim.inc"
c
c...  included variable definitions
c
      include "rtimdat_def.inc"
      include "rgiter_def.inc"
      include "ntimdat_def.inc"
c
c...  return error code, as this material is not yet defined
c
      ierr=101
      errstrng="td_strs_mat_6"
c
      return
      end
c
c
      subroutine prestr_mat_6(dmat,prop,tpois,tyoungs,iddmat,ipauto,
     & nprop,ierr,errstrng)
c
c...  subroutine to form the material matrix for an integration point
c     for prestress computation.  The material matrix is assumed to be
c     independent of the state variables in this case.
c     Note also that only the upper triangle is used (or available), as
c     dmat is assumed to always be symmetric.
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "ndimens.inc"
      include "nconsts.inc"
      include "rconsts.inc"
c
c...  subroutine arguments
c
      integer ipauto,nprop,ierr
      integer iddmat(nstr,nstr)
      character errstrng*(*)
      double precision tpois,tyoungs,dmat(nddmat),prop(nprop)
c
c...  local variables
c
      double precision ptmp(10)
c
      call dcopy(nprop,prop,ione,ptmp,ione)
      if(ipauto.eq.ione) then
        ptmp(2)=tyoungs
        ptmp(3)=tpois
      end if
      call elas_mat_6(dmat,ptmp,iddmat,nprop,ierr,errstrng)
      return
      end
c
c
      subroutine get_state_6(state,dstate,sout,nstate)
c
c...  routine to transfer state variables into sout
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "materials.inc"
      include "nconsts.inc"
c
c...  subroutine arguments
c
      integer nstate
      double precision state(nstate),dstate(nstate),sout(3*nstatesmax)
c
      return
      end
c
c
      subroutine update_state_6(state,dstate,nstate)
c
c...  routine to update state variables at the end of a time step.
c     After updating, state should contain the current total values
c     and dstate should contain the incremental changes since the
c     previous time step.
c     On input, dstate contains the current stress and strain values and
c     state contains the values from the previous time step.
c
      include "implicit.inc"
c
c...  parameter definitions
c
      include "nconsts.inc"
      include "rconsts.inc"
c
c...  subroutine arguments
c
      integer nstate
      double precision state(nstate),dstate(nstate)
c
c...  local data
c
c
c...  local variables
c
c
      return
      end
c
c       
c version
c $Id: mat_6.f,v 1.5 2005/04/01 23:10:17 willic3 Exp $

c Generated automatically by Fortran77Mill on Tue May 18 14:18:50 2004

c End of file 
