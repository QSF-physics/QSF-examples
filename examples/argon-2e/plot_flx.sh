#!/bin/bash -e
cd "Results";
fc="fwhm_cycles_"
fqr="flux_quiver_ratio_"
p="phase_"
DIR=./../../../QSF/mathematica/QSF
FM="OutputType png"
BL="BlurRadius 0.1"
QM="QuarterMerge None"
PR_FULL="PlotRange {{-4,4},{-4,4},Full}"
PR_PART="PlotRange {{0,4},{0,4},Full}"
for MD in "eb" "es"
do 
    
    for MT in "ShowPopulations True" "ShowPopulations False"
    do
        ${DIR}/FLX.wl "model_${MD}/${fqr}@@/nm_@@/${fc}@/${p}*/RE.dat" ${FM} ${BL} ${MT}
    done
done
exit 0;
for MD in "eb" "es"
do 
    for LB in nm_775 nm_1550 nm_3100  # nm_1800 nm_2500 nm_3100
    do
        for MT in "ShowPopulations True"
        do
            ${DIR}/FLX.wl "model_${MD}/${fqr}@@/${LB}/${fc}@/${p}*/RE.dat" ${FM} ${BL} ${MT}
            for PH in "${p}0.000000" "${p}0.250000" "${p}0.500000"
            do
                ${DIR}/FLX.wl "model_${MD}/${fqr}@@/${LB}/${fc}@/${PH}/RE.dat" ${FM} ${BL} ${MT}
            done
        done
    done
done
exit 0;
for QV in "${fqr}0.500000" "${fqr}1.000000" 
do 
    for LB in nm_775 nm_1550 nm_3100  # nm_1800 nm_2500 nm_3100
    do
        for MT in "ShowPopulations True" "ShowPopulations False"
        do
            ${DIR}/FLX.wl "model_@@/${QV}/${LB}/${fc}@/${p}*/RE.dat" ${FM} ${BL} ${MT}
            for PH in "${p}0.000000" "${p}0.250000" "${p}0.500000"
            do
                ${DIR}/FLX.wl "model_@@/${QV}/${LB}/${fc}@/${PH}/RE.dat" ${FM} ${BL} ${MT}
            done
        done
    done
done
exit 0;