import os
import json

import numpy as np
from numpy.typing import NDArray

# filepath relative to this file
relative_filepath = r"../../metadata/transect_coordinates.json"
# absolute filepath
filepath = os.path.join(os.path.dirname(__file__), relative_filepath)

# read transform parameters
with open(filepath, "r") as fp:
    tp = json.load(fp)


def transect_coordinates(
    lon: NDArray[np.float64], lat: NDArray[np.float64]
) -> tuple[NDArray[np.float64], NDArray[np.float64]]:
    x = (lon - tp["lon0"]) * tp["lon2km"]
    y = (lat - tp["lat0"]) * tp["lat2km"]
    xt = x * np.cos(tp["theta"]) + y * np.sin(tp["theta"])
    yt = -x * np.sin(tp["theta"]) + y * np.cos(tp["theta"])
    return xt, yt


def transect_velocities(
    u: NDArray[np.float64], v: NDArray[np.float64]
) -> tuple[NDArray[np.float64], NDArray[np.float64]]:
    ut = u * np.cos(tp["theta"]) + v * np.sin(tp["theta"])
    vt = -u * np.sin(tp["theta"]) + v * np.cos(tp["theta"])
    return ut, vt


if __name__ == "__main__":
    lon = np.array([-92.3, -92.29, -92.28])
    lat = np.array([29.7, 29.8, 29.8])
    xt, yt = transect_coordinates(lon, lat)
    print(xt, yt)

    u = np.array([0.15, 0.17, 0.19])
    v = np.array([0.0, 0.1, 0.12])
    ut, vt = transect_velocities(u, v)
    print(ut, vt)
