#!/bin/bash

export RESOURCE_GROUP="thanh-rg"
export KEY_VAULT_NAME="thanhkeyvault"
export USER_ASSIGN_IDENTITY="thanh-identity"
export SUBSCRIPTION_ID=$(az account show --query id --output tsv)

export IDENTITY_CLIENT_ID=$(az identity show -g $RESOURCE_GROUP -n $USER_ASSIGN_IDENTITY --query clientId --output tsv)
echo "Identity Client Id: $IDENTITY_CLIENT_ID"

export KEYVAULT_TENANT_ID=$(az keyvault show  -g $RESOURCE_GROUP -n $KEY_VAULT_NAME --subscription $SUBSCRIPTION_ID -o tsv --query properties.tenantId)
echo "Key Vault Tenant Id: $KEYVAULT_TENANT_ID"

cat <<EOF | kubectl apply -f -
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-thanhkeyvault-secret-provider
  namespace: thanhnc85
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"    # Set to true for using managed identity
    userAssignedIdentityID: $IDENTITY_CLIENT_ID      # If empty, then defaults to use the system assigned identity on the VM
    keyvaultName: $KEY_VAULT_NAME
    cloudName: ""                   # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: DBSERVER
          objectType: secret        # object types: secret, key, or cert
          objectVersion: ""         # [OPTIONAL] object versions, default to latest if empty
        - |
          objectName: DBUSERNAME
          objectType: secret
          objectVersion: ""
        - |
          objectName: DBPASSWORD
          objectType: secret
          objectVersion: ""
        - |
          objectName: DBNAME
          objectType: secret
          objectVersion: ""
    tenantId: $KEYVAULT_TENANT_ID           # The tenant ID of the key vault
  secretObjects:                              # [OPTIONAL] SecretObjects defines the desired state of synced Kubernetes secret objects
  - data:
    - key: mysql-server                        # data field to populate
      objectName: DBSERVER                   # name of the mounted content to sync; this could be the object name or the object alias
    - key: mysql-user-username
      objectName: DBUSERNAME
    - key: mysql-user-password
      objectName: DBPASSWORD
    - key: mysql-database-name
      objectName: DBNAME
    secretName: springapp-keyvault-secret                     # name of the Kubernetes secret object
    type: Opaque
EOF