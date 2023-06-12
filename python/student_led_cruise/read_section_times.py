import os 

import pandas as pd

def read_section_times() -> pd.DataFrame:
    """Read section start and end times from csv

    Returns:
        pd.DataFrame: Dataframe with UTC and local section start and end times.
                      N.B. All datetimes are timezone unaware.
                      A display time string defined using Aries' local section start time
                      is also given.
    """

    # filepath relative to this file
    relative_filepath = r"../../metadata/section_times.csv"
    # absolute filepath
    filepath = os.path.join(os.path.dirname(__file__),relative_filepath)

    df = pd.read_csv(filepath,
                  dtype={'display_time_string': 'string', 'direction':'category'},
                  parse_dates=[
                      'display_time', 
                      'Aries_start_UTC', 
                      'Aries_start_local', 
                      'Aries_end_UTC', 
                      'Aries_end_local', 
                      'Pelican_start_UTC', 
                      'Pelican_start_local', 
                      'Pelican_end_UTC', 
                      'Pelican_end_local', 
                      'Point_Sur_start_UTC', 
                      'Point_Sur_start_local', 
                      'Point_Sur_end_UTC', 
                      'Point_Sur_end_local', 
                      'Polly_start_UTC', 
                      'Polly_start_local', 
                      'Polly_end_UTC', 
                      'Polly_end_local'
                    ]
                  )
    
    return df

if __name__ == "__main__":
    print(read_section_times().dtypes)