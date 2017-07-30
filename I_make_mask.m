function I_make_mask(thresh)
% thresh=3;
set_params


fidin  = fopen(gammafile,'r','native');
fidout = fopen(maskfile,'w','native');

for i=1:ny
    tmp=fread(fidin,nx,'real*4');
    out=tmp<thresh;
    fwrite(fidout,out,'integer*1');
end
fclose(fidin);
fclose(fidout);


for l=1:length(rlooks)
    fidin  = fopen(maskfile,'r','native');
    fidout = fopen(maskfilerlk{l},'w');
    for i=1:newny(l)
        tmp=zeros(nx,alooks(l));
        [jnk,count]=fread(fidin,[nx alooks(l)],'integer*1');
        tmp(1:count)=jnk;
        tmp = sum(tmp,2); %sum along alooks dir
        
        tmp = reshape(tmp(1:rlooks(l)*newnx(l)),rlooks(l),newnx(l));
        tmp = sum(tmp,1); %sum along rlooks dir
        
        tmp=tmp/rlooks(l)/alooks(l);
        tmp(tmp<.25)=0;
        fwrite(fidout,tmp,'real*4');
    end
    fclose(fidin);
    fclose(fidout);
    system(['mag_phs2rmg ' maskfilerlk{l} ' ' maskfilerlk{l} ' ' rlkdir{l} 'mask.cor ' num2str(newnx(l))]);
end

fid=fopen('TS/gamma0.r4','r','native');
mm=fread(fid,[nx,ny],'real*4')';
figure;imagesc(mm);
% a=zeros(size(mm));
% [ii,jj]=find(mm==10);
% for i=ii
%     for j=jj
%     a(i,j)=1;
%     end
% end

