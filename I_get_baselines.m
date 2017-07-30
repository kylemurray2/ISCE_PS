%Make all pairs relative to a master in ISCE to get offsets
set_params
!rm baseline.txt tmp.baseline
dates(id).bp=0;
for i=[1:id-1 id+1:ndates] %make all relative to date "id"
   command=['baseline.py -m ' dates(id).name ' -s ' dates(i).name ' > tmp.baseline'];
   system(command);
    !grep Baseline tmp.baseline | awk '{print $4}' > baseline.txt
    load 'baseline.txt'
    dates(i).bp=baseline;
end
!rm baseline.txt tmp.baseline

save(ts_paramfile,'dates');