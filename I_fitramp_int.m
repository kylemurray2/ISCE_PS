% function fitramp(thresh,edge,waterheight,topoflag,boxedge,degree)%boxedge and edge must be defined in full res units
%degree:  0=just offset, 1=planar ramp, 2=quadratic
thresh      = 2; %this currently needs to be "big" for the first round, then iterate once or twice with smaller values.
edge       = [100 100 10 10]; %pixels from left, right, top, bottom edges to mask
waterheight = [-10]; %mask all pixels with height < waterheight.
topoflag    = [];
boxedge     = [];%[2437 2636 1357 1582]*4;
degree=1;
%topoflag can be 0 because no trees.   if topoflag is set, the ramp
%includes topo
set_params
% load('watermask');
if topoflag==1
    degree=2;
    disp('Using quadratic because topoflag is set')
end
oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '-' dates(ints(intid).i2).name '/'];

if(isempty(edge))
    edge=[0 0 0 0]; %offset from left, right, top bottom
end
if(isempty(waterheight))
    waterheight=-3000;
end
if(isempty(boxedge))
    boxedge=[0 0 0 0];
end

fullresheightfile=[dates(id).dir 'geom/z.rdr'];

for l=1:length(rlooks)
    %     ratefile=['rates_' num2str(rlooks(l))];
    %     if(exist(ratefile))
    %         disp('removing rate file as well in ramp fit')
    %         userate = 1;
    %         fidrate = fopen(ratefile,'r');
    %         tmp     = fread(fidrate,[newnx(l),newny(l)],'real*4');
    %         ratemap = tmp'*lambda*(4*pi)/1000/365;%conver rate back to radians/day
    %         fclose(fidrate);
    %     else
    %         userate =0;
    %     end
    userate=0; %realized that after first iteration, will introduce whatever ramp is in rate file
    [X,Y]=meshgrid(1:newnx(l),1:newny(l));
    
    
%mask out ocean
    oldintdir = [masterdir 'int_' dates(ints(intid).i1).name '-' dates(ints(intid).i2).name '/'];
            lookheightfile=[dates(id).dir '/geom/z_' num2str(rlooks(1)) 'rlks.rdr'];

                if(~exist(lookheightfile))
                    command=['looks.py -i ' fullresheightfile ' -o ' lookheightfile ' -r ' num2str(rlooks(l)) ' -a ' num2str(rlooks(l)*pixel_ratio)];
                    mysys(command);
                end

        fiddem  = fopen(lookheightfile,'r');
        tmp     = fread(fiddem,[newnx,newny*2],'real*4');
        dem     = tmp(:,2:2:end)';
        fclose(fiddem);
%         watermask=watermask';

%     figure;subplot(1,3,1);imagesc(mask);title('mask')
 
%     fiddem  = fopen(lookheightfile,'r','native');
%     tmp     = fread(fiddem,[newnx,newny*2],'real*4');
%     dem     = tmp(:,2:2:end)';
%     fclose(fiddem);
    
    fidmask = fopen(['res_' num2str(rlooks(l))],'r');
    tmp     = fread(fidmask,[newnx(l),newny(l)],'real*4');
    stdmask = tmp';
    stdmask(stdmask>thresh)=NaN;
    fclose(fidmask);
    
    id1=floor(edge(1)/rlooks(l));
    id2=floor(edge(2)/rlooks(l));
    id3=floor(edge(3)/alooks(l));
    id4=floor(edge(4)/alooks(l));
    alooks(l);
    
    edgemask = ones(size(stdmask));
    edgemask(:,1:1+id1)=NaN; %mask left
    edgemask(:,end-id2:end)=NaN; %mask right
    edgemask(1:1+id3,:)=NaN; %mask top
    edgemask(end-id4:end,:)=NaN; %mask bottom
    
    id1=ceil(boxedge(1)/rlooks(l));
    id2=floor(boxedge(2)/rlooks(l));
    id3=ceil(boxedge(3)/alooks(l));
    id4=floor(boxedge(4)/alooks(l));
    
