import os.path
import unittest

POSSIBLE_TEST_BINARIES = [
    'libreadline.so.5',
    'libreadline.so.6',
]

POSSIBLE_TEST_BINARY_PATHS = [
    '/lib',
    '/usr/lib',
    '/usr/local/lib',
]

class TestBase(unittest.TestCase):
    def get_test_binary(self):
        """Helper to obtain a test binary for object file testing.

        FIXME Support additional, highly-likely targets or create one
        ourselves.
        """
        for d in POSSIBLE_TEST_BINARY_PATHS:
            for lib in POSSIBLE_TEST_BINARIES:
                path = os.path.join(d, lib)

                if os.path.exists(path):
                    return path

        raise Exception('No suitable test binaries available!')
    get_test_binary.__test__ = False
