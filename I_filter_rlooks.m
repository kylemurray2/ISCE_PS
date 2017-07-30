function I_filtAndCor(filter_strength)

% filter int
% unwrap filtered int
% subtract unwrapped from filtered int - this should give you just near-integers *2pi (it won't be exact, though)
% add 2pi*n field to unfiltered int.

set_params
load(ts_paramfile);

ndates  = length(dates);
nints   = length(ints);


for i=1:nints
    ints(i).filtrlk= [rlkdir{1} 'filt_flat_' ints(i).name '_' num2str(rlooks) 'rlks.int'];
    ints(i).filtunwrlk= [rlkdir{1} 'filt_flat_' ints(i).name '_' num2str(rlooks) 'rlks.unw'];
    ints(i).filtunwrlkcor= [rlkdir{1} 'flat' ints(i).name '_' num2str(rlooks) 'rlks.cor'];
    in=ints(i).flatrlk{1};
%         if ~exist([rlkdir{1} 'originals'],'dir')
%             system(['mkdir -p ' rlkdir{1} 'originals']);
%             mysys(['cp ' in ' orig_' in])
%             !mv orig* originals/
%         end
    out=[ints(i).filtrlk];
    cor=ints(i).filtunwrlkcor;
    command=['FilterAndCoherence.py -i ' in ' -f ' out ' -c ' cor ' -s ' num2str(filter_strength)];
    mysys(command); 
end

save(ts_paramfile,'ints','dates')


%Now unwrap the filtered ints
% for l=1:1%length(rlooks)
%     for k=1:nints     
% %         if(~exist(ints(k).unwrlk{1},'file'))
%             command=['snaphu -s ' ints(k).filtrlk ' ' num2str(newnx(l)) ' -o ' ints(k).unwrlk{1} ' -c ' rlkdir{l} 'mask.cor  --tile 6 6 100 100'];
%             mysys(command);
% %         end
%     end
% end

%now load in the filtered int and the filtered unwrapped int and difference
%them to get 2pi*integer
