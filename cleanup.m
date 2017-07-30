function cleanup(rm_mode)
%Kyle Murray; April, 2017
% Remove various files created in time series processing
% cleanup(mode)
%     mode 1: delete ALPS*.zip files
%     mode 2: delete IMG and LED files
%     mode 3: delete raw and slcs
%     mode 4: delete geom and coreg directories in dates directories
%     mode 5: delete full res ints
%     mode 6: delete full res flat, filt, diff ints
%     mode 7: delete flat rlks
%     mode 8: delete unw rlks

set_params

switch rm_mode
    case 1
        display('removing .zip files from each date directory')
        for ii=1:ndates
            system(['rm -r ' dates(ii).dir '*.zip']);
        end

    case 2
        display('removing IMG, LED, and VOL files from each date directory')
        for ii=1:ndates
            system(['rm -r ' dates(ii).dir 'IMG*']);
            system(['rm -r ' dates(ii).dir 'LED*']);
            system(['rm -r ' dates(ii).dir 'VOL*']);
        end
        
    case 3
        display('removing .slc and .raw files from each date directory')
        for ii=1:ndates
            system(['rm -r ' dates(ii).dir '*slc*']);
            system(['rm -r ' dates(ii).dir '*raw*']);
        end
        
    case 4
        display('removing geom and coreg files from each date directory')
        for ii=1:ndates
            system(['rm -r ' dates(ii).dir 'geom*']);
            system(['rm -r ' dates(ii).dir 'coreg*']);
        end
        
    case 5
        display('removing full res ints')
        for ii=1:nints
            system(['rm -r ' ints(ii).int]);
        end
        
    case 6
        display('removing full res flat, filt, diff ints')
            system(['rm -r ' intdir 'flat*']);
            
    case 7
        display('removing flat rlks')
        for ii=1:nints
            system(['rm -r ' ints(ii).flatrlk{1}]);
        end
        
    case 8
        display('removing unw rlks')
        for ii=1:nints
            system(['rm -r ' ints(ii).unwrlk{1}]);
        end
end

