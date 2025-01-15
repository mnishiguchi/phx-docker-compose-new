#!/bin/bash
#
# Install phxd-new by cloning its repository and creating a symlink.

set -eu

REPO_URL="https://github.com/mnishiguchi/phx-dock.git"
INSTALL_DIR="$HOME/.config/phx-dock"
BIN_DIR="$HOME/.local/bin"
BIN_PATH="$BIN_DIR/phxd-new"

# Print headings
echo_heading() {
  echo -e "\n\033[34m$1\033[0m"
}

# Print success message
echo_success() {
  echo -e " \033[32m✔ $1\033[0m"
}

# Print failure message
echo_failure() {
  echo -e " \033[31m✖ $1\033[0m"
}

main() {
  echo_heading "Installing phxd-new..."

  # Ensure ~/.local/bin exists
  mkdir -p "$BIN_DIR"

  # Remove existing installation if present
  if [[ -d "$INSTALL_DIR" ]]; then
    echo_heading "Updating existing installation..."
    rm -rf "$INSTALL_DIR"
    echo_success "Removed previous installation."
  fi

  # Clone the repository
  echo_heading "Cloning repository..."
  if git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"; then
    echo_success "Repository cloned successfully."
  else
    echo_failure "Failed to clone repository."
    exit 1
  fi

  # Ensure phxd-new.sh is executable
  chmod +x "$INSTALL_DIR/phxd-new.sh"

  # Create a symlink in ~/.local/bin
  echo_heading "Creating symlink..."
  ln -sf "$INSTALL_DIR/phxd-new.sh" "$BIN_PATH"
  echo_success "Symlink created at $BIN_PATH"

  # Ensure ~/.local/bin is in PATH
  if ! echo "$PATH" | grep -q "$BIN_DIR"; then
    echo_heading "Final setup required"
    echo -e "\n\033[33m⚠️  Add $BIN_DIR to your PATH with:\033[0m"
    echo "   export PATH=\$HOME/.local/bin:\$PATH"
    echo "Then restart your terminal or source your profile file."
  fi

  echo_heading "Verifying installation..."
  if command -v phxd-new &>/dev/null; then
    echo_success "phxd-new is ready to use! 🚀"
    echo -e "\nRun the following to create a new Phoenix app:"
    echo -e "  \033[36mphxd-new my_app\033[0m"
  else
    echo_failure "Something went wrong: phxd-new is not available in PATH."
    exit 1
  fi
}

main "$@"
