%----------------------------------------------------------------------------
%%% ABOUT %%%
% This script shows an example of how to download and extract NCEP/NCAR 
% reanalysis 1 data using the functions download_ncep & extract_ncep
%
% BEFORE RUNNING, please ensure that you have downloaded wget.exe and 
% moved it to your C:/Windows/System32 directory. Restart Matlab after 
% doing this for the first time. 
%
% The following functions are used in this script. Please ensure they are
% saved in your Matlab path or working directory.
% 	download_ncep();
%	extract_ncep();
%
% These functions are provided as-is and have been used / tested on Windows
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
    %(using download_ncep function)
	ndir = '\DATA_DIRECTORY';

%--- Set desired start / end dates and lat / long ranges for data of interest
	%NOTE: for data sets spanning multiple years, repeat this sequence for 
    % each year of data (i.e. t0 and date should be in the same year)
	t0 = datenum(2018,07,01); %desired first date of data
	tf = datenum(2018,07,10); %desired end date of data

    latr = [40 55]; %deg N
	lonr = [-150 -120]; %deg E
%---------------------------------------------------------------------------- 

%----------------------------------------------------------------------------
%%% RUN DOWNLOADING / EXTRACTING SCRIPTS %%%
%--- Download files to directory 
    %This function downloads a bunch of files. See the function and modify accordingly to
    %add or remove some.
    %The function will not download files that already exist on your hard drive, unless
    %they are > 7 days old and from the current year. 
	%watch as files start to populate your ndir. 
	%Matlab will also show the download progress.
    	download_ncep(str2num(datestr(t0,'yyyy')),ndir); %just be a little patient here .... have a coffee, go for a walk! 

%--- Extract data from nc file
    %This example is for wind data
    [dat]=extract_ncep(ndir,t0,tf,latr,lonr,'wind')

	%plot average to check it worked
        wi = squeeze(dat.wind_spd(1,:,:));
        figure; pcolor(dat.long,dat.lat',wi); shading flat

%----------------------------------------------------------------------------
     
clearvars -except dat

clc
