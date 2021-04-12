function [mdate,lat,long,satdat]=sat_data(wdir,fname,latr,lonr,type);

%----------------------------------------------------------------------------
%%% ABOUT %%
% This function extracts the time, lat, long, and satelite data info 
% from .nc files downloaded from NASA's Ocean Color Level 3 browser 
% (https://oceancolor.gsfc.nasa.gov/l3/). Files were downloaded using 
% sat_dload() function
% 
% USAGE: [mdate,lat,long,satdat]=sat_data(wdir,fname,latr,lonr,type);
% 
% INPUT:
%     wdir = directory where downloaded files are saved
%     fname = filename of txt file containing all of the download urls
%     latr/lonr = lat/long ranges ([min max]) 
%         NOTE: longitude = deg E 
%     type = string specifying data you wish to download; one of: 
%           'cal','chl','sst','nsst','aer', 'par' (calcite, chl-a, day-time SST,
%           night-time SST, aerosol optical thickness or PAR respectively)
%           *More options to come in subsequent release*
% 
% OUTPUT:
%     mdate = array of matlab times
%     lat, long = lat/long arrays
%     satdat = data matrix (size: mdate x lat x long) 
%       units: sst (C); chl (mg/m3); calcite (); aer (); par ();
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: July 2019
%--------------------------------------------------------------------------

%--- CD to temporary folder created in sat_fnames()
    %This folder contains the .txt file (with the list of downloaded files) and
    %the downloaded .nc files. 
    cd([wdir '\sat_temp']); %cd to temp folder
    
%--- Open file with list of ulrs
    fid = fopen(fname); 

%--- Extract the list of files
    C = textscan(fid,'%s'); C = C{1};
    
%--- Close file
    fclose(fid); clear fid

%--- Get list of downloaded files
    f = dir('*.nc'); 
    sf = size(f);
    if sf(1) == 0
        display('No files downloaded')
        mdate = [];
        lat = []; long = []; satdat = [];
        return
    end

%--- Dumby variable to hold date
    mdate = [];
   
%--- Open each file and extract data 
first = 1;
if sf(1) ~= 0
    for jj = 1:numel(C)
        fn = C{jj}; 
        fi = strfind(fn,'getfile');
        fn = fn(fi+8:end); %get just the filename section of the string
        
        if exist(fn)==2 %file is part of current directory
            %extract date info
                yr = str2num(fn(2:5));
                jd = str2num(fn(6:8));
                mdate = [mdate; datenum(yr,0,jd)];

            %extract data
            %get lat/long (first iteration only)
                if first == 1
                    lat = ncread(fn,'lat'); 
                    long = ncread(fn,'lon');
                    
                    %Find lat / long data within specified latr / lonr
                    la = find(lat >= latr(1) & lat <= latr(2)); %find data within lat range
                    lo = find(long >= lonr(1) & long <= lonr(2)); %find data within long range

                    lat = lat(la);
                    long = long(lo);
                    
                    first = 0;
                end

            %get data
                if strcmp(type,'sst') || strcmp(type,'nsst');
                    dat = ncread(fn,'sst',[lo(1),la(1)],[length(lo),length(la)]);
                    satdat(jj,:,:) = dat';
                elseif strcmp(type, 'chl');
                    x = ncinfo(fn);
                    x = x.Variables(1).Name;
                    if strcmp(x,'chl_ocx')
                        dat = ncread(fn,'chl_ocx',[lo(1),la(1)],[length(lo),length(la)]);
                    elseif strcmp(x,'chlor_a');
                        dat = ncread(fn,'chlor_a',[lo(1),la(1)],[length(lo),length(la)]);
                    end
                    clear x
                    satdat(jj,:,:) = dat';
                elseif strcmp(type, 'cal');
                    dat = ncread(fn,'pic',[lo(1),la(1)],[length(lo),length(la)]);
                    satdat(jj,:,:) = dat';
                elseif strcmp(type, 'aer');
                    if mdate > datenum(2002,07,04)
                        dat = ncread(fn,'aot_869',[lo(1),la(1)],[length(lo),length(la)]); %Aqua
                    else
                        dat = ncread(fn,'aot_865',[lo(1),la(1)],[length(lo),length(la)]); %SeaWiFS
                    end        
                    satdat(jj,:,:) = dat';
                elseif strcmp(type, 'par');
                    dat = ncread(fn,'par',[lo(1),la(1)],[length(lo),length(la)]);
                    satdat(jj,:,:) = dat';
                end
        else
            mdate = [mdate; nan];
        end
            
        clear yr jd fn tt kk
        
    end
end

display(' ');
display('Data extracted');
end

