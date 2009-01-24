// -*- C++ -*-
//
// ======================================================================
//
//                           Brad T. Aagaard
//                        U.S. Geological Survey
//
// {LicenseText}
//
// ======================================================================
//

/**
 * @file modulesrc/meshio/MeshIO.i
 *
 * @brief Python interface to C++ MeshIO object.
 */

namespace pylith {
  namespace topology {
    class Mesh;
  } // topology

  namespace meshio {

    class MeshIO
    { // MeshIO

      // PUBLIC TYPEDEFS ////////////////////////////////////////////////
    public :
      
      /// Type of points in a group.
      enum GroupPtType {
	VERTEX=0,
	CELL=1,
      }; // GroupPtType
      
      // PUBLIC MEMBERS /////////////////////////////////////////////////
    public :
      
      /// Constructor
      MeshIO(void);
      
      /// Destructor
      virtual
      ~MeshIO(void);
      
      /** Set debug flag for mesh.
       *
       * @param flag True to print debugging information.
       */
      void debug(const bool flag);
      
      /** Get debug flag for mesh.
       *
       * @returns True if debugging is on.
       */
      bool debug(void) const;
      
      /** Set flag associated with building intermediate mesh topology
       *  elements.
       *
       * @param flag True to build intermediate topology, false not to build
       */
      void interpolate(const bool flag);
      
      /** Get flag associated with building intermediate mesh topology
       * elements.
       *
       * @returns True if building intermediate topology, false if not building
       */
      bool interpolate(void) const;
      
      /** Set scales used to nondimensionalize mesh.
       *
       * @param dim Nondimensionalizer.
       */
      void normalizer(const spatialdata::units::Nondimensional& dim);
      
      /** Read mesh from file.
       *
       * @param mesh PyLith finite-element mesh.
       */
      void read(pylith::topology::Mesh* mesh);
      
      /** Write mesh to file.
       *
       * @param mesh PyLith finite-element mesh.
       */
      void write(pylith::topology::Mesh* const mesh);
      
      // PROTECTED MEMBERS //////////////////////////////////////////////
    protected :

      /// Write mesh
      virtual
      void _write(void) const = 0;
      
      /// Read mesh
      virtual
      void _read(void) = 0;
      
    }; // MeshIO

  } // meshio
} // pylith



// End of file 
