# I used the follow link for smoothing:
# https://stackoverflow.com/questions/76399932/how-to-interpolate-beautiful-smooth-curve-path-for-the-given-x-and-y-mouse-coord
# For arg handling:
# https://www.geeksforgeeks.org/python/command-line-arguments-in-python/
# For plot text sizing:
# https://www.geeksforgeeks.org/python/change-font-size-in-matplotlib/
# Plot colors:
# https://matplotlib.org/stable/gallery/color/named_colors.html

from scipy.interpolate import make_interp_spline
import numpy as np
import matplotlib.pyplot as plt
import sys

if len(sys.argv) != 2:
  print("Intended usage: ", sys.argv[0], "<showOptimalLine=True|False>")
  exit()

isOpt     = sys.argv[1].lower() == "true"
smoothing = 300

x         = np.array(list(range(1,9)))
y_prime   = np.array(
  [138.33,132.9,142.06,148.437,157.566,160.941,164.770,168.819])
y         = y_prime[0] / y_prime

y2_prime  = np.array(
  [284.98,256.67,291.178,302.971,318.386,323.329,316.111,318.419])
y2        = y2_prime[0] / y2_prime

y3_prime  = np.array(
  [173.24, 161.362, 198.621, 211.561, 223.143, 224.918, 228.285, 228.076])
y3        = y3_prime[0] / y3_prime

xOpt      = np.array([1,2,3])
yOpt      = np.array([1,2,3])

x_smooth  = np.linspace(x.min(), x.max(), smoothing)
spline    = make_interp_spline(x, y, k=3)
y_smooth  = spline(x_smooth)

x_smooth2 = np.linspace(x.min(), x.max(), smoothing)
spline2   = make_interp_spline(x, y2, k=3)
y_smooth2 = spline2(x_smooth2)

x_smooth3 = np.linspace(x.min(), x.max(), smoothing)
spline3   = make_interp_spline(x, y3, k=3)
y_smooth3 = spline3(x_smooth3)

window    = 8 #smoothness

sz        = 3
smooth_sz = int((sz / len(x)) * smoothing)
title = "Speedup vs Core Count, with optimal line"

if not isOpt:
  sz        = len(x)
  smooth_sz = smoothing
  title = "Speedup vs Core Count"

plt.rcParams.update({'font.size': 20})
plt.title(title)
plt.grid(True)
plt.plot(x_smooth[:smooth_sz], y_smooth[:smooth_sz], color='royalblue', label='Batch-Par Variation')
plt.plot(x[:sz], y[:sz],'^', color='royalblue', markersize=6)
plt.plot(x_smooth2[:smooth_sz], y_smooth2[:smooth_sz], color='forestgreen', label='Seq-Par Variation')
plt.plot(x[:sz], y2[:sz],'^', color='forestgreen', markersize=6)
plt.plot(x_smooth3[:smooth_sz], y_smooth3[:smooth_sz], color='darkslateblue', label='Non-overlapping Batches Variation')
plt.plot(x[:sz], y3[:sz],'^', color='darkslateblue', markersize=6)
if isOpt: plt.plot(xOpt, yOpt, color='peru', label='Optimal')
plt.ylabel("Speedup")
plt.xlabel("Cores")
plt.legend()
plt.show()
