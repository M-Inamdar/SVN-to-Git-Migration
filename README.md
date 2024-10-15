Version control is a crucial component of software development. Over the years, many teams have transitioned from Subversion (SVN) to Git due to its distributed nature, robust branching capabilities, and widespread adoption. If your organization is still using SVN and plans to migrate to Git with Gerrit for enhanced code review and collaboration, this guide will lead you through the entire process.

Why Migrate from SVN to Git-Gerrit?

Distributed Version Control:

Git allows each developer to have a full copy of the repository, enabling offline work and faster operations compared to SVN’s centralized model.

Advanced Branching and Merging:

Git's branching model is more flexible and efficient, making it easier to manage feature development, hotfixes, and releases.

Integration with Modern Tools:

Git integrates seamlessly with modern CI/CD pipelines and code review tools like Gerrit, which enhances collaboration and code quality.

Improved Performance:

Git is optimized for performance, handling large repositories and complex histories more efficiently than SVN.

Planning the Migration

Migrating from SVN to Git-Gerrit requires careful planning to ensure a smooth transition. Key considerations include:

Repository Structure Analysis:

Understand your SVN repository structure. Is it standard with trunk, branches, and tags, or does it have a custom layout?

Preserve History:

Decide if you need to preserve the entire commit history during migration. Preserving history is crucial for traceability and auditing.

Author Mapping:

In SVN, authorship is tied to SVN usernames. You'll need to map these to corresponding Git users using an authors.txt file.

Gerrit Integration:

Plan how you’ll integrate the migrated Git repository with Gerrit for code reviews. Ensure your team is familiar with Gerrit workflows.

Migration Steps

Required Tools and Credentials

Before starting, ensure you have the following tools installed and credentials handy:

Git: The distributed version control system.

Subversion (SVN): For interacting with the existing SVN repository.

git-svn: A Git command to interact with SVN repositories.

Handshake: Ensure the ssh key or HTTP Credentials for push and clone user.

Note: Recommendation for SSH key generation, how-to-generate-ed25519-ssh-key

You can install these tools on a Unix-like system using:

sudo apt-get update

sudo apt-get install git subversion git-svn

Note: If you do not have sudo access, ask your IT team to download for you.

Create an authors.txt File

You'll need to map SVN users to their corresponding Git identities. Create an authors.txt file with the following format:

svn-username = Full Name <email@example.com>

Example:

yohan_doel = Yohan Doel <yohan.doel@example.com>

stive_smith = Stive Smith <stive.smith@example.com>

Clone the SVN Repository to Git-Gerrit

If your SVN repository follows the standard layout (`trunk`, branches, tags), use the following command:

git svn clone --stdlayout --no-metadata --authors-file=authors.txt <svn-repo-url> my_git_gerrit_repo

--stdlayout: Assumes the standard SVN structure.

--no-metadata: Avoids adding SVN metadata to Git commit messages.

--authors-file=authors.txt: Maps SVN authors to Git authors.

For custom layouts, you can specify the trunk, branches, and tags paths explicitly:

git svn clone --trunk=/path/to/trunk --branches=/path/to/branches --tags=/path/to/tags --no-metadata --authors-file=authors.txt <svn-repo-url> my_git_repo

Command Breakdown

git svn clone: This command initializes a new Git repository and imports the history from an SVN repository. It’s specifically designed for interacting with Subversion repositories using Git.

`--trunk=/path/to/trunk`: Specifies the path to the trunk directory in the SVN repository. This path should point to the main development branch in SVN. For example, in a typical SVN repository structure like http://svn.example.com/repo/trunk, you’d set this as --trunk=/trunk.

`--branches=/path/to/branches`: Specifies the path to the branches directory in the SVN repository. This option maps SVN branches into Git branches. For a repository with branches at http://svn.example.com/repo/branches, this would be --branches=/branches.

`--tags=/path/to/tags`: Specifies the path to the tags directory in the SVN repository. This option maps SVN tags into Git tags. In SVN, tags are generally treated like branches, so this option helps git svn recognize them as tags in Git.

