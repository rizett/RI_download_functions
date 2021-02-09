function argo = get_argo(adir,source, locn, t0, tf, latr, lonr, del);

%----------------------------------------------------------------------------
%%% ABOUT %%
% This functions downloads and extracts ARGO data within specified time and geographic
% limits.
% Data files are downloaded from the European (Coriolis) or American (Monterey) FTP data
% access centres (depending on your specified “source” input).
% 
% USAGE: argo = get_argo(adir, source, locn, t0, tf, latr, lonr, del);
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
%   argo = structure containing:
%       time (UTC / Matlab format)
%       lat (N), long (E)
%       depth (m)
%       T (C) [size time x depth]
%       S (PSU) [size time x depth]
%       units
%       info (information about floats / data)
%       calib (calibration information and equations)
%
% Useful links:
%   US FTP site: 
%       ftp://www.usgodae.org/pub/outgoing/argo/
%       (note: “geo” folder sorts by basin; “dac" sorts by data assembly centre)
%   Manual US data selection tool:
%       https://www.usgodae.org//cgi-bin/argo_select.pl
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: September 2019
%--------------------------------------------------------------------------

%Set default values if some not specified
	if nargin < 8
		del = 0; %option to not delete files after data extracted
	end

%Set ftp download prefix based on source and location
	if strcmp(source,'eu')
		pref = 'ftp://ftp.ifremer.fr/ifremer/argo/geo/';
	elseif strcmp(source,'us')
		pref = 'ftp://www.usgodae.org/pub/outgoing/argo/geo/';
	else
		error('You must specify a valid FTP data source (''eu'' or ''us'')!')
	end

	if strcmp(locn,'pac')
		pref = [pref,'pacific_ocean/'];
    elseif strcmp(locn,'atl')
		pref = [pref,'atlantic_ocean/'];
    elseif strcmp(locn,'ind')
		pref = [pref,'indian_ocean/'];
	else
		error('You must specify a valid ocean region (''pac'', ''atl'' or ''ind'')!')
	end

%Make list of files to download based on specified time ranges
%Write names to text file
	cd(adir);	
	
	%times 	
	tt = t0:tf;
	yy = datestr(tt,'yyyy');
	mm = datestr(tt,'mm');
	dd = datestr(tt,'dd');

	%file to which urls are written
	fid = fopen('argo_urls.txt','wt');

	for kk = 1:numel(tt)
		fname(kk,:) = [pref,yy(kk,:),'/',mm(kk,:),'/',yy(kk,:),mm(kk,:),dd(kk,:),'_prof.nc'];
		
		fprintf(fid,'%s\n',fname(kk,:));
	end
	clear tt yy mm dd
	
	fclose(fid);

%Download files to adir, using wget
	%first, change system directory
		system(['cd ', adir, '\']); 
	%now download
		system(['wget -i ', 'argo_urls.txt']); 

	display(' ')
	display('Downloading complete!')
	display(' ')

%Extract data from files

	filz = dir('*.nc'); %all .nc files that were just downloaded / that are in directory
    
    %create variables to hold data
        argo.time = [];
        argo.lat = [];
        argo.lon = [];
        argo.dep = [];
        argo.T = [];
        argo.S = [];
        argo.units.time = 'Matlab format, UTC';
        argo.units.lat = '+ deg. N';
        argo.units.long = '+ deg. E';
        argo.units.dep = 'decibar';
        argo.units.T = 'C';
        argo.units.S = 'PSU';
        argo.info.platform_no = [];
        argo.info.project_name = [];
        argo.info.PI_name = [];
        argo.info.platform_type = [];
        argo.info.serial_no = [];
        argo.info.data_centre = [];
        argo.info.firmaware_virs = [];
        argo.info.sampling_scheme = [];
        argo.info.cycle_no = [];
        argo.info.direction = [];
        argo.calib.params = [];
        argo.calib.equn = [];
        argo.calib.coef = [];
        argo.calib.comment = [];
        argo.calib.date = [];
        
    %go through each file and extract relevant data
    for kk = 1:numel(filz);
        %don't load if file size is too small
        if filz(kk).bytes < 4500; continue; end
        
        %otherwise, load and get data w/in latr and lonr
        %time
            t = ncread(filz(kk).name,'JULD')+datenum(1950,01,01,0,0,0);
        %lat,long
            la = ncread(filz(kk).name,'LATITUDE');
            lo = ncread(filz(kk).name,'LONGITUDE');
        %depth/pressure
            z = ncread(filz(kk).name,'PRES_ADJUSTED'); %decibars
        %Temp
            T = ncread(filz(kk).name,'TEMP_ADJUSTED'); %C
        %Sal
            S = ncread(filz(kk).name,'PSAL_ADJUSTED'); %psu
        %Pad z, T and S with nans so that all profiles are same length
            T = [T; nan(6000-size(z,1), size(z,2))]; 
            S = [S; nan(6000-size(z,1), size(z,2))]; 
            z = [z; nan(6000-size(z,1), size(z,2))]; 

        %Other information about float
            plat = ncread(filz(kk).name,'PLATFORM_NUMBER')';
            proj = ncread(filz(kk).name,'PROJECT_NAME')';
            pi = ncread(filz(kk).name,'PI_NAME')';
            cyc = ncread(filz(kk).name,'CYCLE_NUMBER');
            di = ncread(filz(kk).name,'DIRECTION');
            pty = ncread(filz(kk).name,'PLATFORM_TYPE')';
            sn = ncread(filz(kk).name,'FLOAT_SERIAL_NO')';
            dc = ncread(filz(kk).name,'DATA_CENTRE')';
            firm = ncread(filz(kk).name,'FIRMWARE_VERSION')';
            sch = ncread(filz(kk).name,'VERTICAL_SAMPLING_SCHEME')';
            calib_para = squeeze(ncread(filz(kk).name,'PARAMETER'));
            calib_equn = squeeze(ncread(filz(kk).name,'SCIENTIFIC_CALIB_EQUATION'));
            calib_coef = squeeze(ncread(filz(kk).name,'SCIENTIFIC_CALIB_COEFFICIENT'));
            calib_cmnt = squeeze(ncread(filz(kk).name,'SCIENTIFIC_CALIB_COMMENT'));
            calib_date = squeeze(ncread(filz(kk).name,'SCIENTIFIC_CALIB_DATE'));
            
        %data/info within lat / long ranges
            laloi = find(la >= latr(1) & la <= latr(2) & lo >= lonr(1) & lo <= lonr(2));
            
            argo.time = [argo.time; t(laloi)];
            argo.lat = [argo.lat; la(laloi)];
            argo.lon = [argo.lon; lo(laloi)];
            argo.dep = [argo.dep; z(1:6000,laloi)'];
            argo.T = [argo.T; T(1:6000,laloi)'];
            argo.S = [argo.S; S(1:6000,laloi)'];
            
            argo.info.platform_no = [argo.info.platform_no; plat(laloi,:)];
            argo.info.project_name = [argo.info.project_name; proj(laloi,:)];
            argo.info.PI_name = [argo.info.PI_name; pi(laloi,:)];
            argo.info.platform_type = [argo.info.platform_type; pty(laloi,:)];
            argo.info.serial_no = [argo.info.serial_no; sn(laloi,:)];
            argo.info.data_centre = [argo.info.data_centre; dc(laloi,:)];
            argo.info.firmaware_virs = [argo.info.firmaware_virs; firm(laloi,:)];
            argo.info.sampling_scheme = [argo.info.sampling_scheme; sch(laloi,:)];
            argo.info.cycle_no = [argo.info.cycle_no; cyc(laloi)];
            argo.info.direction = [argo.info.direction; di(laloi)];
            
            argo.calib.params = cat(3,argo.calib.params,permute(calib_para(:,1:3,laloi),[2,1,3]));
            argo.calib.equn = cat(3,argo.calib.equn, permute(calib_equn(:,1:3,laloi),[2,1,3]));
            argo.calib.coef = cat(3,argo.calib.coef, permute(calib_coef(:,1:3,laloi),[2,1,3]));
            argo.calib.comment = cat(3,argo.calib.comment, permute(calib_cmnt(:,1:3,laloi),[2,1,3]));
            argo.calib.date = cat(3,argo.calib.date, permute(calib_date(:,1:3,laloi),[2,1,3]));
            
            clear laloi t la lo z T S ...
                plat proj pi pty sn dc firm sch cyc dir ...
                calib_para calib_equn calib_coef calib_cmnt calib_date
    end    
	
%Remove some extra NaNs at bottom of T,S,z matrices
    maxi = nan(size(argo.time));
    keep = [];
    for aa = 1:length(argo.time);
        if ~all(isnan(argo.dep(aa,:)))
            maxi(aa) = find(~isnan(argo.dep(aa,:)),1,'last');
            keep = [keep, aa]; %exclude profiles with no data
        else
            
        end 
    end
    maxi = nanmax(maxi);
    argo.dep = argo.dep(keep,1:maxi);
    argo.T = argo.T(keep,1:maxi);
    argo.S = argo.S(keep,1:maxi);
    argo.time = argo.time(keep);
    argo.lat = argo.lat(keep);
    argo.lon = argo.lon(keep);
    fds = fields(argo.info);
    for ff = 1:numel(fds)
        argo.info.(fds{ff}) = argo.info.(fds{ff})(keep,:);
    end
    fds = fields(argo.calib);
    for ff = 1:numel(fds)
        argo.calib.(fds{ff}) = argo.calib.(fds{ff})(:,:,keep);
    end
    clear maxi aa keep fds ff
    
%Delete files from HDD if specified
    if del
        %CD to adir (folder containing downloaded .nc files)
        cd(adir)

        %Open file with list of ulrs & get names of files
            fid = fopen('argo_urls.txt'); 
            C = textscan(fid,'%s'); C = C{1};
            fclose(fid); clear fid

        % Go through each file and delete
            for bb = 1:numel(C)
                fn = C{bb}; fn = fn(end-15:end); %get just the filename section of the string
                delete(fn)
            end

        % Remove text file
            tf = dir('*.txt');
            delete(tf.name);

            cd(adir);
    end
    
return
