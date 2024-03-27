"""Functions for handling matlab things"""

import numpy as np
from numpy.typing import ArrayLike
import pandas as pd

def datenum2pd(dn: ArrayLike) -> pd.DatetimeIndex:
    """Converts an array of matlab datenums to pandas datetime"""
    return pd.to_datetime(np.array(dn)-719529,unit='d')