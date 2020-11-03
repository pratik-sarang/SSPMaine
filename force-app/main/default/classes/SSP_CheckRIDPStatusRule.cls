public with sharing class SSP_CheckRIDPStatusRule extends BasicNavFlowRule {

    public override boolean isRequired(Context ctx, ContextData ctxData) {
        String selectedrole=SSP_Utility.getSelectedRole();

        return (selectedrole =='Contact_Center_View_and_Edit' || selectedrole == 'Contact_Center_View_Only') ? true : false;
    }
}