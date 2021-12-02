% https://github.com/CMRR-C2P/MB

clear
clc

main_dir = '/network/lustre/iss01/cenir/analyse/irm/users/benoit.beranger/CUSPEX/DICOM';

e = exam(main_dir, 's12'); % all subjects with multi-echo

e.addSerie('PhysioLog$','physio')

e.getSerie('physio').addPhysio('dcm$','dcm',1)

e.getSerie('physio').getPhysio('dcm').extract()

e.getSerie('physio').addPhysio('Info.log$','physio_info',1)
e.getSerie('physio').addPhysio('PULS.log$','physio_puls',1)
e.getSerie('physio').addPhysio('RESP.log$','physio_resp',1)

e.getSerie('physio').getPhysio('physio').check()
