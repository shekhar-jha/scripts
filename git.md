
## Credential manager

Git typically uses a simple key or user id & password for authenticating users. In case the authentication involves more complex authentication flows (like OAuth & other complext MFA use-cases at Team Studio, Bitbucket & github), a custom credential manager can be plugged in. A popular one is from Microsoft called [Git Credential Manager for Windows](https://github.com/Microsoft/Git-Credential-Manager-for-Windows) and [Git Credential Manager for Mac & Linux](https://github.com/microsoft/Git-Credential-Manager-for-Mac-and-Linux).

### Clearing cache

By design the credential manager caches the credential. But in case the credential has changed or invalid credential was provided (including cancelling the popup), the credential must be cleared.

```console
$ git credential-manager clear
Target Url:
https://<github server>/path/to/project.git
```

## Certificate Authentication

In some cases, git repository may be setup such that it either requires mutually authenticated SSL or supports mutually authenticated SSL as first step and if that fails switches to SAML/OpenID Connect/OAuth authentication (this allows support for both SSO for web and mutual auth SSL for command line tools).
In such scenario, it is important for the tools to support mutually authenticated SSL. The client certificate for mutually authenticated SSL may exist as a file or in a corporate world may be stored in appropriate repository on device (Mac - Keychain, Windows - Cert store).

## Windows

On windows, this is achieved by using Windows SSL libraries (typically an option while installing the **Git for Windows** client version 2.14 and later). You can confirm whether the git is using the correct SSL libraries by executing the following command

```console
$ git config --get http.sslbackend
schannel
```
In case the value above is `openssl`, change the value as follows
```
git config --global http.sslBackend schannel
```
**Note** : The `--global` will change setting for all the git repositories on the machine. If you want to limit change to your repository, try using `--local`.

## Mac

git on Mac supports certificate files for authentication. But there is no official support for keychain. In worst case scenario, you can use a specific version of git (from brew) that integrates with curl that can integrate with Keychain and use the certificate stored in keychain.

### Setup

1. Install curl
```console
$ brew install curl
```
2. Install git
```console
$ brew install --with-curl https://raw.githubusercontent.com/Homebrew/homebrew-core/a86ae8fc2b24001b3c6460a46dbfc6e323d2a4d1/Formula/git.rb
```
3. Check installed git
```console
$ /usr/local/bin/git --version
```
4. Check keychain for any website specific Internet password already stored (for example if git location is https://example.com/project1/project1.git, the keychain may have an internet password stored against https://example.com). If so, delete the same otherwise the tool is going to use that without prompting for new password.
5. Execute the command as follows to clone the repository. In case there is no existing password in the keychain, the system will prompt user for user id & password and then complete the execution.
```console
$ /usr/local/bin/git clone https://example.com/project1/project1.git
```

# Command Tricks

## Commitment history for remote branch

```
git for-each-ref --format='%(committerdate) %09 %(authorname) %09 %(refname)' | sort
```

## Prune dead/deleted remote branches
```
git remote update origin --prune
```

## Resolve conflicts
There are multiple scenarios in which conflict can happen. This section provides some of the approaches that should be used.
### Parent branch updated
```
original_branch: A – B  – F  
                      \
new_branch:            C – D – E <-- rebase
```
In case the original branch has been updated after the initial branch, depending on the changes, conflict may arise in case of rebase before merging to original branch. In such a scenario the following steps can be followed.

1. Start the rebase by specifying the original branch `git checkout new_branch; git rebase original_branch`. This should display all the files that is resulting in conflict
    ```
    git rebase dev
     First, rewinding head to replay your work on top of it...
     Applying: Commit comment
     .git/rebase-apply/patch:134: trailing whitespace.

     warning: 1 line adds whitespace errors.
     error: Failed to merge in the changes. 
     Using index info to reconstruct a base tree...
     M       folder1/folder2/file1.txt              
     Falling back to patching base and 3-way merge...
     Auto-merging folder1/folder2/file1.txt
     CONFLICT (content): Merge conflict in folder1/folder2/file1.txt <----------------------------
     Patch failed at 0001 Commit comment.
     The copy of the patch that failed is found in: .git/rebase-apply/patch

     Resolve all conflicts manually, mark them as resolved with
     "git add/rm <conflicted_files>", then run "git rebase --continue".
     You can instead skip this commit: run "git rebase --skip".
     To abort and get back to the state before "git rebase", run "git rebase --abort".
    ```
2. Run through the following steps for each of the file identified with conflict
     1. Fix the conflict i.e. find the area in file that has `<<<<<<<` and `>>>>>>>` and fix the content between the two and remove all the line that contain added content like `<<<<<<<`,  `>>>>>>>` & `=======`.
     2. Add the updated file explicitly using `git add <conflict file>` to ensure that git understands you have fixed conflict
3. Run `git rebase --continue` to continue the rebasing process. In case additional conflicts are flagged, execute step 2 to fix the changes
4. At this time pull the branch and identify the conflict files.
    ```
    $ git pull
      Auto-merging folder1/folder2/file1.txt
      CONFLICT (content): Merge conflict in folder1/folder2/file1.txt
      Automatic merge failed; fix conflicts and then commit the result.
    ```
5. Fix the conflicts identified and run `git add <conflict file>`
6. Commit the changes `git commit -m 'comment'` and push the update `git push`

# Very Large Repo

## Initial clone

```
git clone git@github.com:MicrosoftDocs/azure-docs.git --branch master --single-branch --depth 1
```

## Fetch/update

Use the date which is 1 day before last update (can be figured out by using `git log HEAD origin/master` to identify when )
```
git fetch --shallow-since="2021-11-21"
git merge
```
