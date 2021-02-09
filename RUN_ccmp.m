%----------------------------------------------------------------------------
%%% ABOUT %%%
% This script shows an example of how to download CCMP wind speed data from
% http://www.remss.com/measurements/ccmp/.
%
% BEFORE RUNNING, please ensure that you have downloaded wget.exe and 
% moved it to your C:/Windows/System32 directory. Restart Matlab after 
% doing this for the first time. 
%
% The following functions are used in this script. Please ensure they are
% saved in your Matlab path or working directory.
% 	ccmp_fnames();
%	ccmp_dload();
%	ccmp_data();
%	ccmp_delete()
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
    %NOTE 2: At time of writing (July 2019) CCMP data are only available to the END OF
    %DECEMBER, 2017. Check http://data.remss.com/ccmp/v02.0/ for last available data.
	sdate = datenum(2017,07,01); %desired first date of data
	edate = datenum(2017,07,10); %desired end date of data

    latr = [48 53]; %deg N
	lonr = [-150 -120]; %deg E
%---------------------------------------------------------------------------- 

%----------------------------------------------------------------------------
%%% RUN DOWNLOADING / EXTRACTING SCRIPTS %%%
%--- Create list of files to be downloaded
    %This example shows data downloaded in daily files. Change 'day' to 'mon' to extract
    %all monthly data together.
	[fname,filz] = ccmp_fnames(wdir,sdate,edate,'day'); 
	%fname = .txt file that contains the list of files to be downloaded
	%filz = matlab variable that contains the list of files

%--- Download files to directory 
	%watch as files start to populate your wdir. 
	%Matlab will also show the download progress.
    	ccmp_dload(wdir,fname); %just be a little patient here .... have a coffee, go for a walk! 

%--- Extract wind data from nc file
    [mdate,lat,long,wind]=ccmp_wind(wdir,fname,latr,lonr,'day'); 

	%plot average to check it worked
        wi = squeeze(wind(1,:,:));
        figure; pcolor(long,lat',wi); shading flat

%--- (OPTIONAL) Delete files from wdir
	%Run this when desired data has been extracted.
	ccmp_delete(wdir,fname)

%----------------------------------------------------------------------------
     
clearvars -except wind mdate lat long

clc
