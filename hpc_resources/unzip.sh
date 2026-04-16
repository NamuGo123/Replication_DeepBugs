#!/bin/bash
#SBATCH -n 1
#SBATCH -t 02:00:00
#SBATCH -p compute
#SBATCH -o /scratch/<netid>/unzip.log

cd /scratch/<netid>
echo "Unzip starting!"
# Step 1: Extract js_dataset.tar.gz
tar -xzvf js_dataset.tar.gz
echo "Unzip Outer  Done!"
# Step 2: Extract inner data.tar.gz (in same directory)
tar -xzvf data.tar.gz

echo "Unzip All Done!"
