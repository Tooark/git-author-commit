#!/bin/bash

# Git Author - Change author information in Git history
# Usage: ./git-author.sh [OLD_EMAIL] [NEW_EMAIL] [NEW_NAME]

# Default values
OLD_EMAIL="${1:-old@email.com}"
NEW_EMAIL="${2:-user@tooark.com}"
NEW_NAME="${3:-Tooark User}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Display header
echo -e "${CYAN}=== Git Author Tool ===${NC}"
echo "Old Email : $OLD_EMAIL"
echo "New Email : $NEW_EMAIL"
echo "New Name  : $NEW_NAME"
echo ""

# Check if git-filter-repo is installed
if ! command -v git-filter-repo &> /dev/null; then
    echo -e "${RED}ERROR: git-filter-repo not found in PATH.${NC}"
    echo "Install with: pip install git-filter-repo"
    exit 1
fi

# Confirmation before execution
echo -e "${YELLOW}Do you really want to rewrite the ENTIRE repository history?${NC}"
echo -e "${YELLOW}This is irreversible and affects all commits.${NC}"
read -p "Type 'YES' to continue: " confirm

if [ "$confirm" != "YES" ]; then
    echo -e "${RED}Operation cancelled.${NC}"
    exit 0
fi

# Create Python callbacks
EMAIL_CALLBACK="if email == b'$OLD_EMAIL':
    return b'$NEW_EMAIL'
return email"

COMMIT_CALLBACK="commit.committer_email = b'$NEW_EMAIL'
commit.committer_name = b'$NEW_NAME'"

echo -e "${YELLOW}Preparing repository...${NC}"

# Check if git is available and we're inside a git repository
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Warning: 'git' not available in PATH. Proceeding without stash.${NC}"
else
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        echo -e "${YELLOW}Warning: Does not appear to be a git repository. Proceeding without stash.${NC}"
    else
        # Check if there are local changes (including untracked files)
        if [ -n "$(git status --porcelain)" ]; then
            echo -e "${YELLOW}Local changes detected. Creating stash 'Git-Author-Commit'...${NC}"
            if git stash push -u -m "Git-Author-Commit"; then
                echo -e "${GREEN}Stash created successfully: 'Git-Author-Commit'.${NC}"
            else
                echo -e "${RED}Failed to create stash. Aborting.${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}No local changes, proceeding.${NC}"
        fi
    fi
fi

echo -e "${YELLOW}Running git-filter-repo...${NC}"

# Execute git-filter-repo with callbacks
git-filter-repo --force \
    --email-callback "$EMAIL_CALLBACK" \
    --commit-callback "$COMMIT_CALLBACK"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Process completed successfully!${NC}"
else
    echo -e "${RED}An error occurred during the process.${NC}"
    exit 1
fi
