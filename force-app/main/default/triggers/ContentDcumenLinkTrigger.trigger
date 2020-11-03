trigger ContentDcumenLinkTrigger on ContentDocumentLink (after insert) {
    
   FileUtility.isValidDocumenLink(Trigger.New);
   
}