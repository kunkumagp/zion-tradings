#!/bin/bash

# Define target branches
DEV_BRANCH="dev"
MAIN_BRANCH="main"

# Function to display the menu
show_menu() {
    echo
    echo "=========================================="
    echo "    Git Branch Management Script"
    echo "=========================================="
    echo "1. Merge a Feature Branch"
    echo "2. Merge a Fix Branch"
    echo "3. Reset"
    echo "4. Create GitHub Issue"
    echo "5. Close GitHub Issue"
    echo "6. Exit"
    echo "=========================================="
}


# Function for merging feature branches
merge_feature_branch() {
    echo "=== Merge Feature Branch ==="

    # Prompt for the branch name to merge
    echo "Enter the name of the branch you want to merge:"
    read BRANCH_TO_MERGE

    # Prompt for a custom commit message for the dev branch
    echo "Enter a custom commit message for merging into $DEV_BRANCH (leave blank for default):"
    read CUSTOM_COMMIT_MESSAGE

    # Add a tag for the main branch
    echo "Enter a tag name for the main branch (e.g., v1.0.0):"
    read TAG_NAME


    # Check for uncommitted changes
    echo "Checking for uncommitted changes..."
    if ! git diff-index --quiet HEAD --; then
        echo "Found uncommitted changes. Committing them as 'latest changes'..."
        git add -A || exit 1
        git commit -m "latest changes" || exit 1
    else
        echo "No uncommitted changes found."
    fi

    

    # Check if the branch exists on origin and pull/push accordingly
    echo "Checking if branch $BRANCH_TO_MERGE exists on origin..."
    if git ls-remote --exit-code --heads origin $BRANCH_TO_MERGE > /dev/null 2>&1; then
        echo "Branch $BRANCH_TO_MERGE exists on origin. Pulling latest changes..."
        git pull origin $BRANCH_TO_MERGE || exit 1
    else
        echo "Branch $BRANCH_TO_MERGE does not exist on origin. Pushing it now..."
        git push -u origin $BRANCH_TO_MERGE || exit 1
    fi

    # Wait for one second
    sleep 1

    # Put your existing script logic here
    git push -u origin $BRANCH_TO_MERGE || exit 1
    echo "Merging $BRANCH_TO_MERGE to $DEV_BRANCH..."
    git checkout $DEV_BRANCH || exit 1
    # git reset --soft $(git merge-base $DEV_BRANCH $DEV_BRANCH)
    
    # Rebase dev branch onto the BRANCH_TO_MERGE point
    echo "Rebasing $DEV_BRANCH onto $BRANCH_TO_MERGE..."
    git rebase $BRANCH_TO_MERGE || exit 1
    
    # Wait for one second
    sleep 1

    git reset --soft $(git merge-base $DEV_BRANCH $MAIN_BRANCH)
    sleep 1
    git commit -m "$CUSTOM_COMMIT_MESSAGE" || exit 1

    # Wait for one second
    sleep 1
    
    echo "Pushing merged changes to remote $DEV_BRANCH..."
    git push origin $DEV_BRANCH || exit 1

    echo "Merging $DEV_BRANCH into $MAIN_BRANCH..."
    
    # Wait for one second
    sleep 1

    # Merge dev branch into main branch
    echo "Switching to branch $MAIN_BRANCH..."
    git checkout $MAIN_BRANCH || exit 1

    # Wait for one second
    sleep 1

    git merge --no-ff -m "$TAG_NAME" $DEV_BRANCH || exit 1


    echo "Pushing merged changes to remote $MAIN_BRANCH..."
    git push origin $MAIN_BRANCH || exit 1

    # Wait for one second
    sleep 1

    echo "Creating a tag $TAG_NAME for the main branch..."
    git tag -a $TAG_NAME -m "Release version $TAG_NAME" || exit 1

    echo "Pushing the tag $TAG_NAME to the remote repository..."
    git push origin $TAG_NAME || exit 1

    # Wait for one second
    sleep 1

    # Optional: Delete the specified branch locally and remotely
    read -p "Do you want to delete the current branch? (y/n): " DELETE_BRANCH
    if [[ $DELETE_BRANCH == "y" ]]; then
        echo "Deleting branch locally..."
        git branch -d $(git rev-parse --abbrev-ref HEAD) || exit 1

        echo "Deleting branch remotely..."
        git push origin --delete $(git rev-parse --abbrev-ref HEAD) || exit 1
    fi

    echo "Merge process completed successfully!"

    # Optional: Close related GitHub issues after successful merge
    echo
    read -p "Do you want to close any GitHub issues related to this merge? (y/n): " CLOSE_ISSUES
    if [[ $CLOSE_ISSUES == "y" ]]; then
        close_issues_after_merge "$TAG_NAME" "$BRANCH_TO_MERGE"
    fi

    # ... rest of your existing code
    
    # echo "Feature branch merge completed!"
}

