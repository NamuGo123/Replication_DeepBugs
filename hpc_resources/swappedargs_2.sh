#!/bin/bash
#SBATCH -n 4
#SBATCH -t 3-00:00:00
#SBATCH -p compute
#SBATCH --mem=50GB
#SBATCH -o /scratch/<netid>/swappedargs.log
#SBATCH --open-mode=truncate
echo "============================="
echo "Starting SwappedArgs Replication..."
echo "============================="
module purge
module load miniconda/3-4.11.0
source activate /scratch/<netid>/deepbugs_env
NODE=/scratch/<netid>/deepbugs_env/bin/node
PYTHON=/scratch/<netid>/deepbugs_env/bin/python3
echo "Node version: $($NODE --version)"
echo "Python version: $($PYTHON --version)"
cd /scratch/<netid>/Replication_DeepBugs
echo "Cleaning old calls json files..."
rm -f results/calls_*.json
rm -f calls_*.json
echo "Cleaned!"
echo "Step 1a: Extracting TRAINING data..."
$NODE src/javascript/extractFromJS.js calls --parallel 4 dataset/data/js/programs_training.txt data/js/programs_all
echo "Merging training json files into valid JSON array..."
$PYTHON -c "
import json, glob, sys
data = []
for f in glob.glob('calls_*.json'):
    with open(f) as fp:
        data.extend(json.load(fp))
with open('results/calls_training.json', 'w') as fp:
    json.dump(data, fp)
print('Merged', len(data), 'training items')
"
rm -f calls_*.json
echo "Training data extracted!"
echo "Step 1b: Extracting VALIDATION data..."
$NODE src/javascript/extractFromJS.js calls --parallel 4 dataset/data/js/programs_eval.txt data/js/programs_all
echo "Merging validation json files into valid JSON array..."
$PYTHON -c "
import json, glob, sys
data = []
for f in glob.glob('calls_*.json'):
    with open(f) as fp:
        data.extend(json.load(fp))
with open('results/calls_validation.json', 'w') as fp:
    json.dump(data, fp)
print('Merged', len(data), 'validation items')
"
rm -f calls_*.json
echo "Validation data extracted!"
echo "Verifying files..."
ls -lh results/calls_training.json results/calls_validation.json
echo "Step 2a: Train and Validate..."
$PYTHON src/python/BugLearnAndValidate.py --pattern SwappedArgs --token_emb dataset/token_to_vector.json --type_emb dataset/type_to_vector.json --node_emb dataset/node_type_to_vector.json --training_data results/calls_training.json --validation_data results/calls_validation.json
echo "Train and Validate done!"
echo "Step 2b: Train classifier for later use..."
$PYTHON src/python/BugLearn.py --pattern SwappedArgs --token_emb dataset/token_to_vector.json --type_emb dataset/type_to_vector.json --node_emb dataset/node_type_to_vector.json --training_data results/calls_training.json --out results/my_model.keras
echo "Classifier trained!"
echo "============================="
echo "SwappedArgs Replication Done!"
echo "============================="
