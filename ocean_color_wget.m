clear all; close all; clc

%Where files will be downloaded to
%MAC
    % cd '/Users/Robert/Desktop/test'
%PC
    cd 'C:\Users\Robert\Desktop\Data\Testing\sat_temp';

%Change system direcory (PC only; not necessary for Mac)
if ispc
    system(['cd ', cd, '\']);
end

%Download NASA satellite ocean color following ("use wget" section)
%https://oceancolor.gsfc.nasa.gov/data/download_methods/#download_sec

%If you don't have a username/pwd already, create one at:
%https://urs.earthdata.nasa.gov/home

usr_name = 'usr@domain.ca'; %change to your actual username
pwd = '1234'; %change to your actual password

%To be prompted to enter passwork (note, you'll enter your password in the
%command line, but the characters may not appear [eg on Mac])
%THIS WORKED FOR ME ON THE MAC, BUT NOT ON PC
% % % % system(['wget --user=' usr_name, ' --ask-password ', ...
% % % %     ' --auth-no-challenge=on ',...
% % % %     'https://oceandata.sci.gsfc.nasa.gov/ob/getfile/V2019302.L3m_DAY_SNPP_CHL_chl_ocx_9km.nc'])

%To automatically enter password and download one file
system(['wget --user=' usr_name, ' --password=', pwd, ...
    ' --auth-no-challenge=on ',...
    'https://oceandata.sci.gsfc.nasa.gov/ob/getfile/V2019301.L3m_DAY_SNPP_CHL_chl_ocx_9km.nc']);

%To download from a file by passing username and password
system(['wget --user=' usr_name, ' --password=', pwd, ...
    ' --auth-no-challenge=on ',...
    '-i sat_files.txt']);

%Extract data
    dat = ncdataset('V2019302.L3m_DAY_SNPP_CHL_chl_ocx_9km.nc');
    dat.variables

    la = ncread('V2019302.L3m_DAY_SNPP_CHL_chl_ocx_9km.nc','lat');
    lo = ncread('V2019302.L3m_DAY_SNPP_CHL_chl_ocx_9km.nc','lon');
    chl = ncread('V2019302.L3m_DAY_SNPP_CHL_chl_ocx_9km.nc','chl_ocx');

%Plot
    pcolor(lo,la,chl'); shading flat
    xlim([-150 -120])
    ylim([48 56])
    caxis([0 1])
