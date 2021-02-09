%----------------------------------------------------------------------------
%%% ABOUT %%
% This example downloads and extracts ARGO data within specified time and geographic
% limits.
% 
% The following function is used in this script. Please ensure it is
% saved in your Matlab path or working directory.
%       argo = get_argo(adir, source, locn, t0, tf, latr, lonr, del);
% 
% BEFORE RUNNING, please ensure that you have downloaded wget.exe and 
% moved it to your C:/Windows/System32 directory. Restart Matlab after 
% doing this for the first time. 
%
% INPUT:
%   adir = directory to which files will be downloaded (include full path)
%   source = 'eu' or 'us' (for European/Coriolis or US/Monterey data access centres, 
%       respectively) 
%   locn = 'pac', 'atl', 'ind' (for Pacific, Atlantic, or Indian Oceans, respectively)
%   t0, tf = start and end times for data of interest (Matlab format / timestamp)
%   latr, long = latitude and longitude ranges for data of interest
%		format: [lat_low, lat_hi], [lon_low, lon_hi]
%   del = binary option to delete files from local hard drive after extracting data 
%       (0 = no / default, 1 = yes)
% 
% OUTPUT:
%   check your adir  directory ;) (there will be files .. if you set del to 0)
%   argo = structure
% 
% For issues or support, please contact Robert Izett (rizett{at}eoas.ubc.ca)
%--------------------------------------------------------------------------

clear; clc; close all; 

%set input parameters
	adir 	= 'specify\a\directory'; %directory where data will be downloaded to
	source 	= 'us'; %use USA server
	locn	= 'pac'; %data from pacific
	t0 	= datenum(2018,12,25); %start date of interest
	tf 	= datenum(2019,01,05); %end date of interest
	latr 	= [40 60]; %lat range
	lonr 	= [-160 -120]; %long range
	del 	= 1; %delete downloaded files from local hdd

%run the function
	argo = get_argo(adir,source, locn, t0, tf, latr, lonr, del)

%plot an example
    close all;
	pcolor(repmat(argo.lon,1,size(argo.dep,2)),-argo.dep,argo.T); shading flat
    
