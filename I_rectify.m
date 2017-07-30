%Kyle Murray; April, 2017
%Gets DEM
%Refines master timing
%Calculates offsets between master and slaves
%read pages 7-8 in isce2stamps manual

clear all;close all
set_params

master=dates(id).name;
%     system(['mv ' master ' master']);
% master='master';
if strcmp(doppler_type,'n')
    dop_type='-n';
    display('using native doppler')
else
    dop_type='';
    display('using zero doppler')

end

%Get DEM___________________________________________________________________
if ~exist('final_dem','file')
chdir('DEM');
bounds=num2str([floor(min([frames.lat])-1) ceil(max([frames.lat])+1) floor(min([frames.lon])-1) ceil(max([frames.lon])+1)]);
system(['dem.py -a stitch -b ' bounds ' -r -s 1 -c -f -o final_dem']);
chdir(masterdir);
!ln -s DEM/final_dem* ./
!fixImageXml.py -i final_dem -f
else
    display('DEM already exists.')
end
dem='./final_dem'%[masterdir 'DEM/final_dem'];



  %First run simulated amplitude
    system(['mkdir -p' dates(id).dir '/geom_timing/original'])
    system(['cp ' dates(id).dir 'data.* ' dates(id).dir 'geom_timing/original/'])              
    system(['topo.py -m ' master ' -d ' dem ' -o ' master '/geom_timing -a 1 -r 1 ' dop_type])
  %compute slc power image
    system(['imageMath.py -e=''abs(a)*abs(a)'' --a=' master '/' master '.slc -o ' master '/geom_timing/' master '.pow -t FLOAT -s BIP']);
    system(['fixImageXml.py -i ' master '/geom_timing/' master '.pow -f']);
  %compute amplitude again
    system(['imageMath.py -e=''sqrt(a)'' --a=' master '/geom_timing/' master '.pow -o ' master '/geom_timing/' master '.amp -t FLOAT -s BIP']);
    system(['rm ' master '/geom_timing/' master '.pow']);
    system(['cp ' master '/data.* ' master '/geom_timing/.']);
   
    %renames master date to 'master', updates shelf, then renames is back
   %_________________________________
        system(['mv ' master ' master']);
        system(['update_shelf_file.py']);
        system(['mv master ' master]);
    %_______________________________


%For platforms with less reliable timing, refine the master timing. ALOS?__
if sum(strcmp(sat,{'ERS','ENVI'}))
    system(['refineMasterTiming.py -m ' master '/geom_timing -g ' master '/geom_timing']);
%         system(['mv ' master ' master']);

    system(['update_master_sensingTime.py']);
%     system(['mv master ' master]);

else
    display('Platform is reliable or already a geom_timing directory in the master date directory. Skipping to simulated amplitude.');
end

%Find coarse offsets_______________________________________________________
if ~exist([master '/geom/simamp.rdr'],'file')
system(['mkdir ' master '/geom'])
system(['topo.py -m ' master ' -d ' dem ' -o ' master '/geom ' dop_type])
else
    display('Already a geom directory with simamp.rdr in the master date directory. Skipping to coarse offsets');
end


for ii=[1:id-1 id+1:ndates] %make all relative to date "id"
    if ~exist([dates(ii).name '/coreg_coarse/azimuth.off'],'file')
    system(['mkdir ' dates(ii).name '/coreg_coarse'])
    system(['geo2rdr.py -m ' master ' -s ' dates(ii).name ' -g ' master '/geom -o ' dates(ii).name '/coreg_coarse ' dop_type]);
else
    display(['Already a coreg_coarse directory with offsets in ' dates(ii).name '. Skipping to coarse coregistration']);
    end
end

%check that the master/geom/simamp.rdr is the same as master/yyyymmdd.slc.
%Also check the sizes of the coreg_coarse files are consistent. 

%Rectify the slcs (coarse)_________________________________________________
for ii=[1:id-1 id+1:ndates] %make all relative to date "id"
    if ~exist([dates(ii).name '/coreg_coarse/coreg.slc'],'file')
%     system(['fixImageXml.py -i '  [masterdir dates(ii).name] '/..raw.slc -b']);
%     system(['ln ' [masterdir dates(ii).name] '/..raw.sl* ./']);
    system(['resampleSlc.py -s ' [masterdir dates(ii).name] ' -o ' [masterdir dates(ii).name] '/coreg_coarse -f ' [masterdir dates(ii).name] '/coreg_coarse'])
    else
    display(['Already a coregistered slc in ' dates(ii).name '. Skipping to fine offsets.']);
    end
end

%Find fine offsets_________________________________________________________
    %ERS and ENVI have less accurate timing, so use a bigger window size
    if sum(strcmp(sat,{'ERS','ENVI'}))
        window_str=['ww 32 --wh 156 --sww 16 --swh 22'];
    else
        window_str=[];
    end
    
offset_degree=[];
for ii=[1:id-1 id+1:ndates] %make all relative to date "id"
%         if ~exist([dates(ii).name '/coreg_fine'],'file')
        system(['mkdir ' dates(ii).name '/coreg_fine'])
        system(['refineSlaveTiming.py -m ' master '/' master '.slc -s ' dates(ii).name '/coreg_coarse/coreg.slc -o ' dates(ii).name '/coreg_fine/fine_shift -t 10.0 ' window_str]);
%     else
    display(['Already a coreg_fine directory in ' dates(ii).name '. Skipping to fine coregistration']);
%         end
end
%Rectify the slcs (fine)___________________________________________________
for ii=[1:id-1 id+1:ndates] %make all relative to date "id"
%         if ~exist([dates(ii).name '/coreg_fine/coreg.slc'],'file')
    system(['geo2rdr.py -m ' master ' -s ' dates(ii).name ' -g ' master '/geom -o ' dates(ii).name '/coreg_fine -p ' dates(ii).name '/coreg_fine/fine_shift ' dop_type]);
    system(['resampleSlc.py -s ' dates(ii).name ' -o ' dates(ii).name '/coreg_fine -f ' dates(ii).name '/coreg_fine']);
%         else
    display(['Already a fine coregistered slc in ' dates(ii).name '. Nothing left to do here.']);
%         end
end

%Add rectified paths to dates structure
for ii=1:ndates
    if ii==id
    dates(ii).rectslc=[dates(ii).dir dates(ii).name '.slc'];
    else
    dates(ii).rectslc=[dates(ii).dir 'coreg_fine/coreg.slc'];
    end
end
    if(exist('ints','var'))
        save(ts_paramfile,'dates','ints');
    else
        save(ts_paramfile,'dates');
    end