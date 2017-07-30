%make raw and slc files with ISCE
%Kyle Murray; April, 2017

set_params

parfor i=1:ndates
    %     chdir(dates(i).dir)
    if(~exist([dates(i).dir dates(i).name '.raw']))
        switch sat
            case 'ERS'
                system(['unpackFrame_ERS_raw.py -i ' dates(i).dir ' -o ' dates(i).name]);
            case 'ENVI'
                system(['unpackFrame_ENV_raw.py -i ' dates(i).dir ' -o ' dates(i).name]);
            case 'ALOS'
                
                types=dir([dates(i).dir 'IMG*HV*']); %Check to see if this is FBD or FBS
                if(isempty(types))
                    system(['unpackFrame_ALOS_raw.py -i ' dates(i).dir ' -o ' dates(i).name ' -m']) ;
                else
                    display('resampling FBD2FBS')
                    system(['unpackFrame_ALOS_raw.py -i ' dates(i).dir ' -o ' dates(i).name ' -m -r']) ;
                    %-r option will do FBD2FBS (resample)
                end
        end
    else
        disp(['raw already exists'])
    end
end
% chdir(masterdir);

parfor i=1:ndates
    %     chdir(dates(i).dir)
    if(~exist([dates(i).name '.slc']))
        system(['focus.py -i ' dates(i).dir]);
    else
        disp(['slc already exists'])
    end
end
% chdir(masterdir);

%append length and width of master slc to set_params file__________________
% chdir(dates(id).name)
[jnk,width]= system(['get_width_isce.py ' dates(id).dir dates(id).name '.slc']);
[jnk,length]= system(['get_length_isce.py ' dates(id).dir dates(id).name '.slc']);
width=str2num(width);
length=str2num(length);

chdir(masterdir)
file=[masterdir 'set_params.m'];fid=fopen(file,'a+')
fprintf(fid,['ny = ' num2str(length) ';\n'])
fprintf(fid,['nx = ' num2str(width) ';\n'])
fprintf(fid,['newny = ' num2str(length/(rlooks*pixel_ratio)) ';\n'])
fprintf(fid,['newnx = ' num2str(width/rlooks) ';\n'])
clear length width
%__________________________________________________________________________


