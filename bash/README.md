# Bash Configuration

This directory contains configuration files for the Bash shell. These files help customize and extend the behavior of Bash to suit my workflow.

## Files

- `.bash_profile`: Configurations loaded by Bash during a login shell session. (e.g. log in via a terminal or SSH)
  - Sources `.bashrc` to ensure consistent behavior.
- `.bashrc`: Configurations loaded by non-login interactive shells. (e.g. open a terminal emulator)
  - Includes aliases, environment variables, and custom functions.

## Setup Instructions

To use these configurations:

1. Clone the dotfiles repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

