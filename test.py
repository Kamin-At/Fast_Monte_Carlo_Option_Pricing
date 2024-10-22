import cython_mc
from plain_python_mc import *
from time import time

n = 30000
t1 = time()
cython_price, cython_SE = cython_mc.down_and_out_option(n, 95, 100, 100, 0.1, 3.0, 0.06)
t2 = time()
print(
    "cython_price:", cython_price, "cython_SE:", cython_SE, "cython_time[s]:", t2 - t1
)
python_price, python_SE = down_and_out_option_py(2 * n, 95, 100, 100, 0.1, 3.0, 0.06)
t3 = time()
print(
    "python_price:", python_price, "python_SE:", python_SE, "python_time[s]:", t3 - t2
)

print(
    "Cython:",
    t2 - t1,
    "Python:",
    t3 - t2,
    "ratio:",
    (t3 - t2) / (t2 - t1),
)
