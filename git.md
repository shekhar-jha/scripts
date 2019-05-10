
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

git on Mac supports certificate files for authentication. But there is no official support for keychain. In worst case scenario, you can use a specific version of git (from brew) that integrates with 
