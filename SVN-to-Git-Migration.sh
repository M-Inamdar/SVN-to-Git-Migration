#!/bin/bash

# SVN Repository URLs (add all your SVN repositories here)
SVN_REPO_URLS=("http://svn.example.com/svn/repo1" "http://svn.example.com/svn/repo2" "http://svn.example.com/svn/repo3")

# Gerrit Configuration
GERRIT_SERVER="gerrit-server.example.com"
GERRIT_PORT="29418"
GERRIT_USER="your-username"

# Authors file for svn to git mapping
AUTHORS_FILE="authors.txt"

# Loop through each SVN repository URL
for SVN_REPO_URL in "${SVN_REPO_URLS[@]}"; do
  # Extract repository name from URL (assuming URL ends in /repo-name)
  REPO_NAME=$(basename "$SVN_REPO_URL")

  # Define Git repository directory based on repo name
  GIT_REPO_DIR="${REPO_NAME}-git"

  echo "Starting migration for $SVN_REPO_URL to Git repository $GIT_REPO_DIR"

  # Clone the SVN repository with git-svn
  git svn clone --stdlayout --authors-file="$AUTHORS_FILE" "$SVN_REPO_URL" "$GIT_REPO_DIR"

  # Change to the newly created Git repository directory
  cd "$GIT_REPO_DIR" || exit 1

  # Add Gerrit remote
  GERRIT_REMOTE="ssh://${GERRIT_USER}@${GERRIT_SERVER}:${GERRIT_PORT}/${REPO_NAME}"
  git remote add gerrit "$GERRIT_REMOTE"

  # Fetch all branches from SVN
  git svn fetch

  # Push all branches to Gerrit
  echo "Pushing all branches to Gerrit for $REPO_NAME"
  git push gerrit --all

  # Push all tags to Gerrit
  echo "Pushing all tags to Gerrit for $REPO_NAME"
  git push gerrit --tags

  # Go back to the root directory
  cd ..

  echo "Migration for $SVN_REPO_URL completed successfully!"

done

echo "All repositories have been migrated!"
