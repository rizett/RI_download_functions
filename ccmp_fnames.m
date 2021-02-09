function [fname,filz] = ccmp_fnames(wdir,sdate,edate,file)

%----------------------------------------------------------------------------
%%% ABOUT %%
% This functions creates a list of CCMP wind speed files files for download 
% from http://www.remss.com/measurements/ccmp/. The list of files 
% (wind_files.txt) is saved to a specified directory (wdir). 
% 
% USAGE: 
%     [fname,filz] = ccmp_fnames(wdir,sdate,edate,file);
% 
% INPUT:
%     wdir = parent directory of where to save filenames .txt file
%     sdate, edate = start and end dates (matlab date format)
%     file = file type; daily ('day'; individual files for each day 
%        between sdate and edate) or monthly ('mon'; average monthly files
%        between sdate and edate)
%        default = 'day';
% 
% OUTPUT:
%     fname = file name containing list of files (sat_fnames.txt)
%     filz = list of files (string array)
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: Apr. 2020
%--------------------------------------------------------------------------

%--- Set default file type if not specfied
    if nargin == 3;
        warning('File type not specified. Set to ''day''');
        file = 'day';
    end

%--- CD to download directory
    cd(wdir);

%--- Create list of files to download
    %NOTE: the filename / url format:
    %DAILY files:
    %   CCMP_Wind_Analysis_yyyymmdd_V02.0_L3.0_RSS.nc
    %   http://data.remss.com/ccmp/v02.0/Yyyyy/Mmm/CCMP_Wind_Analysis_yyyymmdd_V02.0_L3.0_RSS.nc
    %   NEW:
    %   http://data.remss.com/ccmp/v02.0.NRT/Yyyyy/Mmm/CCMP_RT_Wind_Analysis_yyyymmdd_V02.0_L3.0_RSS.nc
    %MONTHLY files:
    %   CCMP_Wind_Analysis_yyyymm_V02.0_L3.5_RSS.nc
    %   http://data.remss.com/ccmp/v02.0/Yyyyy/Mmm/CCMP_Wind_Analysis_yyyymm_V02.0_L3.5_RSS.nc
    
    %--- Create array of dates from sdate to edate
        dates = sdate:edate;
      
    %--- Open .txt file to hold list of files to download
        %delete existing file (if there is one)
        if ~isempty(dir('wind_files.txt')); delete('wind_files.txt'); end
        fid = fopen('wind_files.txt','wt');
        
    %--- Create filenames
        if strcmp(file,'day')
            for kk = 1:numel(dates)
               yr = datestr(dates(kk),'yyyy');
               mo = datestr(dates(kk),'mm');
               da = datestr(dates(kk),'dd');

%                fil = strcat(['CCMP_Wind_Analysis_',yr,mo,da,'_V02.0_L3.0_RSS.nc']); %specific filename
                if str2num(yr) >= 2017
                    fil = strcat(['CCMP_RT_Wind_Analysis_',yr,mo,da,'_V02.0_L3.0_RSS.nc']); %specific filename
                else
                    fil = strcat(['CCMP_RT_Wind_Analysis_',yr,mo,da,'_V02.1_L3.0_RSS.nc']); %specific filename
                end
%                filz(kk,:) = strcat('http://data.remss.com/ccmp/v02.0/Y',yr,'/M',mo,'/',fil); %download url
               filz(kk,:) = strcat('http://data.remss.com/ccmp/v02.0.NRT/Y',yr,'/M',mo,'/',fil); %download url

               %--- wirte files to text file
               fprintf(fid,'%s\n',filz(kk,:));

            end
        else
            yrmon = unique(str2num(datestr(dates,'yyyymm'))); %all unique year/month combinations
            for kk = 1:numel(yrmon)
                yr = num2str(yrmon(kk)); yr = yr(1:4);
                mo = num2str(yrmon(kk)); mo = mo(5:6);
                
                if str2num(yr) >= 2017
                    fil = strcat(['CCMP_Wind_Analysis_',yr,mo,'_V02.0_L3.5_RSS.nc']); %specific filename
                else
                    fil = strcat(['CCMP_Wind_Analysis_',yr,mo,'_V02.1_L3.5_RSS.nc']); %specific filename
                end
                filz(kk,:) = strcat('http://data.remss.com/ccmp/v02.0/Y',yr,'/M',mo,'/',fil); %download url

                %--- wirte files to text file
                fprintf(fid,'%s\n',filz(kk,:));
            end
            
        end            

    %--- close file
    fclose(fid);
    
fname = 'wind_files.txt';
                
end 