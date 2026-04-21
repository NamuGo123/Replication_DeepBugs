## 1. Project Title and Overview

**Namu Go**  (New York University Abu Dhabi) and **Nelson Mbigili**  (New York University Abu Dhabi) 


- **Paper Title**:DeepBugs:A Learning Approach to Name-based Bug Detection
- **Authors**: MICHAEL PRADEL (TU Darmstadt, Germany), KOUSHIK SEN (UC Berkeley, USA)
- **Replication Team**: Namu Go and Nelson Mbigili
- **Course**: CS-UH 3260 Software Analytics, NYUAD
- **Brief Description**: 
    
    - **Original Paper Summary**:

    DeepBugs is a machine learning framework for detecting name-based bugs 
    in JavaScript code. It frames bug detection as a binary classification 
    problem, training a feedforward neural network to distinguish correct 
    code from buggy variants generated through simple code transformations 
    (e.g., swapping function arguments). Trained on 100,000 JavaScript files 
    from the JS150k corpus, the framework achieves 89%–95% accuracy across 
    three bug detectors (SwappedArgs, BinOperator, IncorrectBinaryOperand), 
    with inference under 20ms per file and a 68% true positive rate on 
    real-world code.

  

    - **Replication Scope Summary**:

    We replicate the SwappedArgs bug detector from the original paper, 
    re-running the full training and evaluation pipeline on the same JS150k 
    corpus. We achieve a training accuracy of 94.13% and validation accuracy 
    of 94.76%, consistent with the original results. We additionally apply 
    the trained model to 10 real-world JavaScript files from popular js librray.

> All scripts, datasets, and evaluation artifacts needed to reproduce the replication results are provided in this repository.
---

##  2. Repository Structure 


This repository has the following structure

```text

Replication_DeepBugs/
├── README.md                              # Project overview and replication guide
├── INSTRUCTS.md                           # Original Paper README.md file
├── LICENSE                                # License file
├── requirements.txt                       # Python dependencies
├── DeepBugs.ipynb                         # Original Jupyter notebook demo
├── fileIDs.json                           # Maps JS files to numeric IDs
├── poss_anomalies.txt                     # Potential bugs found in validation data
├── predictions.txt                        # Bug predictions on additional JS files
├── data -> dataset/data                   # Symbolic link to fix path resolution issue
├── dataset/                               # JS150k corpus, embeddings, and additional files
├── bug_detection_model_1776188293470/     # Original pre-trained model from repository
├── hpc_resources/                         # SLURM job scripts for NYUAD HPC 
├── results/                               # Trained model and bug finding results
├── src/                                   # Original extraction and training source code
├── logs/                                  # Training and evaluation logs
└── tests/                                 # Test scripts

```

## 3. Setup Instructions and Replication Guide

