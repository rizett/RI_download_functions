function npp = get_npp(ndir, t0, tf, latr, lonr, tres, res, prod, del, del_strt);

%----------------------------------------------------------------------------
%%% ABOUT %%
% This functions downloads and extracts NPP (mg C/m2/d) data from the OSU 
% Productivity Site within the specified time and lat/long limits 
% 
% Data files are downloaded from:
%   http://www.science.oregonstate.edu/ocean.productivity/custom.php
% 
% USAGE: npp = get_npp(ndir, t0, tf, latr, lonr, tres, res, prod, del, del_strt);
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
%   prod = Product: 'svgpm' (Standard VGPM), 'evgpm' (Eppley VGPM', 'cbpm' (CbPM)
%   del = binary option to delete files from local hard drive after extracting data 
%       (0 = no / default, 1 = yes)
%   del_strt = binary option to delete files from idir BEFORE running the script. This
%       option is useful if you want to empty the folder before beginning downloading new
%       data (i.e. if you haven't previously cleared old downoladed/.nc data)
%       (0 = no / default, 1 = yes)
% 
% OUTPUT:
%   check your adir  directory ;) (there will be files .. if you set del to 0)
%   npp.time = Matlab time (UTC)
%   npp.lat = deg N 
%   npp.lon = deg E
%   npp.npp = mg C / m2 /d
%   npp.units
%   npp.info
%
% Useful links:
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: November 2019
%--------------------------------------------------------------------------
%Set default values if some not specified
    if nargin < 5
        error('Not enough input variables!')
    end
    if nargin < 10
        warning('You did not specify all input parameters. Some defaults set!')
    end
    if nargin == 5
        tres = 'mon';
        res = 'hi';
        prod = 'svgpm';
        del = 0;
        del_strt = 0;
    elseif nargin == 6
        res = 'hi';
        prod = 'svgpm';
        del = 0;
        del_strt = 0;
    elseif nargin == 7
        prod = 'svgpm';
        del = 0;
        del_strt = 0;
    elseif nargin == 8
        del = 0;
        del_strt = 0;
    elseif nargin == 9
        del_strt = 0;
    end
    	
%Time warning
    if t0 < datenum(1997,10,01);
        warning('You selected a t0 value before October, 1997 (the start of the SeaWiFS era). t0 has been set to 1 October, 1997')
    end

cd(ndir); 

%Delete contents of ndir at start
    if del_strt
       filz = dir(); 
       for kk = 1:numel(filz);
           delete(filz(kk).name)
       end
    end
    clear filz

%Create time variables    
    tt = t0:tf;
    yrs = str2num(datestr(tt,'yyyy'));
    yrs = unique(yrs);

%Create file download name prefix
    pref = 'http://orca.science.oregonstate.edu/data';

%Create string character for specified temporal resolution
    if strcmp(tres,'mon')
        tres_str = '/monthly/';
    elseif strcmp(tres,'8d')
        tres_str = '/8day/';
    end

%Create string character for specified spatial resolution
    if strcmp(res,'hi')
        res_str = '/2x4';
        sz = [2160 4320];
    elseif strcmp(res,'lo')
        res_str = '/1x2';
        sz = [1080 2160];
    end

%Create list of yearly files to download based on Satellite (specified years) and desired
%product (VGPM vs Eppley VGPM vs CbPM)
    %File to which ftp urls are written
        fid = fopen('npp_urls.txt','wt'); 
    
    %Place holder for satellite 
        sat_type = {}; 
    for kk = 1:numel(yrs)
        if yrs(kk) < 2003 %Use SeaWIFS product
            if strcmp(prod,'svgpm'); %Standard VGPM       
                fn = [pref,res_str,tres_str,'vgpm.r2014.s.chl.a.sst/hdf/vgpm.s.',num2str(yrs(kk)),'.tar'];
            elseif strcmp(prod,'evgpm'); %Eppley VGPM
                fn = [pref,res_str,tres_str,'eppley.r2014.s.chl.a.sst/hdf/eppley.s.',num2str(yrs(kk)),'.tar'];
            elseif strcmp(prod,'cbpm'); %CbPM
                fn = [pref,res_str,tres_str,'cbpm2.s.r2014.gsm.v8/hdf/cbpm.s.',num2str(yrs(kk)),'.tar'];
            end
            sat_type = [sat_type; 'SeaWifs'];
            
        elseif yrs(kk) >= 2003 & yrs(kk) < 2013 %Use MODIS product
            if strcmp(prod,'svgpm'); %Standard VGPM       
                fn = [pref,res_str,tres_str,'vgpm.r2018.m.chl.m.sst/hdf/vgpm.m.',num2str(yrs(kk)),'.tar'];
            elseif strcmp(prod,'evgpm'); %Eppley VGPM
                fn = [pref,res_str,tres_str,'eppley.r2018.m.chl.m.sst/hdf/eppley.m.',num2str(yrs(kk)),'.tar'];
            elseif strcmp(prod,'cbpm'); %CbPM
                fn = [pref,res_str,tres_str,'cbpm2.modis.r2018/hdf/cbpm.m.',num2str(yrs(kk)),'.tar'];
            end
            sat_type = [sat_type; 'MODIS'];
            
        elseif yrs(kk) >= 2013 %Use VIRIS product
            if strcmp(prod,'svgpm'); %Standard VGPM       
                fn = [pref,res_str,tres_str,'vgpm.r2018.v.chl.v.sst/hdf/vgpm.v.',num2str(yrs(kk)),'.tar'];
            elseif strcmp(prod,'evgpm'); %Eppley VGPM
                fn = [pref,res_str,tres_str,'eppley.r2018.v.chl.v.sst/hdf/eppley.v.',num2str(yrs(kk)),'.tar'];
            elseif strcmp(prod,'cbpm'); %CbPM
                fn = [pref,res_str,tres_str,'cbpm2.viirs.r2018/hdf/cbpm.v.',num2str(yrs(kk)),'.tar'];
            end 
            sat_type = [sat_type; 'VIRIS'];
        end

        fprintf(fid,[fn,'\n']); %Write file-to-download to list
    end
    fclose(fid); clear kk fn
    
%Download files to ndir, using wget 
	%first, change system directory
		system(['cd ', ndir, '\']); 
	%now download
		system(['wget -i ', 'npp_urls.txt']); 
        
    display(' ')
	display('Downloading complete!')
	display(' ')

%Unzip files
    tfs = dir('*.tar');
    for kk = 1:numel(tfs)
        if ispc
            str = ['7z e ', tfs(kk).name];
        else
            str = ['uncompress', ' ', tfs(kk).name];
        end
        system(str);
    end
    
    gfs = dir('*.gz');
    for kk = 1:numel(gfs)
        gunzip(gfs(kk).name);
    end

    display(' ')
	display('Files unzipped!')
	display(' ')
    
%Extract data from files    
    fnames = dir('*.hdf');
    
    %Latitude / longitude arrays and indices
        lat=linspace(-90,90,sz(1));
        lon=linspace(-180,180,sz(2));

        lai = find(lat >= latr(1) & lat <= latr(2));
        loi = find(lon >= lonr(1) & lon <= lonr(2));

        lat = lat(lai);
        lon = lon(loi);

    % Extract npp data
    stype = {};
    for kk = 1:numel(fnames)
        %Read from file
            fil = fnames(kk).name;
            npp = hdfread(fil, '/npp', 'Index', {[1 1], [1 1], [sz]});

        %time
            time(kk) = datenum(str2num(fil(6:9)), 0, str2num(fil(10:12)));

        %NPP
            npp=double(npp); npp(npp<0)=nan; npp=flipud(npp);
            dat(kk,:,:) = npp(lai,loi);
            
        %Satellite type
            yi = find(yrs == str2num(datestr(time(kk),'yyyy')));
            stype(kk,:) = sat_type(yi);

        clear npp fil r c        
    end

    %Keep only data within time range
        ti = find(time >= t0 & time <= tf);    
    
        npp.time = time(ti); %matlab format
        npp.lat = lat; %deg. N
        npp.long = lon; %deg. E
        %mg C / m**2 / day 
        npp.npp = dat(ti,:,:); %size time x lat x long
        npp.units.time = 'UTC';
        npp.units.lat = 'deg. N';
        npp.units.long = 'deg. E';
        npp.units.npp = 'mgC / m2 /d';
        npp.info.sat_type = stype(ti);
        npp.info.product = prod;
        npp.info.source = 'http://www.science.oregonstate.edu/ocean.productivity/custom.php';
        
%Delete files from HDD if specified
    if del
        % Delete .nc data files
            for kk = 1:size(fnames,1)
                delete(fnames(kk).name)
            end
            
        % Delete .gz data files
            for kk = 1:size(gfs,1)
                delete(gfs(kk).name)
            end
        
        % Delete .tar files
            for kk = 1:size(tfs,1);
            	delete(tfs(kk).name);
            end
            
        % Remove text file
            delete('npp_urls.txt');
    end
    
return