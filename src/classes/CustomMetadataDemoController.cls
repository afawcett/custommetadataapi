public with sharing class CustomMetadataDemoController {
    
    public WidgetPreset__mdt Record {get;set;}
    
    public String DeployId {get;set;}    
    
    public String DeployResult {get;set;}
    
    public PageReference init() {
        
        Record = [select DeveloperName, Label, DefaultNotification__c, Alias__c 
                    from WidgetPreset__mdt
                    where DeveloperName = 'BluetoohToothbrush'];
                    
        return null;
    }
    
    public PageReference save() {
                        
        DeployId = 
            CustomMetadata.Operations
                .callback(
                    MetadataDeployment__e.getSObjectType(),
                    MetadataDeployment__e.DeploymentId__c, 
                    MetadataDeployment__e.Result__c)
                .enqueueUpsertRecords(
                    new List<SObject> { Record })
                .deployId;
                        
        return null;
    }
    
    public PageReference saveHandler() {

        DeployId = null;                
        CustomMetadata.SaveRecordResult result = 
            (CustomMetadata.SaveRecordResult) 
                JSON.deserialize(DeployResult, CustomMetadata.SaveRecordResult.class);
        if(!result.success) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, result.message));            
        }            
        
        return null;
    }
}