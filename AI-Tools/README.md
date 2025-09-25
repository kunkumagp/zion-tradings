# AI-Tools Directory

This directory contains AI assistance tools and context files for the inventory management project.

## 📁 Files in this folder:

1. **AI-prompt**: Main project context file (markdown format)
   - Contains project overview, database structure, current status
   - Instructions and context for AI assistance
   - Focus on current project state (not history)

2. **application-updates**: Application changes log (markdown format)
   - Tracks all application code changes and features
   - Records files modified, features added
   - AI maintains this automatically

3. **database-updates**: Database changes log (markdown format)
   - Tracks all database structure and data changes
   - Records migrations, seeds, table modifications
   - AI maintains this automatically

4. **user-prompt.txt**: Your input file (simple text format) 
   - Write your ideas, requests, and prompts here
   - Simple text format - no markdown needed
   - Edit this with any text editor
   - AI reads this as your current request

5. **run-prompt.sh**: Script that loads all context files for AI
   - Displays project context + app changes + db changes + your request
   - Run with: `run-prompt` (if alias is set up)

6. **setup-alias.sh**: One-time setup for easy access

## 🚀 Quick Setup & Usage

1. **First time setup** (run once):
   ```bash
   chmod +x AI-Tools/setup-alias.sh
   ./AI-Tools/setup-alias.sh
   # Follow instructions to set up `run-prompt` command
   ```

2. **Write your request**:
   ```bash
   nano AI-Tools/user-prompt.txt
   # Write what you want AI to help with (plain text)
   ```

3. **Load context for AI**:
   ```bash
   run-prompt
   # Shows AI both project context and your request
   ```

## 💡 Workflow:
1. Edit `user-prompt.txt` with your ideas/requests
2. Run `run-prompt` to load complete context
3. AI gets project context + application history + database history + your request  
4. After completion:
   - AI updates application changes in `application-updates`
   - AI updates database changes in `database-updates`
   - AI may update project context in `AI-prompt`
5. Clear/update `user-prompt.txt` for next request

## 📋 File Structure Benefits:
- **Separation of concerns**: Context vs. Application vs. Database changes
- **Focused tracking**: Easier to find specific types of changes
- **Cleaner organization**: Each file has a single responsibility
- **Better AI assistance**: More organized context for better responses

## Notes

- This entire folder is ignored by git (.gitignore)
- Files in this folder are for personal/local use only
- Update AI-prompt as your project evolves
- Scripts work from any location in the project