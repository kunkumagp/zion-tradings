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
    echo "4. Exit"
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

# Main execution function
main() {
    while true; do
        show_menu
        read -p "Please select an option (1-4): " choice
        
        case $choice in
            1) merge_feature_branch ;;
            2) merge_fix_branch ;;
            3) reset_option ;;
            4) echo "Exiting script. Goodbye!" ; exit 0 ;;
            *) echo "Invalid option. Please select 1-4." ;;
        esac
        
        echo
        read -p "Press Enter to return to main menu..."
    done
}

# Start the script by calling main function
main
