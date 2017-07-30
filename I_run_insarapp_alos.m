function I_run_insarapp_alos(run_mode,run_app,start_step,end_step)
%__________________________________________________________________________
%Kyle Murray; April 2017
%Sets up directories, xml files, and runs insarApp for ALOS
%
%  I_run_insarapp_alos(run_mode, run_app, start_step, end_step)
%
%     run_mode=1: make all small baseline ints.
%     run_mode=2: make only master int.
%     run_mode=3: make all ints relative to master date.
%
%     run_app=0: don't run insar_app. just creates the directories and .xml files
%     run_app=1: creates directories, .xml files, and runs insar_app for each.
%
% The step names are chosen from the following list:
% ['startup', 'preprocess', 'verifyDEM', 'pulsetiming', 'estimateHeights']
% ['mocompath', 'orbit2sch', 'updatepreprocinfo', 'formslc', 'offsetprf']
% ['outliers1', 'prepareresamps', 'resamp', 'resamp_image', 'mocompbaseline']
% ['settopoint1', 'topo', 'shadecpx2rg', 'rgoffset', 'rg_outliers2']
% ['resamp_only', 'settopoint2', 'correct', 'coherence', 'filter']
% ['mask', 'unwrap', 'unwrap2stage', 'geocode', 'endup']
%
% insarApp.py output is saved in file insarApp.log in the int_date1_date2
% directory.
%__________________________________________________________________________

set_params

switch run_mode
    case 1
        display('making all small baseline ints')
    looparray=1:nints;
    case 2
        display('making only master int')
    looparray=intid;

for ii=looparray
        system(['mkdir int_' ints(ii).name]);
        masterint=['./int_' ints(ii).name];
        fid=fopen([masterint '/' ints(ii).name '.xml'],'w');

    if strcmp(sat,'ALOS')
        [p,m_image]=system(['ls ' dates(ints(ii).i1).name '/IMG-HH*']);
        [p,m_leader]=system(['ls ' dates(ints(ii).i1).name '/LED*']);
        [p,s_image]=system(['ls ' dates(ints(ii).i2).name '/IMG-HH*']);
        [p,s_leader]=system(['ls ' dates(ints(ii).i2).name '/LED*']);

        fprintf(fid,'<insarApp>\n');
        fprintf(fid,'   <component name="insar">\n');
        fprintf(fid,'        <property  name="Sensor name">ALOS</property>\n');
        fprintf(fid,'        <component name="master">\n');
        fprintf(fid,['            <property name="IMAGEFILE">../' m_image '</property>\n']);
        fprintf(fid,['            <property name="LEADERFILE">../' m_leader '</property>\n']);
        fprintf(fid,['            <property name="OUTPUT">' dates(ints(ii).i1).name '.raw</property>\n']);
            types=dir([dates(ints(ii).i1).dir 'IMG*HV*']); %Check to see if this is FBD or FBS
                if(~isempty(types))
                    fprintf(fid,['<property name="RESAMPLE_FLAG"><value>dual2single</value></property>\n']);
                end
        fprintf(fid,'        </component>\n');
        fprintf(fid,'        <component name="slave">\n');
        fprintf(fid,['            <property name="IMAGEFILE">../' s_image '</property>\n']);
        fprintf(fid,['           <property name="LEADERFILE">../' s_leader '</property>\n']);
        fprintf(fid,['           <property name="OUTPUT">' dates(ints(ii).i2).name '.raw</property>\n']);
            types=dir([dates(ints(ii).i2).dir 'IMG*HV*']); %Check to see if this is FBD or FBS
                if(~isempty(types))
                    fprintf(fid,['<property name="RESAMPLE_FLAG"><value>dual2single</value></property>\n']);
                end
        fprintf(fid,'       </component>\n');
        fprintf(fid,'   </component>\n');
        fprintf(fid,'</insarApp>\n');
        fclose(fid)
    end

    %Run insarApp.py if run_app flag is set
    if run_app~=0
        chdir(masterint)
        system(['insarApp.py ' ints(ii).name '.xml --steps start=' start_step ' end=' end_step ' > insarApp.log &'])
        chdir(masterdir)
    end
end

    %all ints relative to master
    case 3
        display('making all ints relative to master')
            for ii=[1:id-1 id+1:ndates] %make all relative to date "id"
                system(['mkdir int_' dates(id).name '_' dates(ii).name]);
                int=['./int_' dates(id).name '_' dates(ii).name];
                fid=fopen([int '/' int '.xml'],'w');

            if strcmp(sat,'ALOS')
                [p,m_image]=system(['ls ' dates(id).name '/IMG-HH*']);
                [p,m_leader]=system(['ls ' dates(id).name '/LED*']);
                [p,s_image]=system(['ls ' dates(ii).name '/IMG-HH*']);
                [p,s_leader]=system(['ls ' dates(ii).name '/LED*']);

                fprintf(fid,'<insarApp>\n');
                fprintf(fid,'   <component name="insar">\n');
                fprintf(fid,'        <property  name="Sensor name">ALOS</property>\n');
                fprintf(fid,'        <component name="master">\n');
                fprintf(fid,['            <property name="IMAGEFILE">../' m_image '</property>\n']);
                fprintf(fid,['            <property name="LEADERFILE">../' m_leader '</property>\n']);
                fprintf(fid,['            <property name="OUTPUT">' dates(id).name '.raw</property>\n']);
                    types=dir([dates(id).dir 'IMG*HV*']); %Check to see if this is FBD or FBS
                    if(~isempty(types))
                        fprintf(fid,['<property name="RESAMPLE_FLAG"><value>dual2single</value></property>\n']);
                    end
                fprintf(fid,'        </component>\n');
                fprintf(fid,'        <component name="slave">\n');
                fprintf(fid,['            <property name="IMAGEFILE">../' s_image '</property>\n']);
                fprintf(fid,['           <property name="LEADERFILE">../' s_leader '</property>\n']);
                fprintf(fid,['           <property name="OUTPUT">' dates(ii).name '.raw</property>\n']);
                    types=dir([dates(ii).dir 'IMG*HV*']); %Check to see if this is FBD or FBS
                    if(~isempty(types))
                        fprintf(fid,['<property name="RESAMPLE_FLAG"><value>dual2single</value></property>\n']);
                    end
                fprintf(fid,'       </component>\n');
                fprintf(fid,'   </component>\n');
                fprintf(fid,'</insarApp>\n');
                fclose(fid)
            end

            %Run insarApp.py if run_app flag is set
            if run_app~=0
                chdir(masterint)
                system(['insarApp.py ' int '.xml --steps start=' step_start ' end=' step_end ' > insarApp.log &'])
                chdir(masterdir)
            end
            end
end