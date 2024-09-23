from setuptools import setup
from Cython.Build import cythonize

setup(
    name='cython_mc',
    ext_modules=cythonize("cython_mc.pyx"),
)