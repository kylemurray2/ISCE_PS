function invert_dates(topoflag)
% topoflag=0;
%0 looks for unwrlk{l}, 1 adds _topo.unw to name.
set_params

[G,Gg,R,N]=build_Gint;
[m,n]=size(Gg);

for l=1:length(rlooks)    
    for i=1:nints
        if(topoflag)
            infile=[ints(i).unwrlk{l} '_topo.unw'];
        else
            infile=[ints(i).unwrlk{l}];
        end
        if(~exist(infile))
            disp([infile ' does not exist'])
            return
        end
           mysys(['rmg2mag_phs ' infile ' mag phs ' num2str(newnx)])
           fidi(i)=fopen('phs','r');
           !rm phs
%         fidi(i)=fopen(infile,'r');
    end
    for i=1:ndates
       
        fido(i)=fopen(dates(i).unwrlk{l},'w');
    end
    fido2=fopen(['res_' num2str(rlooks(l))],'w');

    
    
    for j=1:newny(l)
        tmpdat=zeros(n,newnx(l)); %data for n-nints = zeros
        for i=1:nints

            jnk         = fread(fidi(i),newnx(l),'real*4');
            tmpdat(i,1:length(jnk))=jnk;
        end
       
        mod    = Gg*tmpdat;
        synth  = G*mod;
        res    = tmpdat-synth;
        resstd = std(res,1);
        fwrite(fido2,resstd,'real*4');
        for i=1:ndates
            fwrite(fido(i),mod(i,:),'real*4');
        end
    end
    fclose('all');
end
