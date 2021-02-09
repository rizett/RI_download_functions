%----------------------------------------------------------------------------
%%% ABOUT %%
% This example downloads and extracts NPP data within specified time and geographic
% limits.
% 
% The following function is used in this script. Please ensure it is
% saved in your Matlab path or working directory.
%       npp = get_npp(ndir, t0, tf, latr, lonr, tres, res, prod, del, del_strt);
% 
% BEFORE RUNNING, please ensure that you have downloaded wget.exe and 
% moved it to your C:/Windows/System32 directory. Restart Matlab after 
% doing this for the first time. 
%
% INPUT:
%   ndir = directory to which files will be downloaded (include full path)
%   t0, tf = start and end times for data of interest (Matlab format / timestamp)
%   latr, long = latitude and longitude ranges for data of interest
%		format: [lat_low, lat_hi], [lon_low, lon_hi]
%   tres = temporal resoltion; one of: 'mon' (monthly-avg) or '8d' (8-day)
%       DEFAULT = 'mon'
%   res = spatial resolution; one of: 'hi'(2160 by 4320 pixels) or 'lo' (1080 by 2160)
%       DEFAULT = 'hi'
%   del = binary option to delete files from local hard drive after extracting data 
%       (0 = no / default, 1 = yes)
%   del_strt = binary option to delete files from idir BEFORE running the script. This
%       option is useful if you want to empty the folder before beginning downloading new
%       data (i.e. if you haven't previously cleared old downoladed/.nc data)
%       (0 = no / default, 1 = yes)
% 
% OUTPUT:
%   check your adir  directory ;) (there will be files .. if you set del to 0)
%   npp structure
% 
% For issues or support, please contact Robert Izett (rizett{at}eoas.ubc.ca)
%--------------------------------------------------------------------------

clear; clc; close all; 

%set input parameters
    % npp = get_npp(ndir, t0, tf, latr, lonr, tres, res, prod, del, del_strt);
	ndir 	= 'specify\a\directory'; %directory where data will be downloaded to
	t0      = datenum(2003,12,01); %start date of interest
	tf      = datenum(2004,04,10); %end date of interest
	latr 	= [40 60]; %lat range
	lonr 	= [-160 -120]; %long range
    tres    = 'mon'; %time-resolution
    res     = 'lo'; %spatial resolution
    prod    = 'svgpm'; % product
    del 	= 1; %delete downloaded files from local hdd
    del_strt = 1; %empty ndir at start

%run the function
	npp = get_npp(ndir, t0, tf, latr, lonr, tres, res, prod, del, del_strt);

%plot an example
    close all;
	pcolor(npp.long,npp.lat,squeeze(nanmean(npp.npp))); shading flat
    colorbar; caxis([100 1200])
    
