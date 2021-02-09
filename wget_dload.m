function wget_dload(wdir,fname,usr_name,pwd);

%--------------------------------------------------------------------------
% Download files specified in fname using wget. 
% 
% USAGE: wget_dload(wdir,fnames);
% 
% INPUT:
% wdir = directory where to save filenames (string)
% fname = name of text file (include full directory string if not in wdir)
% usr_name = (optional) username 
% pwd = (optional) password
% 
% OUTPUT:
% check your wdir directory ;) (there will be files!)
% 
% R. Izett
% UBC Oceanography
% Last modified: Dec. 2020
%--------------------------------------------------------------------------

cd([wdir]); %cd to temp folder

%download the data through command line using wget
        %first, change the directory where files will be downloaded to
        if ispc; %IF PC
            system(['cd ', wdir, '\']); 
        else %IF MAC
            %Do not use system command to cd. The system(wget) command
            %(below) will download files to the current Matlab directory 
            current = cd;
            cd(wdir);
        end
        
        %Now, Download
        % OPTION 1: download all ftp urls in a .txt file using -i command
            if ~exist('usr_name','var')
                system(['wget -i ', fname]); 
            else
                system(['wget --user=' usr_name, ' --password=', pwd, ...
                ' --auth-no-challenge=on ',...
                '-i ' fname]);    
            end
            
        % OPTION 2: download all urls in a .txt file using -c command
        % to use -c, the wget command must be run separately on each line
        % of the .txt file
        % Use -c to "continue" downloading files, or to download files
        % that do not currently exist in the cd. IF the file exists, the file will
        % not be downloaded again.
%             fid=fopen(fname,'rt');
%             all_url=textscan(fid,'%s\n','headerlines',0,'collectoutput',1); all_url=all_url{1};
%             fclose(fid);
%             
%             for uu = 1:numel(all_url)
%                 system(['wget -c ' all_url{uu}]);
%             end
        
%Download complete
    display(' ');
    display('*****************');
    display('Download complete');
    display('*****************');
    display(' ');
    
return
