# 0097_unit_testing
# NOTE: Python has unittest built in; C needs a macro or library.

import unittest


def add(a, b):
    return a + b


def divide(a, b):
    return a / b


class T(unittest.TestCase):
    def test_add(self):
        self.assertEqual(add(2, 3), 5)

    def test_raises(self):
        with self.assertRaises(ZeroDivisionError):
            divide(1, 0)


unittest.main(argv=["x"], exit=False)
