#!/usr/bin/env python3
"""
Installation script for gdtoolkit (gdformat, gdlint)
Used for code formatting and linting in Godot projects
"""

import subprocess
import sys
import os

def run_command(command, description):
    """Run a command and handle errors"""
    print(f"Running: {description}")
    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        print(f"✓ {description} completed successfully")
        if result.stdout:
            print(f"Output: {result.stdout}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ {description} failed")
        print(f"Error: {e.stderr}")
        return False

def main():
    """Main installation function"""
    print("Installing gdtoolkit for Godot code formatting and linting...")
    
    # Check if pip is available
    try:
        subprocess.run([sys.executable, "-m", "pip", "--version"], check=True, capture_output=True)
    except subprocess.CalledProcessError:
        print("✗ pip is not available. Please install Python with pip.")
        return False
    
    # Install gdtoolkit
    install_cmd = [sys.executable, "-m", "pip", "install", "gdtoolkit>=4.0.0"]
    if not run_command(install_cmd, "Installing gdtoolkit"):
        return False
    
    # Verify installation
    try:
        gdformat_check = subprocess.run(["gdformat", "--version"], capture_output=True, text=True)
        print(f"✓ gdformat installed: {gdformat_check.stdout.strip()}")
    except FileNotFoundError:
        print("⚠ gdformat command not found in PATH")
    
    try:
        gdlint_check = subprocess.run(["gdlint", "--version"], capture_output=True, text=True)
        print(f"✓ gdlint installed: {gdlint_check.stdout.strip()}")
    except FileNotFoundError:
        print("⚠ gdlint command not found in PATH")
    
    print("\n🎉 gdtoolkit installation completed!")
    print("You can now use:")
    print("  gdformat <file.gd>  - Format GDScript files")
    print("  gdlint <file.gd>    - Lint GDScript files")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)