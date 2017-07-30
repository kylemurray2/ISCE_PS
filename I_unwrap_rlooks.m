function I_unwrap_rlooks(ftype)
%ftype=1: unwrap the flat rlks ints
%ftype=2: unwrap the filtered rlks ints

set_params

switch ftype
    case 1
    for k=1:nints     
        if(~exist(ints(k).unwrlk{1},'file'))
            command=['snaphu -s ' ints(k).flatrlk{1} ' ' num2str(newnx(1)) ' -o ' ints(k).unwrlk{1} ' -c ' rlkdir{1} 'mask.cor  --tile 6 6 100 100'];
            mysys(command);
        else
           display([ints(k).unwrlk{1} ' already exists'])
        end
    end


    case 2
    for k=1:nints     
        if(~exist(ints(k).filtunwrlk,'file'))
            command=['snaphu -s ' ints(k).filtrlk ' ' num2str(newnx(1)) ' -o ' ints(k).filtunwrlk ' -c ' rlkdir{1} 'mask.cor  --tile 6 6 100 100'];
            mysys(command);
        else
           display([ints(k).filtunwrlk ' already exists'])
        end
    end
end

% cp xml files from original ints
% display('copying xml and vrt files, changing lxw, and file type')
% chdir(rlkdir{1})
% for i=1:nints
%     system(['cp ' ints(i).int '.xml ' ints(i).unwrlk{1} '.xml']) ;   
%     system(['fixImageXml.py -i ' ints(i).unwrlk{1} ' -f']);
% 
%     system(['sed -i -- ''s/CFLOAT/FLOAT/g'' *.xml']);
% end
% chdir(masterdir)