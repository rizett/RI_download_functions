function [mdate,lat,long,wind,wspd]=ccmp_wind(wdir,fname,latr,lonr,file);

%----------------------------------------------------------------------------
%%% ABOUT %%
% This function extracts the time, lat, long, and wind speed (m/s) info 
% from downloaded ccmp .nc files. Files were downloaded using the
% ccmp_dload() function
% 
% USAGE: [t,lat,long,wind]=ccmp_wind(wdir,fname,latr,lonr,file);
% 
% INPUT:
%     wdir = parent directory of where to save filenames .txt file
%     fname = filename of txt file containing all of the download urls
%     latr/lonr = lat/long ranges ([min max]) 
%         NOTE: longitude = deg E 
%     file = file type; daily ('day'; individual files for each day 
%        between sdate and edate) or monthly ('mon'; average monthly files
%        between sdate and edate)
%        default = 'day';
% 
% OUTPUT:
%     mdate = array of matlab times
%     lat, long = lat/long arrays
%     wind = data matrix (size: mdate x lat x long) 
%       units: m/s 
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: June 2020
%--------------------------------------------------------------------------


%--- Set default file type if not specfied
    if nargin == 4;
        warning('File type not specified. Set to ''day''');
        file = 'day';
    end
    
%--- CD to temporary folder created in sat_fnames()
    %This folder contains the .txt file (with the list of downloaded files) and
    %the downloaded .nc files. 
    cd(wdir);

%--- Open file with list of ulrs
    fid = fopen(fname); 

%--- Extract the list of files
    C = textscan(fid,'%s'); C = C{1};
    
%--- Close file
    fclose(fid); clear fid

%--- Dumby variable to hold date
    mdate = [];
   
%--- Go through each url and extract data
    for jj = 1:numel(C)
        fn = C{jj}; fn = fn(48:end); %file name 

        %extract date info
            yy = str2num(fn(23:26));
            mm = str2num(fn(27:28));
            dd = str2num(fn(29:30));

            if strcmp(file,'day') %one-day files                
                tt=ncread(fn,'time'); tt=tt-tt(1); %tt is the hours at which observations are made (e.g. obs. at 0hr, 64h, 12hr, 18hr of the day)
                mdate=[mdate; datenum(yy,mm,dd,tt,0,0)]; %exact time from file
            else %multi-day filess
                mdate=[mdate; datenum(yy,mm,1)]; 
                tt = 1;
            end

        %extract data
        %get lat/long (first iteration only)
            if jj == 1
                lat = ncread(fn,'latitude');
                long = ncread(fn,'longitude');
                
                %Adjust long E/W
                    li = find(long>180);
                    long(li) = long(li)-360;
                    clear li

                %Find lat / long data within specified latr / lonr
                la = find(lat >= latr(1) & lat <= latr(2)); %find data within lat range
                lo = find(long >= lonr(1) & long <= lonr(2)); %find data within long range

                lat = double(lat(la));
                long = double(long(lo));
            end
        
        %u and v components of wind w/in specified latr / lonr
            uwnd=ncread(fn,'uwnd',[lo(1), la(1), 1], [length(lo), length(la), Inf]);
            vwnd=ncread(fn,'vwnd',[lo(1), la(1), 1], [length(lo), length(la), Inf]);
            uwnd = permute(uwnd,[3,2,1]);
            vwnd = permute(vwnd,[3,2,1]);
            
        %calculate wind direction
            [th,r] = cart2pol(uwnd,vwnd);
            th = th .* 180 ./ pi;
            th = th + 90;
            th(th<0) = th(th<0) + 360;
            this_dir = th;
            clear th r

        %get net wind speed from each time observations
            %this_spd will be size 4 x lat x long (4obs per day) for file
            %type 'day' and will be 1 x lat x long for file type 'mon'
            for kk = 1:numel(tt)
               this_u = squeeze(uwnd(kk,:,:));
               this_v = squeeze(vwnd(kk,:,:)); 

               this_spd(kk,:,:) = sqrt(this_u.^2 + this_v.^2);

            end

        %combine all data
        if jj == 1;
            wind = this_spd;
            wspd = this_dir;
        else 
            wind = [wind;this_spd]; %stack wind speed data
            wspd = [wspd;this_dir];
        end

        clear yy mm dd fn tt kk uwnd vwnd this_u this_v this_spd ccmp ans this_dir

        display([num2str(jj) '/' num2str(numel(C)) ' complete.']);
    end
    
display(' ');
display('Data extracted');
end