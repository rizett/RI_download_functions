function ccmp_delete(wdir,fname)

%----------------------------------------------------------------------------
%%% ABOUT %%
% This functions deletes downloaded ccmp .nc files (specified in fname)
% from the wdir.
% 
% USAGE: ccmp_delete(wdir,fname)
% 
% INPUT:
%     wdir = direcotry containing files
%     fname = filename of txt file containing all of the download urls
% 
% OUTPUT:
%     check your wdir directory ;) (there won't be files!)
% 
% R. Izett (rizett{at}eoas.ubc.ca)
% UBC Oceanography
% Last modified: July 2019
%--------------------------------------------------------------------------

%--- CD to temporary folder created in sat_fnames()
    %This folder contains the .txt file (with the list of downloaded files) and
    %the downloaded .nc files. 
    cd(wdir)

%--- Open file with list of ulrs
    fid = fopen(fname); 

%--- Open file with list of ulrs
    C = textscan(fid,'%s'); C = C{1};
    
%--- Close file
    fclose(fid); clear fid
    
%--- Go through each file and delete
    for bb = 1:numel(C)
        fn = C{bb}; fn = fn(44:end); %get just the filename section of the string
        delete(fn)
    end
    
%--- Remove text file
    tf = dir('*.txt');
    delete(tf.name);
    