### Prerequisites
- **Operating System:** Linux (recommended: NYUAD HPC cluster, Jubail)
- **Programming Languages:** Python 3.11, Node.js v25+
- **Tools:** `git`, `conda` (via miniconda), `npm`, SLURM job scheduler
- **Hardware:** HPC access recommended for full JS150k corpus training (50GB RAM, 4 CPU cores)
- **Dataset:** The full JS150k corpus must be downloaded separately from
  [http://www.srl.inf.ethz.ch/js150.php](http://www.srl.inf.ethz.ch/js150.php)
  and saved in *datasets/data/js/programs_all* folder

- **Trained Model:** Our trained SwappedArgs model is available in
  `results/Part_1/my_model.keras` and can be used directly for bug finding.

> All required Python packages are specified in `requirements.txt`.
> Node.js dependencies are specified in `src/package.json`.

---

### Replication Guide

**1. Clone the Repository**
```bash
git clone <repository-url>
cd Replication_DeepBugs
```
**2. Set Up Environment**

Install Node.js (v14+) and Python 3.11, then install all dependencies:
```bash
# Install JavaScript dependencies
cd src
npm install
cd ..

# From the root Install Python dependencies
pip install -r requirements.txt
```

> **HPC users:** A ready-to-use SLURM setup script is provided in
> `hpc_resources/setup.sh` that automates the above steps using conda.

**3. Prepare the Dataset**

Download the JS150k corpus from
[http://www.srl.inf.ethz.ch/js150.php](http://www.srl.inf.ethz.ch/js150.php)
and place it under `dataset/data/js/programs_all/`.

Then create the symbolic link required to fix the path resolution issue:
```bash
ln -s dataset/data data
```

---

### Replication Tasks

#### Task 1: Training and Evaluating the SwappedArgs Detector

Run the full training and evaluation pipeline:

**Step 1: Extract training and validation data**
**Step 1a: Extract training data**
```bash
node src/javascript/extractFromJS.js calls --parallel 4 \
  dataset/data/js/programs_training.txt data/js/programs_all
```

**Step 1b: Merge training outputs into a single valid JSON array**
```bash
python3 -c "
import json, glob
data = []
for f in glob.glob('calls_*.json'):
    with open(f) as fp: data.extend(json.load(fp))
with open('results/calls_training.json', 'w') as fp: json.dump(data, fp)
"
```

**Step 1c: Extract validation data**
```bash
node src/javascript/extractFromJS.js calls --parallel 4 \
  dataset/data/js/programs_eval.txt data/js/programs_all
```

**Step 1d: Merge validation outputs into a single valid JSON array**
```bash
python3 -c "
import json, glob
data = []
for f in glob.glob('calls_*.json'):
    with open(f) as fp: data.extend(json.load(fp))
with open('results/calls_validation.json', 'w') as fp: json.dump(data, fp)
"
```

**Step 2: Train and validate the classifier**
```bash
python3 src/python/BugLearnAndValidate.py --pattern SwappedArgs \
  --token_emb dataset/token_to_vector.json \
  --type_emb dataset/type_to_vector.json \
  --node_emb dataset/node_type_to_vector.json \
  --training_data results/calls_training.json \
  --validation_data results/calls_validation.json
```

**Step 3: Train classifier for later use**
```bash
python3 src/python/BugLearn.py --pattern SwappedArgs \
  --token_emb dataset/token_to_vector.json \
  --type_emb dataset/type_to_vector.json \
  --node_emb dataset/node_type_to_vector.json \
  --training_data results/calls_training.json \
  --out results/my_model.keras
```

> **HPC users:** All steps above are automated in `hpc_resources/swappedargs_2.sh`.

---


#### Task 2: Bug Finding on Additional Real-World JS Files

```
**Step 1: Extract code pieces

node src/javascript/extractFromJS.js calls --files <list of files>

The command produces calls_*.json files, which is data suitable for the SwappedArgs bug detector.


**Step 2: Use a trained classifier to identify bugs

python3 src/python/BugFind.py --pattern SwappedArgs --threshold 0.95 --model results/Part_1/my_model.keras --token_emb dataset/token_to_vector.json --type_emb dataset/type_to_vector.json --node_emb dataset/node_type_to_vector.json --testing_data results/Part_2/calls_1776601747307.json

The first argument selects the bug pattern.
0.95 is the threshold for reporting bugs; higher means fewer warnings of higher certainty.
--model sets the directory to load a trained model from.
The next three arguments are vector representations for tokens (here: identifiers and literals), for types, and for AST node types.
The remaining argument is a list of .json files. They contain the data extracted in Step 1.
The command examines every code piece and writes a list of potential bugs with its probability of being incorrect

```

---

### 4. GenAI Usage
- **Tool Used:** [Claude Code](https://claude.ai/)
- **How It Was Used:**
  - **Environment & Dependency Setup:** Assisted in resolving Python and 
    Node.js dependency version conflicts and setting up the conda environment 
    on the NYUAD HPC cluster.
  - **HPC Job Scripts:** Assisted in writing and structuring SLURM batch job 
    scripts for training and evaluation.
  - **Debugging:** Assisted in diagnosing and fixing issues including 
    TensorFlow/Keras API compatibility issues.
