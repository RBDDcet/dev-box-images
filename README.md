# Dev Box Images

This repo contains custom images to be used with [Microsoft Dev Box](https://techcommunity.microsoft.com/t5/azure-developer-community-blog/introducing-microsoft-dev-box/ba-p/3412063).  It demonstrates how to create custom images with pre-installed software using [`az bake`][az-bake] (which uses [Packer](https://www.packer.io/) under the hood) and shared them via [Azure Compute Gallery][az-gallery].

## Images

| Name      | OS                             | Additional Software                                          |
| --------- | ------------------------------ | -------------------------------------------------------------|
| VS2022Box | [Windows 11 Enterprise][win11] | [Visual Studio 2022](https://visualstudio.microsoft.com/vs/) |
| VSCodeBox | [Windows 11 Enterprise][win11] |                                                              |

Use [this form](/../../issues/new?assignees=colbylwilliams&labels=image&template=request_image.yml&title=%5BImage%5D%3A+) to request a new image.

### Preinstalled Software

The following software is installed on all images. Use [this form](/../../issues/new?assignees=colbylwilliams&labels=software&template=request_software.yml&title=%5BSoftware%5D%3A+) to request additional software.

|     |     |     |
| --- | --- | --- |
| [Microsoft 365 Apps](https://www.microsoft.com/en-us/microsoft-365/products-apps-services) | [Visual Studio Code](https://code.visualstudio.com/) | [GitHub Desktop](https://desktop.github.com/) |
| Git | [Firefox](https://www.mozilla.org/en-US/firefox/new/) | [Google Chrome](https://www.google.com/chrome/) |
| [Chocolatey](https://chocolatey.org/) | [.Net](https://dotnet.microsoft.com/en-us/) (versions 3.1, 5.0, 6.0, 7.0) | [Python](https://www.python.org/) (version 3.10.5) |
| [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli) (2.37.0) | [Az PowerShell module](https://docs.microsoft.com/en-us/powershell/azure/what-is-azure-powershell) | |

---

## Usage 
#####- [Github specific specific](#to-get-started---github)
#####- [Azure DevOps specific directions](#to-get-started---azure-devops)

---
### ___To get started - Github___

#### 1. [Fork][fork] this repository

#### 2. Create a Service Principal (or use an existing one)

```sh
az ad sp create-for-rbac -n MyUniqueName
```

output:

```json
{
   "appId": "<GUID>",
   "displayName": "MyUniqueName",
   "password": "<STRING>",
   "tenant": "<GUID>"
}
```

#### 3. Create three new [repository secrets][repo-secrets] with the values output above

- `AZURE_CLIENT_ID` _(appId)_
- `AZURE_CLIENT_SECRET` _(password)_
- `AZURE_TENANT_ID` _(tenant)_

#### 4. [Install][az-bake-install] the `az bake` Azure CLI extension

#### 5. Create a [sandbox][az-bake-sandbox], providing an [Azure Compute Gallery][az-gallery] and the Service Principal's ID (created above)

```sh
az bake sandbox create --name MySandbox --gallery MyGallery --principal 00000000-0000-0000-0000-000000000000
```

> _**Important:** The GUID passed in for the `--principal` argument is the principal's Id NOT its AppId from the output above. To get the principal's ID, run:_  `az ad sp show --id appId -o tsv --query id`

#### 6. Setup the repo for use with `az bake`

```sh
az bake repo setup --repo /path/to/repo --sandbox MySandbox --gallery MyGallery
```

#### 7. Commit and push your changes

This will kick off a GitHub Actions workflow to build your custom images.  Once the workflow is finished, you can continue to monitor the image builds:

```sh
az bake image logs --sandbox MySandbox --name VSCodeBox
```
---

### ___To get started - Azure DevOps___

#### 1. Azure Devops UI: [Import][az-devops-import] this repository to the project

#### 2. Create a Service Principal (or use an existing one)

```sh
az ad sp create-for-rbac -n MyUniqueName
```

output:

```json
{
   "appId": "<GUID>",
   "displayName": "MyUniqueName",
   "password": "<STRING>",
   "tenant": "<GUID>"
}
```

#### 3. Azure Devops UI: Create a pipeline by importing the azure-pipelines.yml file
- Open Pipelines and select "Create Pipeline"
- Select repo
- Select "Existing Azure Pipelines YAML file"
- Select branch, and the "/azure-pipelines.yml"

#### 4. Azure Devops UI: Create three new [secret variables][az-devops-secrets] with the values from the Service Principal

- `AZURE_CLIENT_ID` _(appId)_
- `AZURE_CLIENT_SECRET` _(password)_
- `AZURE_TENANT_ID` _(tenant)_

#### 4. [Install][az-bake-install] the `az bake` Azure CLI extension

#### 5. Create a [sandbox][az-bake-sandbox], providing an [Azure Compute Gallery][az-gallery] and the Service Principal's ID (created above)

```sh
az bake sandbox create --name MySandbox --gallery MyGallery --principal 00000000-0000-0000-0000-000000000000
```

> _**Important:** The GUID passed in for the `--principal` argument is the principal's Id NOT its AppId from the output above. To get the principal's ID, run:_  `az ad sp show --id appId -o tsv --query id`

#### 6. Setup the repo for use with `az bake`

```sh
az bake repo setup --repo /path/to/repo --sandbox MySandbox --gallery MyGallery
```
> This will command will customize the bake.yml file with the specific information for the sandbox. 

#### 7. Commit and push your changes

This will kick off the Azure Pipeline to build your custom images.  Once the pipeline is finished, you can continue to monitor the image builds:

```sh
az bake image logs --sandbox MySandbox --name VSCodeBox
```



# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit <https://cla.opensource.microsoft.com>.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

[win11]:https://www.microsoft.com/en-us/microsoft-365/windows/windows-11-enterprise
[fork]:https://docs.github.com/en/get-started/quickstart/fork-a-repo
[az-gallery]:https://docs.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries?tabs=azure-cli
[az-bake]:https://github.com/colbylwilliams/az-bake
[az-bake-install]:https://github.com/colbylwilliams/az-bake#install
[az-bake-sandbox]:https://github.com/colbylwilliams/az-bake#sandbox
[repo-secrets]:https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository
[az-devops-import]:https://learn.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops
[az-devops-secrets]:https://learn.microsoft.com/en-us/azure/devops/pipelines/process/set-secret-variables?view=azure-devops&tabs=yaml%2Cbash#secret-variable-in-the-ui