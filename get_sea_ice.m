function cice = get_sea_ice(idir, locn, t0, tf, latr, lonr, del, del_strt);

%----------------------------------------------------------------------------
%%% ABOUT %%
% This functions downloads and extracts DAILY IFREMER/CERSAT SEA ICE DATA 
% within specified time limits.
% 
% Data files are downloaded from:
%   /ifremer/cersat/products/gridded/psi-concentration/data/
%   http://cersat.ifremer.fr/oceanography-from-space/our-domains-of-research/sea-ice
% 
% USAGE: cice = get_sea_ice(idir, locn, t0, tf, del);
% 
% BEFORE RUNNING, please ensure that you have downloaded wget.exe and 
% moved it to your C:/Windows/System32 directory. Restart Matlab after 
% doing this for the first time. 
%
% INPUT:
%   idir = directory to which files will be downloaded (include full path)
%   locn = 'n', 's' (for North/Arctic or South/Antarctic)
%   t0, tf = start and end times for data of interest (Matlab format / timestamp)
%   latr, long = latitude and longitude ranges for data of interest
%		format: [lat_low, lat_hi], [lon_low, lon_hi]
%   del = binary option to delete files from local hard drive after extracting data 
%       (0 = no / default, 1 = yes)
%   del_strt = binary option to delete files from idir BEFORE running the script. This
%       option is useful if you want to empty the folder before beginning downloading new
%       data (i.e. if you haven't previously cleared old downoladed/.nc data)
%       (0 = no / default, 1 = yes)
% 
% OUTPUT:
%   check your adir  directory ;) (there will be files .. if you set del to 0)
%   cice.time = Matlab time (UTC)
%   cice.lat = deg N (size 608 x 896 - 12 km resolution)
%   cice.lon = deg E (size 608 x 896 - 12 kn resoultion)
%   cice.ice_conc = % ice concentration (size time x 608 x 896 - 12 kn resoultion)
%   cice.units
%   cice.info
%
% Useful links:
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: November 2019
%--------------------------------------------------------------------------

%Set default values if some not specified
	if nargin == 4
		del = 0; %option to not delete files after data extracted
    end
    if nargin < 6
        del_strt = 0; %option to empty idir directory at start
    end

%CD to directory where netcdf files will be downloaded
    cd(idir);
    
% Delete contents of idir at start
    if del_strt
       filz = dir(); 
       for kk = 1:numel(filz);
           delete(filz(kk).name)
       end
    end
    clear filz
    
%File to which ftp urls are written
	fid = fopen('ice_urls.txt','wt');    
        
%Set ftp download prefix based on source and location
%and get files with grid information and set ftp download prefix based on source  location
	if strcmp(locn,'n')
		pref = 'ftp://ftp.ifremer.fr/ifremer/cersat/products/gridded/psi-concentration/data/arctic';
        fprintf(fid,'ftp://ftp.ifremer.fr/ifremer/cersat/products/gridded/psi-concentration/data/grid_north_12km.nc.gz\n');
	elseif strcmp(locn,'s')
		pref = 'ftp://ftp.ifremer.fr/ifremer/cersat/products/gridded/psi-concentration/data/antarctic/';
        fprintf(fid,'ftp://ftp.ifremer.fr/ifremer/cersat/products/gridded/psi-concentration/data/grid_south_12km.nc.gz\n');
	else
		error('You must specify a valid FTP data source: ''n'' (for Arctic) or ''S'' (for Antarctic)!')
    end
    
%Make list of files to download based on specified time ranges
%Write names to text file
	%times 	
	tt = t0:tf;
	yy = datestr(tt,'yyyy');
	
    for kk = 1:numel(tt)
		ftpname(kk,:) = [pref,'/daily/netcdf/',yy(kk,:),'/',datestr(tt(kk),'yyyymmdd'),'.nc.Z'];		
		fprintf(fid,'%s\n',ftpname(kk,:));
    end
    clear yy kk
    fclose(fid);
    
%Download files to idir, using wget 
	%first, change system directory
		system(['cd ', idir, '\']); 
	%now download
		system(['wget -i ', 'ice_urls.txt']); 

	display(' ')
	display('Downloading complete!')
	display(' ')

%Unzip files
    %grid file
        gfs = dir('*.gz');
        gfs = gunzip(gfs.name);
    
    %ice files
        ifs = dir('*.Z');
        for kk = 1:numel(ifs)
            if ispc
                str = ['7z e ', ifs(kk).name];
            else
                str = ['uncompress', ' ', ifs(kk).name];
            end
            system(str);
            fnames(kk,:) = ifs(kk).name(1:end-2);
        end
        
    display(' ')
	display('Files unzipped!')
	display(' ')
    
%Extract data from files    
    %create variables to hold data
        cice.time = tt;
        cice.lat = [];
        cice.lon = [];
        cice.ice_conc = [];
        cice.units.time = 'Matlab format, UTC';
        cice.units.lat = '+ deg. N';
        cice.units.long = '+ deg. E';
        cice.units.ice_conc = 'decimal %';
        cice.info.source = [pref,'/'];
        cice.info.ftp_files = ftpname;
        
    %get grid data first
        cice.lat = double(ncread(char(gfs),'latitude'));
        cice.lon = double(ncread(char(gfs),'longitude'));
            li = find(cice.lon>180);
            cice.lon(li) = cice.lon(li)-360;
            
    %Down scale grid to be within latr/lonr
        %Fit to more regular grid
        la = latr(1):nanmin(nanmean(abs(diff(cice.lat)))):latr(2);
        lo = lonr(1):nanmean(nanmin(abs(diff(cice.lon)))):lonr(2);
        [x,y] = meshgrid(lo,la);        
        
    %get ice data
        for kk = 1:size(fnames,1)
            icedat = double(ncread(fnames(kk,:),'concentration'))/100;
            icedat = griddata(cice.lon,cice.lat,icedat,x,y);
            cice.ice_conc = [cice.ice_conc; reshape(icedat,1,size(icedat,1),size(icedat,2))];
            clear icedat
        end
        clear kk 
        
    cice.lat = la; cice.lon = lo;
    
    display(' ')
	display('Data extracted!')
	display(' ')
        
%Delete files from HDD if specified
    if del
        % Delete .nc data files
            for kk = 1:size(fnames,1)
                delete(fnames(kk,:))
            end
            
        % Delete .Z data files
            for kk = 1:size(ifs,1)
                delete(ifs(kk).name)
            end
        
        % Delete grid file
            delete(char(gfs))
            delete([char(gfs), '.gz'])

        % Remove text file
            delete('ice_urls.txt');

    end
    
return
