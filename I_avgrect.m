set_params

im=sqrt(-1);

fidout=fopen(avgslcfile,'w','native');
disp('stacking slc magnitudes')
for i=1:ndates
    fidin(i)=fopen(dates(i).rectslc,'r','native');
end

for j=1:ny
    band1=zeros(nx,ndates);
    for i=1:ndates
        [tmp,count]=fread(fidin(i),nx*2,'real*4');
        if(count==nx*2)
            rl=tmp(1:2:end);
            ig=tmp(2:2:end);
            cpx=rl+im*ig;
            amp=abs(cpx);
            band1(:,i)=amp/dates(i).ampmed;
        end
    end
    band1(isnan(band1))=0;
    good = sum(band1>0,2);
    mag  = sum(band1,2)./good;
    mag(isnan(mag))=0;
    m2   = band1-repmat(mag,1,ndates);
    mstd = sum(m2.^2,2)./good;
    mstd(isnan(mstd))=0;
    
    fwrite(fidout,mag,'real*4');
end

for i=1:ndates
    fclose(fidin(i));
end
fclose(fidout);


%% Plot the avgrect file
fid  = fopen('TS/avgslc.r4','r','native');
[rmg,count] = fread(fid,[nx,ny],'real*4');
status = fclose(fid);
%downlook by taking every 10th pixel
phs = (rmg(1:10:nx,1:10:ny))';

figure
imagesc(phs,[0 5])
colorbar
title('Average of SLCs')
kylestyle


