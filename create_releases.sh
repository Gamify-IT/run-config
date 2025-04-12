#!/bin/bash

# Check if required arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <version> <message>"
  exit 1
fi

# Assign input arguments to variables
VERSION=$1
MESSAGE=$2

# List of repositories
REPOS=("test-data" "crosswordpuzzle-backend" "crosswordpuzzle" "chickenshock-backend" "chickenshock" "overworld" "memory" "finitequiz-backend" "bugfinder" "memory-backend"
 "bugfinder-backend" "finitequiz" "towerdefense-backend" "towerdefense" "towercrush" "regexgame" "regexgame-backend" "towercrush-backend" "landing-page" "overworld-backend" 
 "run-config" "lecturer-interface" "reverse-proxy" "functionbuilder-backend" "functionbuilder" "keycloak" "third-party-license-notice" "privacy-policy" "authentification-validator"
 "sharry-fileserver" "multiplayer-backend")

# Loop over each repository and create a release
for REPO in "${REPOS[@]}"; do
  echo "Creating release for $REPO..."
  
  # Change to the repository directory (make sure the script is in the parent directory of these repos)
  if [ -d "$REPO" ]; then
    cd "$REPO"
    
    # Use GitHub CLI to create a release
    gh release create "$VERSION" --title "$VERSION" --notes "$MESSAGE"
    
    # Move back to the parent directory
    cd ..
  else
    echo "Directory $REPO not found. Skipping..."
  fi
done

echo "Releases created for all repositories."
