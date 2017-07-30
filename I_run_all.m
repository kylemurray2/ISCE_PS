clear all;close all

%% These definitions can be changed________________________________________
    track=218;
    frame=700;
    sat='ALOS';
    id=2;
    mkdir('figs')
    masterdir = [pwd '/'];

%% Forming Interferograms__________________________________________________

    [dn,footprints,searchresults,sortresults,sortdn,apiCall]=search_data(track,frame,sat,1,[]);   
%     [dn,searchresults,sortdn,sortresults]=I_subset([1:3],dn,searchresults,sortdn,sortresults); %do only these date ids     
    I_write_paramfile(sat,masterdir,id,footprints,1,2,track,frame); %writes set_params.m, which you can edit.
    init_dirs;                                %initializes timeseries directories
    I_make_dates_struct(sortdn,sortresults);    %makes dates structure, stores in ts_params.mat
    load_data;   %After: Check to see if each dir now has data files  
    I_make_slcs %Make raw and SLCs
%     I_crop_slcs %Optional crop
    I_get_baselines
    I_rectify %uses native doppler. should experiment with zero doppler
%     I_calamp %could use imageMath.py for these steps?
%     I_avgrect
    I_choose_ints %add or remove pairs in set_params
%     I_run_insarapp_alos(2,1,'startup','coherence') % "help I_run_insarapp_alos" for info
    I_make_ints % makes all ints. currently copies xml files.. may be unecessary

%% Gamma0 and mask_________________________________________________________
    I_FilterFlat(0) % 0 is first iteration
    I_CalcGamma
    I_FilterFlat(1) % 1 is subsequent iteration
    I_CalcGamma
    I_make_mask(3)

%% Downlooks and unwrap____________________________________________________
    I_smart_rlooks  %buffers could make this faster.  Lots of I/O
    I_filtAndCor(.1) % argument: filter strength
    I_crop_edges([10*4 10*4 10*8 320*8]) %full res location of crop (so that it works for multiple rlooks, left right, top, bottom.
    I_unwrap_rlooks(2) % argument: 1 to unwrap flat ints, 2 to unwrap filtered. could change to just use filtered
%     unw2png_km1(2,10,15) %(mode,wraprate,scale%) make a .png image of each unw_4lks in TS/looks4/png_files/

%% Making a time series____________________________________________________
    I_invert_dates(0); %1 looks for .unw_topo.unw files (not made til fitramp_int), 0 looks for normal unw files. 
    %%%this generates TS/looks#/date.r4 files and res#.  Res# will have a ramp if not alligned. Choose thresh accordingly
        thresh      = 3; %this currently needs to be "big" for the first round, then iterate once or twice with smaller values.
        edge       = [10 10 20 200]; %pixels from left, right, top, bottom edges to mask
        waterheight = [-10]; %mask all pixels with height < waterheight.
        topoflag    = [];
        boxedge     = [];%[2437 2636 1357 1582]*4;
    I_fitramp_int(thresh,edge,waterheight,topoflag,boxedge,1);  %topoflag=1 removes topo and writes to *_topo.unw files, 0 is normal. Now uses rates file, if it exists!
    I_unwrap_rlooks(2);
    I_invert_dates(0);
    I_invert_rates;
    I_geocode_ts;