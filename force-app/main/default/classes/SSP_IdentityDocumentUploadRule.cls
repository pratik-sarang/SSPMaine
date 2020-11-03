public with sharing class SSP_IdentityDocumentUploadRule extends BasicNavFlowRule{
  public override boolean isRequired(Context ctx, ContextData ctxData) {
      String selectedrole=SSP_Utility.getSelectedRole();

        return (selectedrole=='Contact_Center_View_and_Edit' || selectedrole=='Mail_Center_Worker' || selectedrole=='Mail_Center_Supervisor' || selectedrole=='Contact_Center_View_Only') ? false : true;
    }
}