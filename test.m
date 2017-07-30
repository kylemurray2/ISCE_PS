if ~exist([dates(id).name '/geom'],'dir')
system(['mkdir ' dates(id).name '/geom'])
system(['topo.py -m ' dates(id).name ' -d ' dem ' -o ' dates(id).name '/geom'])
else
    display('Looks like there is already a geom directory in the master date directory :/');
    return
end
a=5;