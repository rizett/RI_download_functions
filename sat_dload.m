function sat_dload(wdir,fname,usr_name,pwd);

%----------------------------------------------------------------------------
%%% ABOUT %%
% This function downloads files from NASA's Ocean Color Level 3 browser 
% (https://oceancolor.gsfc.nasa.gov/l3/) using the wget extensions. The list 
% of files (sat_files.txt) is saved to a specified directory (wdir) using the
% function sat_fnames (or it can be created manually).
% 
% USAGE: sat_dload(wdir,fname);
% 
% BEFORE RUNNING, please ensure that you have downloaded wget.exe and 
% moved it to your C:/Windows/System32 directory. Restart Matlab after 
% doing this for the first time. 
% 
% ALSO BEFORE RUNNING: Create a NASA Earth Obs. user account at:
% https://urs.earthdata.nasa.gov/home
%
% INPUT:
%     wdir = directory where text file containing filenames is saved; also where 
%         data will be downloaded to
%     fname = name of text file (sat_files.txt)
%     usr_name = NASA username
%     pwd = NASA password
% 
% OUTPUT:
%     Check your wdir directory ;) (there will be files!)
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: Dec. 2020
%--------------------------------------------------------------------------

if nargin < 4
    error('Please specify username and password')
end

%--- CD to temporary folder created in sat_fnames()
    %This folder contains the .txt file with the list of files to be downloaded
    %and is the folder to which files will be downloaded
    cd([wdir '\sat_temp']);

%--- Warning if .nc files already exist in current folder
    x=dir('*.nc');
    if ~isempty(x)
        warning('wdir\sat_temp already contains .nc files. System will automatically rename downloaded files that already exist');
        sel = input('Do you wish to continue: yes (1) or no (2)? ');
        if sel == 2; return; end
    end
    
%--- Download the data through command line using wget
    %first, change system directory
	if ispc
        system(['cd ', wdir, '\sat_temp\']); 
	end
    %Download by passing username and password
	system(['wget --user=' usr_name, ' --password=', pwd, ...
        ' --auth-no-challenge=on ',...
        '-i ' fname]);     
    
end
    