#! /usr/bin/bash

seed_list=()
pval_list=()

echo "Running Chisqfit.py $1 Times..."

rm nohup.out
nohup parallel -j100% --header : python3 -u Chisqfit.py "-s" {seeds} \
   ::: seeds $(shuf -i 1-100 -n $1) \

i=0
for n in $(grep 'p-value = ' nohup.out | sed 's/^.*= //'); do
   if (( $(echo "$n < 0.05" | bc -l) )); then
      let i+=1
      pval_list+="$n "
   fi
done


echo "Number of occurrances: $i" 
echo $pval_list