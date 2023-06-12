# SUNRISE Student Led Cruise #

Metadata and code for analysing the SUNRISE student led cruise. 

MATLAB and python functions for reading the metadata are defined in *matlab/student_led_cruise* and *python/student_led_cruise* respectively.

## Section times ##

Section start and end times (both UTC and local) are defined in *metadata/section_times.csv*. A display time and display time string is also defined for each section using Aries' local start time.  All times are defined as timezone unaware datetimes. 

## Transect coordinates ## 

Along- and across-track coordinates are defined from a linear fit to Aries' track. The transform parameters are saved in *metadata/transect_coordinates.json*. The coordinate and velocity transform functions can be imported from *python/student_led_cruise* or returned from *matlab/student_led_cruise/transect_coordinates.m*.

## Front position ## 

The mat file with the front positions Devon computed is included in the metadata. His code is also included in *matlab/front_position* for reference.

## Other code and data ## 

Our google drive: https://drive.google.com/drive/folders/15lmVhYCWKxgH1qS9wNFcpTVFKUbjTSAd?usp=drive_link.

T-Chain processing: https://github.com/Jamie-Hilditch/SUNRISE2022_TCHAIN.