`--no-metadata`: Tells git svn to avoid embedding SVN-specific metadata (like the SVN revision number) into Git commit messages. By default, git svn adds this metadata to track the exact SVN revision for each Git commit, but if you’re doing a one-time migration and don’t need that information, --no-metadata can produce cleaner Git commit messages.

`--authors-file=authors.txt`: Specifies a file (`authors.txt`) that maps SVN usernames to Git usernames and email addresses. This file is necessary if you want the Git commits to display the correct author names and emails, as SVN often uses short usernames. The format of each line in this file is typically:

  svnusername = Full Name <email@example.com>

`<svn-repo-url>`: This is the URL to the SVN repository you want to clone. It can be an HTTP, HTTPS, or SVN protocol URL, depending on how your SVN repository is hosted.

`my_git_repo`: The directory name for the new Git repository. This is where the Git repository will be created, containing the imported SVN history and structure.

Example

If you had an SVN repository structured like this:

http://svn.example.com/project
├── trunk
├── branches
└── tags

You could run:

git svn clone --trunk=/trunk --branches=/branches --tags=/tags --no-metadata --authors-file=authors.txt http://svn.example.com/project my_git_repo

This command would:

Import the trunk as the main Git branch (`master` or main).

Convert each directory inside branches into a separate Git branch.

Convert each directory inside tags into a Git tag.

Apply author mappings from authors.txt for cleaner author data in Git.

Create a Git repository in the my_git_repo directory, which contains the entire history from SVN.

Convert SVN Branches to Git-Gerrit Branches

After cloning, SVN branches and tags need to be converted to Git-Gerrit branches and tags. Navigate to your Git-Gerrit repository:

cd my_git_repo

To create Git-Gerrit branches from SVN branches:

git for-each-ref --format='%(refname:short)' refs/remotes/origin/ | grep -v trunk | while read ref; do
git branch $ref refs/remotes/origin/$ref
git branch -d -r origin/$ref
done

This command is a bash one-liner designed to convert remote branches from an origin reference in Git into local branches and then delete those remote references. Let’s break down each part of it:

git for-each-ref --format='%(refname:short)' refs/remotes/origin/:

git for-each-ref: This command lists references in the Git repository, such as branches or tags.

--format='%(refname:short)': Specifies the output format, where %(refname:short) gives the short name of the reference, effectively listing only the branch names without the full path.

refs/remotes/origin/: Limits the references to those under refs/remotes/origin/, meaning all remote branches from the origin remote.

This part of the command lists all the remote branches under origin, outputting each one’s name (e.g., feature-branch, bugfix, etc.).

| grep -v trunk:

This pipes the list of branch names to grep.

grep -v trunk: Filters out any branches containing trunk in their name, which means it excludes trunk (or origin/trunk) from the list. -v inverts the match, so it removes lines containing "trunk" from the output.

| while read ref; do:

while read ref; do: This starts a loop that reads each branch name from the list and assigns it to the variable ref.

For each branch name in ref, the following commands within the loop are executed.

git branch $ref refs/remotes/origin/$ref:

This creates a new local branch with the name $ref (the branch currently being processed) from the corresponding remote branch refs/remotes/origin/$ref.

Essentially, it converts the remote branch into a local branch with the same name.

git branch -d -r origin/$ref:

This deletes the remote-tracking reference for the branch from origin.

-d -r indicates that it’s deleting (-d) a remote (-r) branch reference.

So, origin/$ref (the remote branch reference for the current branch) is deleted after the local branch is created.

done:

This closes the while loop. The loop will repeat for each branch reference in the list.

To convert SVN tags to Git-Gerrit tags:

git for-each-ref --format='%(refname:short)' refs/remotes/origin/tags | while read ref; do
git tag $ref refs/remotes/origin/tags/$ref
git branch -d -r origin/tags/$ref
done

