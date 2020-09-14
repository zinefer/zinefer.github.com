# My personal website

## Install notes

```
git clone git@github.com:zinefer/hugo-carbon.git themes/carbon
npm install postcss-cli
npm install autoprefixer
npm install postcss-easing-gradients
```

## Github Actions Setup:

```
az ad sp create-for-rbac --id "$APPNAME" --role contributor --scopes /subscriptions/$SUBSCRIPTIONID/resourceGroups/$RESOURCEGROUP --sdk-auth

az role assignment create --role "Storage Blob Data Contributor" --assignee (az ad sp list --display-name "$APPNAME" --query "[].appId" -o tsv) --scope /subscriptions/$SUBSCRIPTIONID/resourceGroups/$RESOURCEGROUP/providers/Microsoft.Storage/storageAccounts/$STORAGEACCOUNT
```