# Function for merging fix branches
merge_fix_branch() {
    echo "=== Merge Fix Branch ==="
    echo "Fix branch functionality - to be implemented"
}

# Function for reset operations
reset_option() {
    echo "=== Reset Operation ==="
    echo "Reset functionality - to be implemented"
}

# Function to create GitHub issue
create_github_issue() {
    echo "=== Create GitHub Issue ==="
    
    # Check if GitHub CLI is installed
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI (gh) is not installed."
        echo "Please install it from: https://cli.github.com/"
        return 1
    fi
    
    # Check if user is authenticated
    if ! gh auth status &> /dev/null; then
        echo "Error: Not authenticated with GitHub CLI."
        echo "Please run 'gh auth login' first."
        return 1
    fi
    
    # Get issue details
    echo "Enter issue title:"
    read ISSUE_TITLE
    
    if [ -z "$ISSUE_TITLE" ]; then
        echo "Error: Issue title cannot be empty."
        return 1
    fi
    
    echo "Enter issue description (press Enter twice when done):"
    ISSUE_BODY=""
    while IFS= read -r line; do
        if [ -z "$line" ]; then
            break
        fi
        ISSUE_BODY="${ISSUE_BODY}${line}\n"
    done
    
    # Interactive label selection
    echo
    echo "=== Available Labels ==="
    echo "Fetching repository labels..."
    
    # Get available labels and store them in an array (compatible approach)
    AVAILABLE_LABELS=()
    while IFS= read -r label; do
        AVAILABLE_LABELS+=("$label")
    done < <(gh label list --json name --jq '.[].name' 2>/dev/null)
    
    if [ ${#AVAILABLE_LABELS[@]} -eq 0 ]; then
        echo "No labels found in repository or error fetching labels."
        echo "Do you want to add labels manually? (y/n):"
        read MANUAL_LABELS
        if [[ $MANUAL_LABELS == "y" ]]; then
            echo "Enter labels (comma-separated):"
            read LABELS
        else
            LABELS=""
        fi
    else
        echo "Available labels:"
        for i in "${!AVAILABLE_LABELS[@]}"; do
            echo "$((i+1)). ${AVAILABLE_LABELS[i]}"
        done
        echo "$((${#AVAILABLE_LABELS[@]}+1)). Skip labels"
        echo "$((${#AVAILABLE_LABELS[@]}+2)). Add custom labels"
        
        SELECTED_LABELS=""
        echo
        echo "Select labels (enter numbers separated by spaces, e.g., '1 3 5'):"
        read LABEL_CHOICES
        
        if [ -n "$LABEL_CHOICES" ]; then
            for choice in $LABEL_CHOICES; do
                if [[ $choice =~ ^[0-9]+$ ]]; then
                    if [ $choice -eq $((${#AVAILABLE_LABELS[@]}+1)) ]; then
                        # Skip labels option
                        break
                    elif [ $choice -eq $((${#AVAILABLE_LABELS[@]}+2)) ]; then
                        # Add custom labels
                        echo "Enter custom labels (comma-separated):"
                        read CUSTOM_LABELS
                        if [ -n "$CUSTOM_LABELS" ]; then
                            if [ -n "$SELECTED_LABELS" ]; then
                                SELECTED_LABELS="$SELECTED_LABELS,$CUSTOM_LABELS"
                            else
                                SELECTED_LABELS="$CUSTOM_LABELS"
                            fi
                        fi
                    elif [ $choice -ge 1 ] && [ $choice -le ${#AVAILABLE_LABELS[@]} ]; then
                        # Valid label selection
                        LABEL_NAME="${AVAILABLE_LABELS[$((choice-1))]}"
                        if [ -n "$SELECTED_LABELS" ]; then
                            SELECTED_LABELS="$SELECTED_LABELS,$LABEL_NAME"
                        else
                            SELECTED_LABELS="$LABEL_NAME"
                        fi
                    fi
                fi
            done
        fi
        LABELS="$SELECTED_LABELS"
    fi
    
    # Interactive assignee selection
    echo
    echo "=== Assignee Selection ==="
    echo "Fetching repository collaborators..."
    
    # Get available assignees (collaborators) using compatible approach
    AVAILABLE_ASSIGNEES=()
    while IFS= read -r assignee; do
        AVAILABLE_ASSIGNEES+=("$assignee")
    done < <(gh api repos/:owner/:repo/collaborators --jq '.[].login' 2>/dev/null)
    
    if [ ${#AVAILABLE_ASSIGNEES[@]} -eq 0 ]; then
        echo "No collaborators found or error fetching collaborators."
        echo "Do you want to add an assignee manually? (y/n):"
        read MANUAL_ASSIGNEE
        if [[ $MANUAL_ASSIGNEE == "y" ]]; then
            echo "Enter assignee GitHub username:"
            read ASSIGNEE
        else
            ASSIGNEE=""
        fi
    else
        echo "Available assignees:"
        for i in "${!AVAILABLE_ASSIGNEES[@]}"; do
            echo "$((i+1)). ${AVAILABLE_ASSIGNEES[i]}"
        done
        echo "$((${#AVAILABLE_ASSIGNEES[@]}+1)). Skip assignee"
        echo "$((${#AVAILABLE_ASSIGNEES[@]}+2)). Add custom assignee"
        
        echo
        echo "Select an assignee (enter a number):"
        read ASSIGNEE_CHOICE
        
        if [[ $ASSIGNEE_CHOICE =~ ^[0-9]+$ ]]; then
            if [ $ASSIGNEE_CHOICE -eq $((${#AVAILABLE_ASSIGNEES[@]}+1)) ]; then
                # Skip assignee
                ASSIGNEE=""
            elif [ $ASSIGNEE_CHOICE -eq $((${#AVAILABLE_ASSIGNEES[@]}+2)) ]; then
                # Add custom assignee
                echo "Enter GitHub username:"
                read ASSIGNEE
            elif [ $ASSIGNEE_CHOICE -ge 1 ] && [ $ASSIGNEE_CHOICE -le ${#AVAILABLE_ASSIGNEES[@]} ]; then
                # Valid assignee selection
                ASSIGNEE="${AVAILABLE_ASSIGNEES[$((ASSIGNEE_CHOICE-1))]}"
            else
                echo "Invalid selection. Skipping assignee."
                ASSIGNEE=""
            fi
        else
            echo "Invalid input. Skipping assignee."
            ASSIGNEE=""
        fi
    fi
    
    # Build the gh command
    CMD="gh issue create --title \"$ISSUE_TITLE\""
    
    if [ -n "$ISSUE_BODY" ]; then
        CMD="$CMD --body \"$ISSUE_BODY\""
    fi
    
    if [ -n "$LABELS" ]; then
        CMD="$CMD --label \"$LABELS\""
    fi
    
    if [ -n "$ASSIGNEE" ]; then
        CMD="$CMD --assignee \"$ASSIGNEE\""
    fi
    
    # Show summary before creating
    echo
    echo "=== Issue Summary ==="
    echo "Title: $ISSUE_TITLE"
    echo "Labels: ${LABELS:-None}"
    echo "Assignee: ${ASSIGNEE:-None}"
    echo
    read -p "Create this issue? (y/n): " CONFIRM
    
    if [[ $CONFIRM != "y" ]]; then
        echo "Issue creation cancelled."
        return 0
    fi
    
    # Execute the command
    echo "Creating GitHub issue..."
    eval $CMD
    
    if [ $? -eq 0 ]; then
        echo "GitHub issue created successfully!"
    else
        echo "Error: Failed to create GitHub issue."
        return 1
    fi
}

# Function to close GitHub issue
close_github_issue() {
    echo "=== Close GitHub Issue ==="
    
    # Check if GitHub CLI is installed
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI (gh) is not installed."
        echo "Please install it from: https://cli.github.com/"
        return 1
    fi
    
    # Check if user is authenticated
    if ! gh auth status &> /dev/null; then
        echo "Error: Not authenticated with GitHub CLI."
        echo "Please run 'gh auth login' first."
        return 1
    fi
    
    # Show open issues
    echo "Fetching open issues..."
    gh issue list --state open
    
    echo
    echo "Enter the issue number to close:"
    read ISSUE_NUMBER
    
    if [ -z "$ISSUE_NUMBER" ] || ! [[ "$ISSUE_NUMBER" =~ ^[0-9]+$ ]]; then
        echo "Error: Please enter a valid issue number."
        return 1
    fi
    
    echo "Enter a closing comment (optional):"
    read CLOSE_COMMENT
    
    # Close the issue
    echo "Closing issue #$ISSUE_NUMBER..."
    
    if [ -n "$CLOSE_COMMENT" ]; then
        gh issue close $ISSUE_NUMBER --comment "$CLOSE_COMMENT"
    else
        gh issue close $ISSUE_NUMBER
    fi
    
    if [ $? -eq 0 ]; then
        echo "Issue #$ISSUE_NUMBER closed successfully!"
    else
        echo "Error: Failed to close issue #$ISSUE_NUMBER."
        return 1
    fi
}

# Function to close issues after successful merge
close_issues_after_merge() {
    local TAG_NAME="$1"
    local BRANCH_NAME="$2"
    
    echo "=== Close Issues After Merge ==="
    echo "Looking for issues related to branch: $BRANCH_NAME"
    
    # Check if GitHub CLI is installed
    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI not found. Skipping issue closure."
        return 1
    fi
    
    # Check if user is authenticated
    if ! gh auth status &> /dev/null; then
        echo "Not authenticated with GitHub. Skipping issue closure."
        return 1
    fi
    
    # Show all open issues first
    echo "Fetching all open issues..."
    gh issue list --state open --limit 20
    
    if [ $? -ne 0 ]; then
        echo "Error fetching issues. Skipping issue closure."
        return 1
    fi
    
    echo
    echo "=== Issues potentially related to branch '$BRANCH_NAME' ==="
    
    # Search for issues that might be related to the branch
    echo "Searching for issues mentioning '$BRANCH_NAME'..."
    RELATED_ISSUES=$(gh issue list --state open --search "$BRANCH_NAME" --json number,title --jq '.[] | "\(.number): \(.title)"' 2>/dev/null)
    
    if [ -n "$RELATED_ISSUES" ]; then
        echo "Found issues potentially related to branch '$BRANCH_NAME':"
        echo "$RELATED_ISSUES"
        echo
        echo "Suggested issues to close based on branch name:"
        SUGGESTED_NUMBERS=$(echo "$RELATED_ISSUES" | cut -d':' -f1 | tr '\n' ' ')
        echo "Suggested issue numbers: $SUGGESTED_NUMBERS"
    else
        echo "No issues found specifically mentioning branch '$BRANCH_NAME'"
    fi
    
    echo
    echo "Select issues to close:"
    echo "- Enter issue numbers separated by spaces (e.g., '1 5 7')"
    echo "- Enter 'suggested' to use suggested issues: $SUGGESTED_NUMBERS"
    echo "- Enter 'skip' to skip issue closure"
    read ISSUES_TO_CLOSE
    
    # Handle different input options
    if [ "$ISSUES_TO_CLOSE" = "skip" ] || [ -z "$ISSUES_TO_CLOSE" ]; then
        echo "Skipping issue closure."
        return 0
    elif [ "$ISSUES_TO_CLOSE" = "suggested" ]; then
        if [ -n "$SUGGESTED_NUMBERS" ]; then
            ISSUES_TO_CLOSE="$SUGGESTED_NUMBERS"
            echo "Using suggested issues: $ISSUES_TO_CLOSE"
        else
            echo "No suggested issues available. Skipping issue closure."
            return 0
        fi
    fi
    
    # Generate automatic closing message with branch info
    CLOSING_MESSAGE="Resolved in release $TAG_NAME (merged from branch: $BRANCH_NAME)"
    echo "Default closing comment: '$CLOSING_MESSAGE'"
    echo "Enter custom closing comment (or press Enter to use default):"
    read CUSTOM_CLOSE_COMMENT
    
    if [ -n "$CUSTOM_CLOSE_COMMENT" ]; then
        CLOSING_MESSAGE="$CUSTOM_CLOSE_COMMENT"
    fi
    
    # Ask if user wants to test mode or actually close issues
    echo
    echo "Choose execution mode:"
    echo "1. Actually close issues on GitHub"
    echo "2. Test mode (simulate closure without making changes)"
    read -p "Select mode (1 or 2): " EXECUTION_MODE
    
    if [ "$EXECUTION_MODE" = "2" ]; then
        echo
        echo "🎭 TEST MODE: Simulating issue closure..."
        echo "Issues would be closed with message: '$CLOSING_MESSAGE'"
        
        # Simulate closing each specified issue
        for ISSUE_NUM in $ISSUES_TO_CLOSE; do
            if [[ $ISSUE_NUM =~ ^[0-9]+$ ]]; then
                echo "🔄 [SIMULATION] Closing issue #$ISSUE_NUM..."
                sleep 0.5  # Brief pause for realism
                echo "✅ [SIMULATION] Issue #$ISSUE_NUM would be closed successfully!"
            else
                echo "⚠️  [SIMULATION] Invalid issue number: $ISSUE_NUM (would be skipped)"
            fi
        done
        
        echo
        echo "🎉 TEST MODE COMPLETED: No actual changes were made to GitHub!"
        echo "📝 Summary of what would have happened:"
        echo "   - Message: '$CLOSING_MESSAGE'"
        echo "   - Issues that would be closed: $ISSUES_TO_CLOSE"
    else
        # Actually close each specified issue
        echo "Closing issues with message: '$CLOSING_MESSAGE'"
        for ISSUE_NUM in $ISSUES_TO_CLOSE; do
            if [[ $ISSUE_NUM =~ ^[0-9]+$ ]]; then
                echo "Closing issue #$ISSUE_NUM..."
                
                if gh issue close $ISSUE_NUM --comment "$CLOSING_MESSAGE"; then
                    echo "✅ Issue #$ISSUE_NUM closed successfully!"
                else
                    echo "❌ Failed to close issue #$ISSUE_NUM"
                fi
                
                sleep 1  # Brief pause between closures
            else
                echo "⚠️  Invalid issue number: $ISSUE_NUM (skipping)"
            fi
        done
    fi
    
    echo "Issue closure process completed for branch '$BRANCH_NAME'!"
}

# Main execution function
main() {
    while true; do
        show_menu
        read -p "Please select an option (1-6): " choice
        
        case $choice in
            1) merge_feature_branch ;;
            2) merge_fix_branch ;;
            3) reset_option ;;
            4) create_github_issue ;;
            5) close_github_issue ;;
            6) echo "Exiting script. Goodbye!" ; exit 0 ;;
            *) echo "Invalid option. Please select 1-6." ;;
        esac
        
        echo
        read -p "Press Enter to return to main menu..."
    done
}

# Start the script by calling main function
main
