% #TAPAS/PhysIO -> SPM12 (https://github.com/translationalneuromodeling/tapas)

clear
clc

load e

CLUSTER = 0;


%% fetch physio files


main_dir_physio = '/network/lustre/iss01/cenir/analyse/irm/users/benoit.beranger/CUSPEX/DICOM';
e_physio = exam(main_dir_physio, 's12'); % all subjects with multi-echo
e_physio.addSerie('_PhysioLog$','physio')
e_physio.getSerie('physio').addVolume('dcm$','dcm',1)

e_physio.getSerie('physio').addVolume('Info.log$','info',1)
e_physio.getSerie('physio').addVolume('PULS.log$','puls',1)
e_physio.getSerie('physio').addVolume('RESP.log$','resp',1)

% e_physio.explore

info = e_physio.getSerie('physio').getVolume('info').getPath';
puls = e_physio.getSerie('physio').getVolume('puls').getPath';
resp = e_physio.getSerie('physio').getVolume('resp').getPath';


%% Prepare dirs & files

run = e.getSerie('run');

clear par
if CLUSTER
    par.run = 0;
    par.sge = 1;
    par.sge_queu = 'normal,bigmem'; 
else
    par.run = 1;
    par.sge = 0;
end
job_afni_remove_nan( run.getVolume('^wts_OC'), par );


%%

volume = run.getVolume('^nwts_OC').removeEmpty.toJob(0);

outdir = get_parent_path(volume);

rp     = fullfile(outdir,'rp_spm.txt');

tmp = [run.getVolume('^nwts_OC').exam]';
mask   = tmp.getSerie('anat').getVolume('^rwp[23]').toJob(0);


%%

clear par

%----------------------------------------------------------------------------------------------------------------------------------------------------
% ALWAYS MANDATORY
%----------------------------------------------------------------------------------------------------------------------------------------------------

par.physio   = 1;
par.noiseROI = 1;
par.rp       = 1;

par.TR     = 1.660;
par.nSlice = 60;

par.volume = volume;
par.outdir = outdir;

%----------------------------------------------------------------------------------------------------------------------------------------------------
% Physio
%----------------------------------------------------------------------------------------------------------------------------------------------------

par.physio_Info = info;
par.physio_PULS = puls;
par.physio_RESP = resp;

par.physio_RETROICOR        = 1;
par.physio_HRV              = 1;
par.physio_RVT              = 1;
par.physio_logfiles_vendor  = 'Siemens_Tics'; % Siemens CMRR multiband sequence, only this one is coded yet
par.physio_logfiles_align_scan = 'last';         % 'last' / 'first'
% Determines which scan shall be aligned to which part of the logfile.
% Typically, aligning the last scan to the end of the logfile is beneficial, since start of logfile and scans might be shifted due to pre-scans;
par.physio_slice_to_realign    = 'middle';       % 'first' / 'middle' / 'last' / sliceNumber (integer)
% Slice to which regressors are temporally aligned. Typically the slice where your most important activation is expected.


%----------------------------------------------------------------------------------------------------------------------------------------------------
% noiseROI
%----------------------------------------------------------------------------------------------------------------------------------------------------

par.noiseROI_mask   = mask;
par.noiseROI_volume = volume;

par.noiseROI_thresholds   = [0.95 0.70];     % keep voxels with tissu probabilty >= 95%
par.noiseROI_n_voxel_crop = [2 1];           % crop n voxels in each direction, to avoid partial volume
par.noiseROI_n_components = 10;              % keep n PCA componenets


%----------------------------------------------------------------------------------------------------------------------------------------------------
% Realignment Parameters
%----------------------------------------------------------------------------------------------------------------------------------------------------

par.rp_file = rp;

par.rp_order     = 24;   % can be 6, 12, 24
% 6 = just add rp, 12 = also adds first order derivatives, 24 = also adds first + second order derivatives
par.rp_method    = 'FD'; % 'MAXVAL' / 'FD' / 'DVARS'
par.rp_threshold = 0.5;  % Threshold above which a stick regressor is created for corresponding volume of exceeding value


%----------------------------------------------------------------------------------------------------------------------------------------------------
% Other
%----------------------------------------------------------------------------------------------------------------------------------------------------
par.print_figures = 0; % 0 , 1 , 2 , 3

% classic matvol
if CLUSTER
    par.run = 0;
    par.sge = 1;
    par.sge_queu = 'normal,bigmem'; 
else
    par.run = 1;
    par.sge = 0;
end
par.display  = 0;
par.redo     = 0;

% cluster
par.jobname  = 'spm_physio';
par.walltime = '04:00:00';
par.mem      = '4G';

job_physio_tapas( par );