%     boxmask = ones(size(stdmask));
%     boxmask(:,1:id1)=NaN; %mask left
%     boxmask(:,id2:end)=NaN; %mask right
%     boxmask(1:1+id3,:)=NaN; %mask top
%     boxmask(id4:end,:)=NaN; %mask bottom
    
%     boxmask=isnan(boxmask); %reverse sense of boxmask

% watermask=double(watermask);
% watermask(watermask==0)=NaN;

watermask=dem;
watermask(watermask<waterheight)=NaN;
%add all together
    mask = isfinite(stdmask+edgemask+watermask);%+boxmask);
    disp([sum(isfinite(stdmask(:))) sum(isfinite(edgemask(:))) sum(isfinite(watermask(:))) ]);%sum(isfinite(boxmask(:)))])
    disp([num2str(sum(mask(:))/newnx(l)/newny(l)*100) '% points left after masking'])
    
    figure
    imagesc((mask))
    title('Mask')
    print('-dpng','figs/rampmask.png')
    
    
    %invert for ramp with remaining points
    Xg = X(mask);
    Yg = Y(mask);
    switch degree
        case 0 %just offset
            G = [ones(sum(mask(:)),1)];  %left out dem because of kansas examples, would be near-flat
        case 1 %planar ramp
            G  = [ones(sum(mask(:)),1) Xg Yg dem(mask)];
        case 2 %quadratic
            G  = [ones(sum(mask(:)),1) Xg Yg Xg.*Yg Xg.^2 Yg.^2 dem(mask)];
    end
    Gg = inv(G'*G)*G';
    
    
    for i=1:nints
        fid = fopen(ints(i).unwrlk{l},'r');
        tmp = fread(fid,[newnx(l),newny(l)*2],'real*4');
        fclose(fid);
        phs   = tmp(:,2:2:end)';
        zid   = phs==0; %find id of points=0
        %remove rate if exists
        if(userate)
            avgrate   = ints(i).dt*rate;
            phs       = phs-avgrate;
        end
        
        mod   = Gg*phs(mask);
        
        switch degree
            case 0 %just offset
                synth = mod(1);
            case 1 %planar ramp
                synth = mod(1)+mod(2)*X+mod(3)*Y;
            case 2 %quadratic
                synth = mod(1)+mod(2)*X+mod(3)*Y+mod(4)*X.*Y+mod(5)*X.^2+mod(6)*Y.^2;
        end
               
        if(topoflag)
            synth = synth+mod(7)*dem;
        end
        res   = phs-synth;
        if(userate)
            res = res+avgrate; %puts avg rate back in
        end
        
        res(isnan(watermask+edgemask))=0;
        res(zid)=0; %this keeps anything set exactly at zero from being "deramped"
        tmp(:,2:2:end) = res';
        tmp(isnan(tmp))=0;
        %write flatenned unw file to output.
       if(~exist([ints(i).unwrlk{l} '_old']))
          movefile(ints(i).unwrlk{l},[ints(i).unwrlk{l} '_old']);
       end
        
        %move the _old files back
%         for i=1:nints
%         movefile([ints(i).unwrlk{l} '_old'],[ints(i).unwrlk{l}]);    
%         end
%         
        if(topoflag)
            outfile=[ints(i).unwrlk{l} '_topo.unw'];
        else
             outfile=ints(i).unwrlk{l};
        end
        fid=fopen(outfile,'w');
        fwrite(fid,tmp,'real*4');
        fclose(fid);
        
    end
end

%plot the original, ramp, and removed 
figure
subplot(1,3,1)
imagesc(phs);title('example original interferogram');colorbar;axis image
subplot(1,3,2)
imagesc(synth);title('example ramp');colorbar;axis image
subplot(1,3,3)
imagesc(phs-synth);title('example ramp removed interferogram');colorbar;axis image

save(ts_paramfile,'dates','ints');

