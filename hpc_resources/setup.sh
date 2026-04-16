#!/bin/bash
#SBATCH -n 1
#SBATCH -t 02:00:00
#SBATCH -p compute
#SBATCH -o /scratch/<netid>/setup.log
#SBATCH --open-mode=truncate

echo "============================="
echo "Starting Setup..."
echo "============================="

# Step 1: Load miniconda
echo ""
echo "Step 1: Loading miniconda..."
module purge
module load miniconda/3-4.11.0
echo "Miniconda loaded!"

# Step 2: Create conda environment with Python 3.11 and Node.js
echo ""
echo "Step 2: Creating conda environment..."
conda create -y --prefix /scratch/<netid>/deepbugs_env python=3.11 nodejs -c conda-forge
echo "Conda environment created!"

# Step 3: Activate environment
echo ""
echo "Step 3: Activating environment..."
source activate /scratch/<netid>/deepbugs_env
echo "Environment activated!"

# Verify node and python
echo ""
echo "Verifying installations..."
echo "Node version: $(node --version)"
echo "Python version: $(python --version)"
echo "Pip version: $(pip --version)"

# Step 4: Upgrade pip
echo ""
echo "Step 4: Upgrading pip..."
pip install --upgrade pip
echo "Pip upgraded!"

# Step 5: JavaScript Dependencies
echo ""
echo "Step 5: Installing JavaScript dependencies..."
cd /scratch/<netid>/Replication_DeepBugs/src
npm install
echo "JavaScript dependencies installed!"

# Step 6: Fix requirements.txt tensorflow version
echo ""
echo "Step 6: Fixing tensorflow version in requirements.txt..."
cd /scratch/<netid>/Replication_DeepBugs
sed -i 's/tensorflow==2.21.0/tensorflow==2.13.0/g' requirements.txt
echo "requirements.txt updated!"
echo "Current requirements.txt:"
cat requirements.txt

# Step 7: Install Python packages
echo ""
echo "Step 7: Installing Python packages..."
pip install -r requirements.txt
echo "Python packages installed!"

echo ""
echo "============================="
echo "Setup Done!"
echo "============================="
