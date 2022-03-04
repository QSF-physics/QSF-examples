#!/bin/bash -e
cd "Results";
fc="fwhm_cycles_"
fqr="flux_quiver_ratio_"
p="phase_"
DIR=./../../../QSF/mathematica/QSF/
FM=;
BL="BlurRadius 0.05"
MO="MergeOrthants"
MR="WFMaskEdgeAtRatio 0.7"
QALL="PlotRange->{{-4,4},{-4,4},Full}"
Q1="PlotRange->{{0,4},{0,4},Full}"
Q1D="PlotRange->{{0,4*Sqrt[2]},Full}"

OPT_GROUP="OptionGroups <|full-><|${Q1D},$MO->None|>,corr-><|${Q1D},$MO->Correlated|>,all-><|${Q1D},$MO->All|>|>"
for QV in "${fqr}2.000000" # "${fqr}1.000000" #"${fqr}0.500000"
do 
    for MD in "eb" "es"
    do
        CMN="${BL} ${FM} ${MR}"
        ${DIR}/WF.wl "model_${MD}/${QV}/nm_*/${fc}**/${p}0.5***/momenta_repP.psi3" $CMN ${OPT_GROUP}
    done
done
exit 0;
# OPT_GROUP="OptionGroups <|full-><|${Q1D},$MO->None,DiagSum->True|>,corr-><|${Q1D},$MO->Correlated,DiagSum->True|>,all-><|${Q1D},$MO->All,DiagSum->True|>|>"
for QV in "${fqr}2.000000" # "${fqr}1.000000" #"${fqr}0.500000"
do 
    for LB in nm_3100 nm_775 nm_1550   # nm_1800 nm_2500 
    do
        for MD in "eb" "es"
        do
            CMN="${RB} ${BL} ${FM} ${MR}"
            ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}@/${p}0.5*/momenta_repP.psi*" $CMN ${OPT_GROUP}
            # ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}@/${p}*/momenta_repP.psi3" ${FM} ${BL} MergeOrthants None ${Q1}
            # ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}@/${p}*/momenta_repP.psi3" ${FM} ${BL} MergeOrthants All ${Q1}
            # ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}@/${p}*/momenta_repP.psi3" ${FM} ${BL} MergeOrthants Correlated ${Q1}
            # ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}@/${p}0.5*/momenta_repP.psi3" ${FM} ${BL} MergeOrthants None ${QALL}

            # for PH in "${p}0.000000" "${p}0.250000" "${p}0.500000"
            # do
            #     ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}@/${PH}/momenta_repP.psi3" ${FM} ${BL} ${MO} ${PR} Preprocess Identity
            # done
            # ${DIR}/WF.wl "model_eb/flux_quiver_ratio_0.900000/nm_3100/fwhm_cycles_13.540000/phase_0.000000/snapshot@repP.psi3" ${FM} ${BL} ${MO} ${PR} Identity
            # ${DIR}/WF.wl "model_eb/flux_quiver_ratio_0.900000/nm_3100/fwhm_cycles_13.540000/phase_0.000000/snapshot@repP.psi3" ${FM} ${BL} ${MO} ${PR} WFDropCorrelated
            # ${DIR}/WF.wl "model_eb/flux_quiver_ratio_0.900000/nm_3100/fwhm_cycles_13.540000/phase_0.000000/snapshot@repP.psi3" ${FM} ${BL} ${MO} ${PR} Preprocess WFKeepCorrelated
            # ${DIR}/WF.wl "model_eb/flux_quiver_ratio_0.900000/nm_3100/fwhm_cycles_13.540000/phase_0.000000/snapshot@repP.psi3" ${FM} ${BL} ${MO} ${PR} Preprocess WFDropCorrelated
            # ${DIR}/WF.wl "model_eb/flux_quiver_ratio_0.900000/nm_3100/fwhm_cycles_13.540000/phase_0.000000/snapshot@repP.psi3" ${FM} ${BL} ${MO} ${PR} Preprocess Identity
            # ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}13.540000/${p}0.000000/momenta_repP.psi3" ${FM} ${BL} ${MO} ${PR} Identity
            # ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}13.540000/${p}0.000000/momenta_repP.psi3" ${FM} ${BL} ${MO} ${PR} WFFourier
            # ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}13.540000/${p}0.000000/momenta_repP.psi3" ${FM} ${BL} ${MO} ${PR} WFDropCorrelated
            # ${DIR}/WF.wl "model_${MD}/${QV}/${LB}/${fc}13.540000/${p}0.000000/momenta_repP.psi3" ${FM} ${BL} ${MO} ${PR} WFKeepCorrelated
        done
    done
done