# Copyright David Abrahams 2004. Distributed under the Boost
# Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
'''
>>> from exception_translator_ext import *
>>> try:
...     throw_error();
... except RuntimeError, x:
...     print x
... else:
...     print 'Expected a RuntimeError!'
!!!error!!!
'''


def run(args=None):
    import sys
    import doctest

    if args is not None:
        sys.argv = args
    return doctest.testmod(sys.modules.get(__name__))


if __name__ == '__main__':
    print "running..."
    import sys

    status = run()[0]
    if (status == 0): print "Done."
    sys.exit(status)
