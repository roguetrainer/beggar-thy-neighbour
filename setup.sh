#!/bin/bash

# setup.sh - Create virtual environment and install dependencies

set -e

VENV_DIR="venv"
alias python3='/usr/local/bin/python3'

echo "Creating virtual environment in ./$VENV_DIR..."
python3 -m venv "$VENV_DIR"

echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing requirements from requirements.txt..."
pip install -r requirements.txt

echo ""
echo "Setup complete!"
echo "To activate the virtual environment, run:"
echo "  source $VENV_DIR/bin/activate"
