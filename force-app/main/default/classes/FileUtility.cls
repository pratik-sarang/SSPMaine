/* Class Name:FileUtility
* Description: Trigger Handler for ContentVersionTrigger. This class holds the logic to restrict the upload of files with certain extensions
*/
public with sharing class FileUtility{
    
    public static void isValidDocumenLink(List<ContentDocumentLink>  DocLinkList){
           set<string> fileExtIncludeSet = new set<string>();
            Set<Id> idList = new set<Id>();
            for(ContentDocumentLink doclink :DocLinkList){
                idList.add(doclink.contentdocumentid);
            }
        
            for(File_Extension_Setting__c exten : File_Extension_Setting__c.getAll().values()){
                if(exten.Is_Allowed__c){
                    fileExtIncludeSet.add(exten.Value__c);
                }
            }
                
            for (ContentDocument f :[SELECT Id, FileExtension FROM ContentDocument where Id IN:idList]) { 
                    String strFileExtension = f.FileExtension.toLowerCase(); 
                   /* if( ! fileExtIncludeSet.contains(strFileExtension)){
                        if(!Test.isRunningTest()) {
                            DocLinkList[0].addError(System.Label.RE_FileExtentionError); 
                        }
                    }*/ // Force Reviewer Fixes : Kojashree
                     if(!fileExtIncludeSet.contains(strFileExtension) && !Test.isRunningTest() ){
                        
                            DocLinkList[0].addError(System.Label.RE_FileExtentionError); 
                        
                    }
            }
    }
}