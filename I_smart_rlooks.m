set_params

fid1=fopen(gammafile,'r');
im=sqrt(-1);
thresh=2;

for l=1:length(rlooks)
    for k=1:nints
        if(~exist(ints(k).flatrlk{1},'file'));
            fid2    = fopen(ints(k).flat,'r');
            fid3    = fopen(ints(k).flatrlk{1},'w');
            fid4    = fopen([ints(k).flatrlk{1} '.cor'],'w');
            fid5    = fopen(maskfilerlk{l},'r');
            for j=1:newny(l)
                gamma = NaN(alooks(l),nx);
                int   = zeros(alooks(l),nx);
                mask  = zeros(1,newnx(l));
                
                for i=1:alooks(l)
                    tmp=fread(fid1,nx,'real*4'); 
                    gamma(i,1:length(tmp))=tmp;
            
                    tmp=fread(fid2,nx,'real*4');
                    int(i,1:length(tmp))=exp(im*tmp);
                end
                               
                gamma(isnan(gamma))=1000;
                
                %read old mask file (downlooked)
                tmp  = fread(fid5,newnx(l),'real*4');
                mask(1:length(tmp))=tmp;
                
                cor = zeros(1,newnx(l));
                for i=1:newnx(l)
                    ids    = (i-1)*rlooks(l)+[1:rlooks(l)]; % defines size of block (actually array) to average
                    tempi  = int(:,ids);
                    phs    = angle(tempi);
                    
                    tempm  = gamma(:,ids);
                    tempm  = 1./tempm;
                    tempm(isnan(tempm))=0;
                    
                    
                    goodid = find((phs~=0) & (isfinite(phs)));
                    if(length(goodid)>1)
                        cor(i) = abs(sum(tempi(goodid)))/length(goodid);
                        meani  = mean(tempi(goodid).*tempm(goodid)); %this weights each block using gamma0 (0 to 1)
                        fwrite(fid3,[real(meani) imag(meani)],'real*4');
                        fwrite(fid4,cor(i),'real*4');
                    else
                        cor(i) = 0;
                        fwrite(fid3,[0 0],'real*4');
                        fwrite(fid4,[0],'real*4');
                    end
                end
                cor(cor<.75)=0;
                fwrite(fid4,max(cor,mask),'real*4');
            end
            fclose(fid2);
            fclose(fid3);
            fclose(fid4);
            fclose(fid5);
            frewind(fid1);
        else
            disp(['skipping ' ints(k).name]);
        end
    end
end
fclose(fid1);

%cp xml files from original ints
chdir(rlkdir{1})
for i=1:nints
    system(['cp ' intdir 'int4.int.xml ' ints(i).flatrlk{1} '.xml'])    
    system(['fixImageXml.py -i ' ints(i).flatrlk{1} ' -f'])

    
    system(['cp ' intdir 'int4.int.vrt ' ints(i).flatrlk{1} '.vrt'])    
    system(['fixImageXml.py -i ' ints(i).flatrlk{1} ' -f'])

end
chdir(masterdir)