#!/usr/bin/env python
#
# ----------------------------------------------------------------------
#
#                           Brad T. Aagaard
#                        U.S. Geological Survey
#
# <LicenseText>
#
# ----------------------------------------------------------------------
#

## @file pyre/meshio/DataWriterVTKSubSubMesh.py
##
## @brief Python object for writing finite-element data to VTK file.

from DataWriterVTK import DataWriterVTK
from meshio import SubSubMeshDataWriterVTK as ModuleDataWriterVTK

# DataWriterVTKSubSubMesh class
class DataWriterVTKSubSubMesh(DataWriterVTK, ModuleDataWriterVTK):
  """
  Python object for writing finite-element data to VTK file.

  Inventory

  Factory: output_data_writer
  """

  # PUBLIC METHODS /////////////////////////////////////////////////////

  def __init__(self, name="datawritervtksubmesh"):
    """
    Constructor.
    """
    DataWriterVTK.__init__(self, name)
    ModuleDataWriterVTK.__init__(self)
    return


  def initialize(self, normalizer):
    """
    Initialize writer.
    """
    DataWriterVTK.initialize(self, normalizer)

    ModuleDataWriterVTK.filename(self, self.filename)
    ModuleDataWriterVTK.timeFormat(self, self.timeFormat)
    ModuleDataWriterVTK.timeConstant(self, self.timeConstantN)
    return
  

# FACTORIES ////////////////////////////////////////////////////////////

def output_data_writer():
  """
  Factory associated with DataWriter.
  """
  return DataWriterVTKSubSubMesh()


# End of file 
