function I_make_slcs
%Kyle Murray
%April 2017
%Makes the raw files and slcs with ISCE

set_params
load(ts_paramfile);
ndates=length(dates);

for i=1:ndates
    chdir(dates(i).dir)
    if(~exist('..raw'))
        switch sat
            
            case 'ERS'
                   !unpackFrame_ERS_raw.py -i ./ -o ./
            case 'ENVI'
                 !unpackFrame_ENV_raw.py -i ./ -o ./
            case 'ALOS'
                
                types=dir('IMG*HV*'); %Check to see if this is FBD or FBS
                if(isempty(types))
                    !unpackFrame_ALOS_raw.py -i ./ -o ./ 
                    !focus.py -i ./
                else
                    !unpackFrame_ALOS_raw.py -i ./ -o ./ -r 
                        %-r option will do FBD2FBS (resample)
                    !focus.py -i ./
                end
        end
    else
        disp(['..raw already exists'])
    end
end
chdir(masterdir);
