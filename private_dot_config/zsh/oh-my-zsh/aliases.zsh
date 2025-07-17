# Adaptations for Devcontainers
if [ "$DEVCONTAINER" = "true" ] || [ "$REMOTE_CONTAINERS" = "true" ]; then
  # open a file in VS Code from the integrated terminal
  alias edit="code -r"
fi
