function [data] = get_iabp_dat(ndir,latr,lonr);

%--------------------------------------------------------------------------------------------------
% Extract data from downloaded International Arctic Buoy Program files 
% within specified lat/long range

% USAGE: dat = get_iabp_dat(nc,latr,lonr);
%   e.g.dat = dload_iabp_dat('C:\Users\user\Desktop\Data\IABP',[50 70,[-110 -40]);
%
% INPUT:
%   nc = directory where data saved
%   latr,longr = latitude and longitude arrays, respectively, formatted as
%       [min max]
% 
% OUTPUT:
%   dat = data structure
% 
% Links:
%   IABP: 
%       http://iabp.apl.washington.edu/data.html
%   Original FTP source (daily files):
%       http://iabp.apl.washington.edu/Data_Products/Daily_Full_Res_Data/
% 
% Data Reference & Citation:
%   
% Script Reference:
%   R. Izett
%   rizett@eoas.ubc.ca
%   UBC Oceanography
%   Last modified: Apr. 2020
%--------------------------------------------------------------------------------------------------

%--- cd to data location & get list of files
    cd(ndir)
    filz = dir('Fr*.dat');
    
%--- read through files and extract data
    dat = [];
    day = [];
    for kk = 1:numel(filz)
        fid = fopen(filz(kk).name,'rt'); %open .dat file
        %scan for data
        readdat = textscan(fid,[repmat('%f;',1,10),'%f'],100000,'headerlines',1,'collectoutput',1); readdat = readdat{1};
        fclose(fid);
       
        %keep only data within range
        lai = find(readdat(:,7) >= latr(1) & readdat(:,7) <= latr(2) & readdat(:,8) >= lonr(1) & readdat(:,8) <= lonr(2));
        readdat = readdat(lai,:);
        
        dat = [dat;readdat];
        day = [day; repmat(datenum(filz(kk).name(4:end-4),'yyyymmdd'),length(lai),1)];
        clear readdat lai
        
    end
    
    %Package data
        data.utc        = day + datenum(0,0,0,dat(:,3),dat(:,4),0);
        data.buoy_id    = dat(:,1);
        data.lat        = dat(:,7);
        data.lon        = dat(:,8);
        data.slp_mbar   = dat(:,9);
        data.sst_C      = dat(:,10);
        data.air_T      = dat(:,11);
        
return