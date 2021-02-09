function ccmp_dload(wdir,fname);

%----------------------------------------------------------------------------
%%% ABOUT %%
% This function downloads the a list of CCMP wind files using the wget 
% extensions. The list of files (wind_files.txt) is saved to a specified 
% directory (wdir) using the function ccmp_fnames (or it can be created 
% manually).
% 
% USAGE: ccmp_dload(wdir,fname);
% 
% BEFORE RUNNING, please ensure that you have downloaded wget.exe and 
% moved it to your C:/Windows/System32 directory. Restart Matlab after 
% doing this for the first time. 
% 
% INPUT:
%     wdir = directory where text file containing filenames is saved; also where 
%         data will be downloaded to
%     fname = name of text file (ccmp_files.txt)
% 
% OUTPUT:
%     Check your wdir directory ;) (there will be files!)
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: July 2019
%--------------------------------------------------------------------------

%--- CD to temporary folder created in sat_fnames()
    %This folder contains the .txt file with the list of files to be downloaded
    %and is the folder to which files will be downloaded
    cd(wdir);
    
%--- Check to see if any of the files already exist
    % List of files to be downloaded
    fid = fopen(fname);
    C = textscan(fid,'%s'); C = C{1};
    fclose(fid);
    
    % List of file names already downloaded / in download folder
    filz = dir([wdir,'\*.nc']);
    rm = []; %filenames / urls to be removed from original list, if they have already been downloaded
    
    % Check if listed files have already been downloaded; 
    % Modify list of files to download, if necessary
    if ~isempty(filz)
        for kk = 1:numel(filz)
            fn(kk,:) = filz(kk).name;
            fd(kk) = filz(kk).datenum;
        end
        %Check if file already exists
        for kk = 1:numel(filz)
           si = strfind(C,fn(kk,:));
           for ss = 1:numel(si)
               if ~isempty(si{ss})
                   rm = [rm ss];
               end
           end
           clear ss si
        end
    end
    
    % Remove files that have already been read    
    C2 = C; %new list of files to download
    C2(rm,:) = [];
    fname_dload = 'wind_files_dload.txt';
    fid = fopen(fname_dload,'wt');
    
    % New list of files to download
    for kk = 1:numel(C2)
        fprintf(fid,'%s\n',C2{kk,:});
    end
    fclose(fid);    

%--- Download the data through command line using wget
    %first, change system directory
        system(['cd ', wdir, '\']); 
    %now download
        system(['wget -i ', fname_dload]); 
