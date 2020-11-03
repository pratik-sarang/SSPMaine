/***************************************************************************************************************************
*   Type         :   
*   Name         :   SspJsonFlowNamePicklist
*   Created By   :   Narapa Naidu Pulipati
*   Created Date :   05/25/2020
*   Description  :   Class to add rows to Flow Name picklist property configured in metafile of 
*                    jsonFlowContainer component (lwc)
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Narapa Naidu Pulipati     05/25/2020      Initial Version
*****************************************************************************************************************************/
public with sharing class SspJsonFlowNamePicklist  extends VisualEditor.DynamicPickList{

    /*Name: getDefaultValue
    * Description: To add a blank row as default value for Flow Name picklist property
    *              configured in metafile of jsonFlowContainer component (lwc)
    * Params:
    * returnType: A default row on the Flow Name picklist        
    */
    public override VisualEditor.DataRow getDefaultValue(){
        return new VisualEditor.DataRow('', '');
    }

    /*Name: getValues
    * Description: Gets options for the Flow Name picklist property configured in metafile of 
    *              jsonFlowContainer component (lwc), from which administrator can chose Navigation flow detail 
    *              metadata records having IsJsonBasedFlow__c field set to true
    * Params: 
    * returnType: List of rows for Flow Name picklist from which administrator
    *             can chose a Navigation Flow Detail that can be rendered on the UI 
    *             from jsonFlowContainer component. 
    */
    public override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows rows = new VisualEditor.DynamicPickListRows();
        List<NavFlowDetail__mdt> jsonMetaList = [SELECT DeveloperName, MasterLabel, FlowName__c, FlowDisplayName__c
                    FROM NavFlowDetail__mdt
                    WHERE IsJsonBasedFlow__c = true
                    ORDER BY FlowDisplayName__c];
        rows.addRow(this.getDefaultValue());
        if(null != jsonMetaList){
            for(NavFlowDetail__mdt jsonMeta : jsonMetaList){
                rows.addRow(new VisualEditor.DataRow(jsonMeta.FlowDisplayName__c, jsonMeta.DeveloperName));
            }
        }
        return rows;
    }
    
}