# Authorization

Authorization in Lea5 is done with the gem [CanCanCan](https://github.com/CanCanCommunity/cancancan).

The defined rights can be be found in the file [`app/models/ability.rb`](../../app/models/ability.rb).

For each controller, we check the rights of the current user, and continue or throw accordingly.

The admin role is defined as the group `rezoleo`, given on our [SSO](./authentication.md). 
