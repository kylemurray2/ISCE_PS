function I_FilterFlat(iter)
%iter=0 first iteration 
%iter=1 next iteration
set_params

im           = sqrt(-1);
rx           = 5; %should perhaps be set in set_params instead
ry           = rx*pixel_ratio;

if(iter)
    display('Using TS/gamma0.r4 file for a subsequent iteration')
    for i=1:nints
            system(['rm ' ints(i).flat '_filt ' ints(i).flat '_diff']);
            filter_diff_iter(ints(i).int,[ints(i).flat '_filt'],[ints(i).flat '_diff'], nx,ny,rx,ry,gammafile,1.5);
            snapnow;
    end   
        !mv TS/gamma0.r4 TS/gamma0_orig.r4

else
        display('Doing first iteration')

    for i=1:nints
        if(exist([ints(i).flat '_filt']))
            disp(['skipping ' ints(i).name]);
        else
            tmp=dir(ints(i).int); %is output from diffnsim with phase+amp, we just want phase.
            if(tmp.bytes==nx*ny*4)
                disp([ints(i).int ' already split to one band'])
            elseif(tmp.bytes==nx*ny*8)
                disp(['splitting ' ints(i).int ' into just phs'])
                command=['cpx2mag_phs ' ints(i).int ' mag phs ' num2str(nx)];
                mysys(command);
                command=['mv phs ' ints(i).flat];
                mysys(command);
            else
                disp([ints(i).int ' wrong size?'])
                return 
            end
                filter_diff(ints(i).int,[ints(i).flat '_filt'],[ints(i).flat '_diff'], nx,ny,rx,ry);
        end
    end
end