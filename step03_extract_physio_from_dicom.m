% https://github.com/CMRR-C2P/MB

clear
clc

main_dir = '/network/lustre/iss01/cenir/analyse/irm/users/benoit.beranger/CUSPEX/DICOM';

e = exam(main_dir, 's12'); % all subjects with multi-echo

e.addSerie('PhysioLog$','physio')

e.getSerie('physio').addVolume('dcm$','dcm',1)

physio_file = e.getSerie('physio').getVolume('dcm').getPath;

for f = 1 : length(physio_file)
    
    extractCMRRPhysio(physio_file{f})

end 
