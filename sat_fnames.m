function [fname,filz] = sat_fnames(wdir,sdate,edate,type,res,tres)

%----------------------------------------------------------------------------
%%% ABOUT %%
% This functions creates a list of files for download from NASA's Ocean Color 
% Level 3 browser (https://oceancolor.gsfc.nasa.gov/l3/). The list of files 
% (sat_files.txt) is saved to a specified directory (wdir). 
% 
% USAGE: 
%     sat_fnames(wdir,sdate,edate,type,res,tres);
% 
% INPUT:
%     wdir = parent directory of where to save filenames .txt file
%     sdate, edate = start and end dates (matlab date format)
%     type = string specifying data you wish to download; one of: 
%           'cal','chl','sst','nsst','aer', 'par' (calcite, chl-a, day-time SST,
%           night-time SST, aerosol optical thickness or PAR respectively)
%           *More options to come in subsequent release*
%     res = spatial resolution; one of:
%           9 or 4 (9km or 4 km respectively)
%           DEFAULT = 9 if empty or unspecified
%     tres = temporal resoltion; one of:
%           'day','3day','8day','mon' (daily, 3-day rolling, 8-day,
%           monthly respectively)
% 
% OUTPUT:
%     fname = file name containing list of files (sat_files.txt)
%     filz = list of files (string array)
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: July 2019
%--------------------------------------------------------------------------

%--- Error messages 
    if sdate > datenum(date)-1 | edate > datenum(date)-1
        error('Date range not possible. Please specify date range PRIOR to today''s date.');
    elseif str2num(datestr(sdate,'yyyy')) ~= str2num(datestr(edate,'yyyy'))
        error('Date range not possible. Please specify date range within a single year. Re-do download for each unique year.');
    elseif sdate > edate
        error('Date range not possible. Please specify sdate < edate.')
    elseif ~exist('type','var')
        error('Please specify a valid data type: ''cal'', ''chl'', ''sst'', ''nsst'', ''aer'', or ''par''');
    elseif ~any(strcmp(type,{'cal'; 'chl'; 'sst'; 'nsst'; 'aer'; 'par'}))
        error('Please specify a valid data type: ''cal'', ''chl'', ''sst'', ''nsst'', ''aer'', or ''par''');
    elseif ~exist('res','var')
        error('Please specify a valid spatial resolution: 4 or 9');
    elseif (res ~=4 & res~=9) | isempty(res)
        error('Please specify a valid spatial resolution: 4 or 9');
    elseif ~exist('tres','var')
        error('Please specify a valid temporal resolution: ''day'',''3day'',''8day'',''mon''');
    elseif ~any(strcmp(tres,{'day';'3day';'8day';'mon'}))
        error('Please specify a valid temporal resolution: ''day'',''3day'',''8day'',''mon''');
    elseif sdate < datenum(1997,09,04) | edate < datenum(1997,09,04)
        error('Sorry, the current functions are written only for the SeaWiFS (4 Sept, 1997 - 11 Dec, 2010) and MODIS-Aqua (4 July, 2002 - present) eras. Please select a valid date range.')        
    end 

%--- Additional warnings
    if res == 4 & sdate <= datenum(2002,07,04)
        warning('4km-resolution data is not available during the SeaWiFS era.');
        warning('Please indicate whether you would like to:');
        warning('   Continue with current date range and adjust the resolution to 9 km (1)');
        warning('   Stop and adjust your input parameters (2)');
        sel = input('Enter 1 or 2: ');
        if sel == 1; res = 9; 
        elseif (sel ~=1 & sel ~=2); warning('Invalid option; ending function'); fname = []; filz = []; return;
        else; fname = []; filz = []; return; end
    end
    if strcmp(tres,'3day') & sdate <= datenum(2002,07,04)
        warning('3-day rolling quick view is not available during the SeaWiFS era');
        warning('Please indicate whether you would like to:');
        warning('   Continue with current date range and adjust the resolution to 1-day (1)');
        warning('   Stop and adjust your input parameters (2)');
        sel = input('Enter 1 or 2: ');
        if sel == 1; tres = 'day'; 
        elseif (sel ~=1 & sel ~=2); warning('Invalid option; ending function'); fname = []; filz = []; return;
        else; fname = []; filz = []; return; end
    end
    if strcmp(tres,'3day') & strcmp(type,'cal');
        warning('3-day rolling quick view is not available for type ''cal''');
        warning('Please indicate whether you would like to:');
        warning('   Continue with type and adjust the resolution to 1-day (1)');
        warning('   Stop and adjust your input parameters (2)');
        sel = input('Enter 1 or 2: ');
        if sel == 1; tres = 'day'; 
        elseif (sel ~=1 & sel ~=2); warning('Invalid option; ending function'); fname = []; filz = []; return;
        else; fname = []; filz = []; return; end
    end
    if strcmp(tres,'3day') & strcmp(type,'aer');
        warning('3-day rolling quick view is not available for type ''aer''');
        warning('Please indicate whether you would like to:');
        warning('   Continue with type and adjust the resolution to 1-day (1)');
        warning('   Stop and adjust your input parameters (2)');
        sel = input('Enter 1 or 2: ');
        if sel == 1; tres = 'day'; 
        elseif (sel ~=1 & sel ~=2); warning('Invalid option; ending function'); fname = []; filz = []; return;
        else; fname = []; filz = []; return; end
    end
    if strcmp(tres,'3day') & strcmp(type,'par');
        warning('3-day rolling quick view is not available for type ''par''');
        warning('Please indicate whether you would like to:');
        warning('   Continue with type and adjust the resolution to 1-day (1)');
        warning('   Stop and adjust your input parameters (2)');
        sel = input('Enter 1 or 2: ');
        if sel == 1; tres = 'day'; 
        elseif (sel ~=1 & sel ~=2); warning('Invalid option; ending function'); fname = []; filz = []; return;
        else; fname = []; filz = []; return; end
    end            

%--- CD to download direcotry; make temporary folder to hold data
    cd(wdir);
    mkdir('sat_temp'); %create temporary folder within parent directory
    if ispc
        cd([wdir '\sat_temp']); %cd to it
    else
        cd([wdir '/sat_temp']); %cd to it
    end
    
%--- Create parts of download urls 
    %Based on specified date range, data type and resolutions.
%     prefix = 'https://oceandata.sci.gsfc.nasa.gov/cgi/getfile/';
    prefix = 'https://oceandata.sci.gsfc.nasa.gov/ob/getfile/';
    
    %MODIS-Aqua vs SEAWiFS
    if sdate > datenum(2012,01,02) %VIIRS
        sat{1} = 'V'; 
        sat{2} = 'SNPP';
        satl = 'VIIRS_SNPP';
    elseif sdate > datenum(2002,07,04) %MODIS-Aqua
        sat{1} = 'A';
        sat{2} = '';
        satl = 'MODIS_Aqua';
%         sat = 'AQUA_MODIS.';
    else %SEAWiFS
        sat{1} = 'S'; 
        sat{2} = '';
        satl = 'SEAWiFS';
    end
    
    %Tres extension and datestrings
    dates = sdate:edate;
    if strcmp(tres,'day');
%         tres_ext = '.L3m.DAY';
        tres_ext = '.L3m_DAY_';
        for kk = 1:numel(dates)
            yr = str2num(datestr(dates(kk),'yyyy')); %year
            jd = dates(kk)-datenum(yr,0,0); %julian days
            jd = sprintf('%03d',jd); 
            daterng(kk,:) = [num2str(yr),(jd)];
        end
        clear kk yr jd
        
    elseif strcmp(tres,'3day');
%         tres_ext = '.L3m_R3QL';   
        tres_ext = '.L3m_R3QL';
        for kk = 1:numel(dates)        
            yr = str2num(datestr(dates(kk),'yyyy')); %year
            jd = dates(kk)-datenum(yr,0,0); %julian days
            jd = sprintf('%03d',jd); 
            jd2 = sprintf('%03d',(str2num(jd)+2));
            daterng(kk,:) = [num2str(yr),jd,num2str(yr),jd2];
        end
        clear kk yr jd jd2
        
    elseif strcmp(tres,'8day');
%         tres_ext = '.L3m.8D';     
        tres_ext ='.L3m_8D';
        %https://oceandata.sci.gsfc.nasa.gov/cgi/getfile/A20021852002192.L3m_8D_CHL_chlor_a_9km.nc
        sdates = datenum(str2num(datestr(sdate,'yyyy')),0,1:8:366);
        sdates = sdates(find(sdates>=sdate & sdates<=edate));
        for kk = 1:numel(sdates)
            yr = str2num(datestr(sdates(kk),'yyyy')); %year
%             jd1 = sdates(kk)-datenum(yr,0,0); %julian days
%             jd1 = sprintf('%03d',jd1);
            jd1 = datestr(sdates(kk),'mmdd')
            jd2 = sdates(kk)+7-datenum(yr,0,0); %julian days
            jd2 = sprintf('%03d',jd2);
            jd2 = datestr(sdates(kk)+7,'mmdd')
%             %check if leap year
%                 if jd1>360;
%                     leap = datenum(yr,12,31)-datenum(yr,01,0);
%                     jd2 = num2str(leap);
%                 end
            daterng(kk,:) = [num2str(yr),jd1,'_',num2str(yr),jd2];
        end
        clear sdates kk yr jd1 jd2 leap
        
    elseif strcmp(tres,'mon');
        tres_ext = '.L3m_MO';        
        mons = unique(str2num(datestr(sdate:edate,'mm')));
        mons = [mons; mons(end)+1];
        for kk = 1:numel(mons)-1
            yr = str2num(datestr(sdate,'yyyy')); %year
            jd1 = datenum(yr,mons(kk),1) - datenum(yr,0,0); %julian days
            jd1 = sprintf('%03d',jd1);
            jd2 = datenum(yr,mons(kk+1),1) - datenum(yr,0,0)-1; %julian days
            jd2 = sprintf('%03d',jd2);
            daterng(kk,:) = [num2str(yr),jd1,num2str(yr),jd2];
        end
        clear mons kk yr jd1 jd2        
    end
    
    %Data type extension (including errors if data unavailable in SeaWiFS)
    if strcmp(type,'cal')
        type_ext = '_PIC_pic';        
    elseif strcmp(type,'chl')
        type_ext = '_CHL_chl_ocx';        
    elseif strcmp(type,'sst')
        if sdate <= datenum(2002,07,04)
            error('SST data is not available from the SEAWiFS era. Please select a date range > 4 July 2002.')
        else
            type_ext = '.SST.sst';
        end
    elseif strcmp(type,'nsst')
        if sdate <= datenum(2002,07,04)
            error('Sorry, NSST data is not available from the SEAWiFS era. Please select a date range > 4 July 2002.')
        else
            type_ext = '.NSST.sst';
        end        
    elseif strcmp(type,'aer')
        if sdate > datenum(2002,07,04)
            type_ext = '_RSS_aot_869'; %Aqua
        else
            type_ext = '_RSS_aot_865'; %SeaWiFS
        end        
    elseif strcmp(type,'par')
        if sdate <= datenum(2002,07,04)
            error('Sorry, PAR data is not available from the SEAWiFS era. Please select a date range > 4 July 2002.')
        else
            type_ext = '_PAR_par';
        end 
    end
    
    %Spatial resolution extension
    res_ext = ['_',num2str(res),'km'];
    
%--- Open .txt file to hold list of files to download
    fid = fopen('sat_files.txt','wt');    
    
%--- Combine url names and save to file list
    for kk = 1:size(daterng,1)
        filz(kk,:) = [prefix,sat{1},daterng(kk,:),tres_ext,sat{2},type_ext,res_ext,'.nc'];
        
        %wirte files to text file
        fprintf(fid,'%s\n',filz(kk,:));        
    end   

%--- Close file for holding download files
    fclose(fid);
    
fname = 'sat_files.txt';
    
display('** List of download files created **');
end 