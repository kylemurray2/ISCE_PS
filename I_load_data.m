set_params
load(ts_paramfile)

switch sat
    case {'ENVI','ERS'}
        uname = 'rlohman';
        passw = 'starfish';
    case {'ALOS' , 'S1A'}
        %make cookies file
        %EOSDIS password info
        uname = 'rlohman';
        passw = 'Rolohman1';
        
end
parfor ii=1:length(dn)
    tic
    I_parraw(ii,sat,searchresults,dn,sortdn,uname,passw)
    toc
end

