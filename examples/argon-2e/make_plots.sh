
cd "Results/agh-transfergrid-eb/";
for FW in "fwhm_cycles_3.965000" "fwhm_cycles_6.576000" "fwhm_cycles_13.540000"
do
    # ./../../../../QSF/plotting/MergePlot.wls "${FW}/*/momenta_repP.psi3" 
    ./../../../../QSF/plotting/Plot.wls "${FW}/*/momenta_repP.psi*" #too many
    # for PH in "phase_0.000000" "phase_0.250000" "phase_0.500000" # bad res
    # do 
        # ./../../../../QSF/plotting/MergePlot.wls "${FW}/${PH}/momenta_repP.psi*"
    # done
done
cd -;
cd "Results/agh-transfergrid-es/";
for FW in "fwhm_cycles_3.965000" "fwhm_cycles_6.576000" "fwhm_cycles_13.540000"
do
    # ./../../../../QSF/plotting/MergePlot.wls "${FW}/*/momenta_repP.psi3"  
    # ./../../../../QSF/plotting/Plot.wls "${FW}/*/momenta_repP.psi*"  # too many
    # for PH in "phase_0.000000" "phase_0.250000" "phase_0.500000" # bad res
    # do 
    #     ./../../../../QSF/plotting/MergePlot.wls "${FW}/${PH}/momenta_repP.psi*"
    # done
done