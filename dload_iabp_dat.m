function dload_iabp_dat(ndir,t0,tf,reg);

%--------------------------------------------------------------------------------------------------
% Download the data from the International Arctic Buoy 
% Program within a specified time frame
% 
% USAGE: dload_iabp_dat(ndir,t0,tf,reg);
%   e.g. dload_iabp_dat('C:\Users\user\Desktop\Data\IABP',datenum(2019,01,01),datenum(2019,10,01),'A');
%
% INPUT:
%   ndir = directory where data will be downlaoded.
%   t0, tf = datenum of start and end dates
%   reg = region; 'A' = Arctic (default), 'AA' = Antarctic
% 
% OUTPUT:
%   check your directory ;) (there will be files!)
% 
% Links:
%   IABP: 
%       http://iabp.apl.washington.edu/data.html
%   Original FTP source (daily files):
%       http://iabp.apl.washington.edu/Data_Products/Daily_Full_Res_Data/
% 
% Data Reference & Citation:
%   
% Script Reference:
%   R. Izett
%   rizett@eoas.ubc.ca
%   UBC Oceanography
%   Last modified: Apr. 2020
%--------------------------------------------------------------------------------------------------

if nargin < 4
    reg = 'A';
end

cd(ndir)
    
%Make time array
    tarr = floor(t0):ceil(tf);
    tarr = datestr(tarr,'yyyymmdd');
    
%Make list of data files to download
    fid = fopen('iabp_files.txt','wt');
    %Arctic
    if reg == 'A'
        %e.g. 'http://iabp.apl.washington.edu/Data_Products/Daily_Full_Res_Data/Arctic/FR_20200318.dat'
        for kk = 1:length(tarr)
            fprintf(fid,'%s\n',['http://iabp.apl.washington.edu/Data_Products/Daily_Full_Res_Data/Arctic/FR_',tarr(kk,:),'.dat']);
        end
    else
    %Antarctic
        %e.g. http://iabp.apl.washington.edu/Data_Products/Daily_Full_Res_Data/Antarctic/FR_20120310.dat        
        for kk = 1:length(tarr)
            fprintf(fid,'%s\n',['http://iabp.apl.washington.edu/Data_Products/Daily_Full_Res_Data/Antarctic/FR_',tarr(kk,:),'.dat']);
        end
    end
    fclose(fid);

%download the data through command line using wget
    %first, change system directory
        system(['cd ', '\']); 
    %now download
        system(['wget -i ', 'iabp_files.txt']); 
    
%Delete list of files 
    delete('iabp_files.txt')

display(' ')
display('*********************')
display(['IABP data downloaded!'])
display('*********************')
