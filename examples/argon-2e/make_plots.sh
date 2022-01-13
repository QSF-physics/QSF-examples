#!/bin/bash -e
cd "Results";
fc="fwhm_cycles_"
fqr="flux_quiver_ratio_"
p="phase_"
DIR=./../../../QSF/plotting
FM=png
BL=0.1

# momenta only downloaded for 0.5
# for QV in "${fqr}0.500000"
# do 
#     for LB in nm_775 nm_1550 # nm_1800 nm_2500 nm_3100
#     do
#         for MD in "es" "eb"
#         do
#             ${DIR}/WF.wls "model_${MD}/${QV}/${LB}/${fc}@/${p}*/momenta_repP.psi3" 
#         done
#     done
# done
for QV in "${fqr}0.500000" "${fqr}1.000000" #"${fqr}2.000000" #"${fqr}0.500000" "${fqr}1.000000" #"${fqr}2.0" "${fqr}0.100000"
do 
    for LB in nm_775 nm_1550 #nm_3100  # nm_1800 nm_2500 nm_3100
    do
        for MT in "True" "False"
        do
            ${DIR}/FLX.wls "model_@@/${QV}/${LB}/${fc}@/${p}*/RE.dat" ${FM} ${BL} ${MT}
            # for PH in "${p}0.000000" "${p}0.250000" "${p}0.500000"
            # do
            #     ${DIR}/FLX.wls "model_@@/${QV}/${LB}/${fc}@/${PH}/RE.dat" ${FM} ${BL} ${MT}
            # done
        done
    done
    # for MD in "es" "eb"
    # do
        # ${DIR}/FLX.wls "model_${MD}/${QV}/nm_@@/${fc}@/${p}*/RE.dat" ${FM} ${BL}
        # for PH in "${p}0.000000" "${p}0.250000" "${p}0.500000"
        # do
        #     ${DIR}/FLX.wls "model_${MD}/${QV}/nm_@@/${fc}@/${PH}/RE.dat" ${FM} ${BL}
        # done
    # done
    
    # for FW in "3.965000" "6.576000" "13.540000"
    # do
    #     ${DIR}/FLX.wls "model_@@/${QV}/nm_@/${fc}${FW}/${p}*/RE.dat" ${FM} ${BL}
    #     for PH in "${p}0.000000" "${p}0.250000" "${p}0.500000"
    #     do
    #         ${DIR}/FLX.wls "model_@@/${QV}/nm_@/${fc}${FW}/${PH}/RE.dat" ${FM} ${BL}
    #     done
    # done
done
exit 0;
for LB in nm_1800 nm_2500 nm_3100 #nm_1000
do
    
    # for MD in "es" "eb"
    # do
        
        # ./../../../QSF/plotting/WF.wls "@/${LB}/@/*/momenta_repP.psi3" 
        # for PH in "phase_0.000000" "phase_0.250000" "phase_0.500000"
        # do 
        #     ./../../../QSF/plotting/Plot.wls "@/${LB}/@/${PH}/momenta_repP.psi3"
        # done
        # for FW in "fwhm_cycles_3.965000" "fwhm_cycles_6.576000" "fwhm_cycles_13.540000"
        # do
        #     # ./../../../../QSF/plotting/MergePlot.wls "${FW}/*/momenta_repP.psi3" 
        #     ./../../../../QSF/plotting/Plot.wls "${MD}/${FW}/*/momenta_repP.psi*" #too many
        # done
    # done
done

