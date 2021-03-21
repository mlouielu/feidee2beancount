import os, sys

# beancount doesn't run from this directory
sys.path.append(os.path.dirname(__file__))

import feidee_importer

CONFIG = [feidee_importer.FeideeImporter()]
