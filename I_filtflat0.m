function I_filtflat0(ii,rx,ry)
set_params
    tmp=dir(ints(ii).int); %is output from diffnsim with phase+amp, we just want phase.
    if(tmp.bytes==nx*ny*4)
        disp([ints(ii).flat ' already split to one band'])
    elseif(tmp.bytes==nx*ny*8)
        disp(['splitting ' ints(ii).int ' into just phs'])
        command=['cpx2mag_phs ' ints(ii).int ' mag phs ' num2str(nx)];
        mysys(command);
        command=['mv phs ' ints(ii).int];
        mysys(command);
    else
        disp([ints(ii).flat ' wrong size?'])
        return 
    end
%         filter_diff(ints(ii).flat,[ints(ii).flat '_filtrate'],[ints(ii).flat '_filt'],[ints(ii).flat '_diff'],[ints(ii).flat 'raterem'], nx,ny,rx,ry);
 filter_diff(ints(ii).flat,[ints(ii).flat '_filt'],[ints(ii).flat '_diff'], nx,ny,rx,ry);