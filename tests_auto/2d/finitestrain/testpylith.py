#!/usr/bin/env nemesis
#
# ======================================================================
#
# Brad T. Aagaard, U.S. Geological Survey
# Charles A. Williams, GNS Science
# Matthew G. Knepley, University of Chicago
#
# This code was developed as part of the Computational Infrastructure
# for Geodynamics (http://geodynamics.org).
#
# Copyright (c) 2010-2015 University of California, Davis
#
# See COPYING for license information.
#
# ======================================================================
#

import unittest

def suite():
  """
  Create test suite.
  """
  suite = unittest.TestSuite()

  from TestRigidRotate import TestRigidRotate
  suite.addTest(unittest.makeSuite(TestRigidRotate))

  from TestCompressRotate import TestCompressRotate
  suite.addTest(unittest.makeSuite(TestCompressRotate))

  from TestShearRotate import TestShearRotate
  suite.addTest(unittest.makeSuite(TestShearRotate))

  return suite


def main():
  """
  Run test suite.
  """
  unittest.TextTestRunner(verbosity=2).run(suite())
  return


# ----------------------------------------------------------------------
if __name__ == '__main__':
  main()

  
# End of file 
