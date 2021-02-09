RI_download_functions

Fed-up of manually clicking on online data files to download them? The functions here can be used to download these files automatically!

Contents:
Matlab functions for downloading online data products. 
Includes functions for downloading:
- NASA Ocean Color L3 satellite products (see RUN_sat.m) NOTE: these scripts need to be edited to fit NASA's new data archiving. 
- CCMP Wind speed product (see RUN_ccmp.m)
- NCEP/NCAR Reanalysis 1 sea surface fields (see run_ncep.m)
- Argo data (see RUN_argo.m)
- Ifremer/CSAT daily sea ice concentration NOTE: to be updated for ASMR-2 product
- +others to come soon!

To use: 
1) Download the "wget" extension (https://eternallybored.org/misc/wget/ for Windows), and copy wget.exe to your C:/Windows/System32 directory.
2) Restart Matlab
3) Download the functions in this folder (individually, or by cloning or downloading the whole repository), and add them to your Matlab working directory / path.
4) See the "RUN" files for examples on how to use the functions. 

For questions / comments, please contact:
Robert Izett 
rizett{at}eoas.ubc.ca