This command is another bash one-liner that converts remote tags from an origin reference into local Git tags, and then deletes the corresponding remote references. It’s useful when you have tags in a remote repository that you want to convert to local tags and clean up the remote references afterward. Let’s break down each part:

git for-each-ref --format='%(refname:short)' refs/remotes/origin/tags:

git for-each-ref: Lists references in the Git repository, such as branches or tags.

--format='%(refname:short)': Specifies the output format, where %(refname:short) gives the short name of each reference. In this case, it lists just the tag names without the full path.

refs/remotes/origin/tags: Limits the references to those under refs/remotes/origin/tags, which means all the remote tags from the origin remote.

This part of the command outputs the names of all tags located under the origin/tags namespace.

| while read ref; do:

while read ref; do: Starts a loop that reads each tag name and assigns it to the variable ref.

For each tag name, the following commands within the loop are executed.

git tag $ref refs/remotes/origin/tags/$ref:

This creates a new local tag with the name $ref (the tag currently being processed) based on the remote tag reference refs/remotes/origin/tags/$ref.

In essence, it converts the remote tag from origin into a local tag with the same name.

git branch -d -r origin/tags/$ref:

This deletes the remote-tracking reference for the tag.

-d -r indicates that it’s deleting (-d) a remote (-r) reference.

So, origin/tags/$ref (the remote tag reference) is deleted after the local tag is created.

done:
This ends the while loop. The loop will continue to repeat for each tag reference in the list.
Push to Git-Gerrit Repository

Next, push the converted Git repository to your Gerrit server:

Add Gerrit Remote: Add your Gerrit repository as a remote in your local Git repository.
git remote add gerrit ssh://<username>@<gerrit-server>:<port>/<project-name>
This command adds a new remote to a local Git repository, specifically pointing to a Gerrit server. This remote is named gerrit and can be used to push code to a Gerrit repository.

Push All Branches to Gerrit:
git push gerrit master:master
This command is used to push the master branch from your local Git repository to the master branch on the remote repository called gerrit.

Push All Tags to Gerrit:
git push gerrit --tags

The command git push gerrit --tags is used to push all local tags from your Git repository to the remote repository called gerrit. 
This ensures that any tags you have created locally are also available in the remote repository
Note: Ensure that your Gerrit server is properly configured to receive pushes from Git. Gerrit will automatically create code reviews for new commits pushed to certain branches.

Verify the Migration

After the push, verify that:
All branches and tags are correctly migrated.
Commit history is intact and accurate.
Authors and commit messages are correctly mapped.
You can use Gerrit's UI to review the commits and branches.
Update Development Workflow
Educate your team on using Git and Gerrit. Key changes include:
Branching and Merging: Git's branching model is different from SVN, so make sure everyone understands how to create, switch, and merge branches.
Code Reviews in Gerrit: Ensure the team is familiar with Gerrit’s review process, including submitting changes, reviewing, and approving code.

Best Practices

Test the Migration: Before migrating the entire repository, run a test migration on a small or non-critical repository to identify potential issues.
Backup SVN Repository: Always back up your SVN repository before starting the migration.
Incremental Migration: If your repository is very large, consider migrating it in chunks (e.g., one branch at a time).
Automation: Automate the migration process where possible to minimize human error and ensure consistency.
Note: For automation refer my shell script SVN-to-Git-Migration.sh

IMP Inputs

Command for Git logs
git log –online

If you have the space in SVN Repository name, substitute them with %20
Example:
https://abc.ls.ege.ds/svn/svn/1500012_-_ABC DCE ECU s_to_g
https://abc.ls.ege.ds/svn/svn/1500012_-_ABC%20DCE%20ECU%20s_to_g

Conclusion
Migrating from SVN to Git-Gerrit is a significant step towards modernizing your development workflow. 
By following the steps outlined in this guide, you can ensure a smooth transition while preserving your project history and enhancing your team's collaboration and code quality. 
With careful planning and execution, your migration will set the stage for a more efficient and scalable version control system.
