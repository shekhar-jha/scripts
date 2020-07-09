
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

