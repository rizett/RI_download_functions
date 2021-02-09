%----------------------------------------------------------------------------
%%% ABOUT %%%
% This script shows an example of how to download satellite data from
% NASA's Ocean Color Level 3 browser (https://oceancolor.gsfc.nasa.gov/l3/).
%
% BEFORE RUNNING, please ensure that you have downloaded wget.exe and 
% moved it to your C:/Windows/System32 directory. Restart Matlab after 
% doing this for the first time. 
%
% The following functions are used in this script. Please ensure they are
% saved in your Matlab path or working directory.
% 	[fname] = sat_fnames(wdir,sdate,edate,type,res,tres);
%	sat_dload(wdir,fname);
%	[mdate,lat,long,satdat]=sat_data(wdir,fname,latr,lonr,type);
%	sat_delete(wdir,fname)
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
    %(using sat_data function) and later deleted (using sat_delete)
	wdir = '\DATA_DIRECTORY';

%--- Set desired start / end dates and lat / long ranges for data of interest
	%NOTE: for data sets spanning multiple years, repeat this sequence for 
    % each year of data (i.e. sdate and date should be in the same year)
	sdate = datenum(2018,07,01); %desired first date of data
	edate = datenum(2018,07,10); %desired end date of data

    latr = [48 53]; %deg N
	lonr = [-150 -120]; %deg E
%----------------------------------------------------------------------------    

%----------------------------------------------------------------------------
%%% RUN DOWNLOADING / EXTRACTING SCRIPTS %%%
%--- Create list of files to be downloaded
	%This example will download chl-a at 4 km and daily resolution
	[fname,filz] = sat_fnames(wdir,sdate,edate,'chl',4,'day'); 
	%fname = .txt file that contains the list of files to be downloaded
	%filz = matlab variable that contains the list of files

%--- Download files to directory
	%watch as files start to populate your wdir. 
	%Matlab will also show the download progress.
    	sat_dload(wdir,fname); %just be a little patient here .... have a coffee, go for a walk! 

%--- Extract data from .nc files
	[mdate,lat,long,satdat]=sat_data(wdir,fname,latr,lonr,'chl'); %note the type here is the same as in sat_fnames
    %mdate = time array of extracted satellite data
    %lat, long = lat and long arrays of extracted satellite data
    %satdat = 3D data matrix (size time x lat x long)
    
	%plot average
        sd = squeeze(nanmean(satdat(:,:,:)));
        figure; pcolor(long,lat',sd); shading flat        

%--- (OPTIONAL) Delete files from wdir
	%Run this when desired data has been extracted.
	sat_delete(wdir,fname)

%----------------------------------------------------------------------------
     
clearvars -except satdat mdate lat long

clc
