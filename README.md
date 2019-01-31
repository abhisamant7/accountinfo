# AccountStore
Ethereum smart contract that can record a user's public address as having granted permission to another user’s public address. Assume  that the contract will eventually be used by a DApp where users can grant permission and other users can check if they have permission for some entity.
Use the setGrantAddress() to allow public addresses to have access to the msg.sender account. Use removeGrantee() to revoke the access privileges again from the msg.sender account.
Use checkPermission() (input address in the msg.sender) from any account to check whether the access is provided to any other valid account.
getGrantAddresses() to see all those accounts to which access has been granted.
accessableAddresses() to see all those those accounts to which the msg.sender account has access to.
