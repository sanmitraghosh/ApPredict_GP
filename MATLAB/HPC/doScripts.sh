mkdir -p sa{1..100}

for d in ./*/ ;
do (cp surfaceVsInterpolator.m did.sh surfaceVsInterpolator_slurm.sh ./$d && cd "$d" && bash did.sh);
done;
