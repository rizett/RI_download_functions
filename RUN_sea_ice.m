%----------------------------------------------------------------------------
%%% ABOUT %%%
% This script shows an example of how to download sea ice data from
% IFREMER.
%
% BEFORE RUNNING, please ensure that you have downloaded wget.exe and 
% moved it to your C:/Windows/System32 directory. Restart Matlab after 
% doing this for the first time. 
%
% The following function is used in this script. Please ensure is
% saved in your Matlab path or working directory.
% 	cice = get_sea_ice(idir, locn, t0, tf, del);
%
% This functions are provided as-is and have been used / tested on Windows
% 7 and 10, using Matlab 2018.
%
% For issues or support, please contact Robert Izett (rizett{at}eoas.ubc.ca)
%----------------------------------------------------------------------------

%--- (OPTIONAL) Clear current Matlab session
	clear all; close all; clc

%----------------------------------------------------------------------------
%%% INPUT INFORMATION %%%
%--- Indicate folder where data will be (temporarily) downloaded 
	%This is the directory where downloaded files will be saved 
    %(using sat_data function) and later deleted (using sat_delete)
	idir = '\DATA_DIRECTORY';
    
%--- Set desired start / end dates for data of interest
	sdate = datenum(2018,07,01); %desired first date of data
	edate = datenum(2018,07,10); %desired end date of data
    
%--- Set desired lat/long range
    latr = [60 85]; %lat range
	lonr = [-100 -50]; %long range

%--- Example cruise track to which sea ice data will be interpolated
    lat = [70 70 72 74 75 74 77];
    lon = [-60 -61 -62 -64 -66 -70 -75];
    tt = linspace(datenum(2018,07,02),datenum(2018,07,08),numel(lat));
    
%----------------------------------------------------------------------------    
 
%----------------------------------------------------------------------------
%%% RUN DOWNLOADING / EXTRACTING SCRIPT %%%
%--- Use function to download files
	%This example will download Arctic sea ice at 12 km, daily resolution
    %Files will NOT be deleted at the end (set del = 1 if you want to delete automatically);
 	cice = get_sea_ice(idir, 'n', sdate, edate, latr, lonr, 0, 1);
%----------------------------------------------------------------------------

%----------------------------------------------------------------------------
%%% INTERPOLATE TO CRUISE TRACK %%%
    %Use mean ice conc. over time range
    mean_ice = interp2(cice.lon,cice.lat,squeeze(nanmean(cice.ice_conc)),lon,lat);
    
    %Interpolated to time x lat x long
    [x,y,z] = meshgrid(cice.lat,cice.time,cice.lon);
    cruise_ice = interp3(x,y,z,cice.ice_conc,lat,tt,lon);
%----------------------------------------------------------------------------
     
clearvars -except cice cruise_ice mean_ice lat lon tt

clc
