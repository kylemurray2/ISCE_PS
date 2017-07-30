set_params

%make all ints
for ii=1:nints
    mslc=dates(ints(ii).i1).rectslc;
    sslc=dates(ints(ii).i2).rectslc;
    int=ints(ii).int;
    system(['imageMath.py -e=''a*conj(b)'' --a=' mslc ' --b=' sslc ' -o ' int ' -t CFLOAT'])
end
%Save amplitude files
!mkdir -p TS/int/amplitudes
for ii=1:nints
    mslc=dates(ints(ii).i1).rectslc;
    sslc=dates(ints(ii).i2).rectslc;
    ampout=[intdir 'amplitudes/' dates(ints(ii).i1).name '-' dates(ints(ii).i2).name '.amp'];
    system(['imageMath.py -e=''abs(a);abs(b)'' --a=' mslc ' --b=' sslc ' -o ' ampout ' -t FLOAT -s BIP'])
end

%downlook master int to get .xml and .vrt
    system(['looks.py -i ' ints(id).int ' -a 8 -r 4 -o TS/int/int4.int']);

