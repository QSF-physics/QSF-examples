rm -f *.param;

CURRENT_DIR=`pwd`
BASENAME=`basename "$CURRENT_DIR"`

for SZ in 2 4
do
    nodes=$((256*$SZ*$SZ))
    wavelenghth=$((775*$SZ))
    mbytes=256 #$((256/$SZ/$SZ))
    for FW in 3.965 6.576 13.54
    do
      	for PH in 0 0.25 0.5
        do

            echo "-n ${nodes} --dx 0.5 --flux-quiver-ratio 0.5 --postdelay 4.0 --fwhm ${FW} --phase ${PH} -l ${wavelenghth}" >> ${params_file}${SZ}.param
        done
    done
    count=$(awk 'END { print NR }' ${SZ}.param)
    sbatch --job-name="${BASENAME}-${SZ}" --array=1-${count} --ntasks-per-node=16 --nodes=${SZ} --mem-per-cpu=${mbytes} prun-re.sh
done