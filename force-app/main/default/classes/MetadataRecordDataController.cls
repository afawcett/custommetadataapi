/**
 * Copyright (c) 2017, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public with sharing class MetadataRecordDataController {

    @AuraEnabled
    public static SObject loadRecord(String fullName, String fields) {
        // TODO: Protected against SOQL injection etc...
        // TODO: Better unhandled excepiton handling, looks like these have to be wrapped in AuraHandledException's
        List<String> fullNameParts = fullName.split('\\.');
        List<SObject> records = Database.query('select ' + fields + ' from ' + fullNameParts[0] + '__mdt where DeveloperName = \'' + fullNameParts[1] + '\'');
        if(records.size()==0) {
            throw new AuraHandledException('Record not found');
        }
        return records[0];        
    } 
    
    @AuraEnabled
    public static String upsertRecord(SObject record) {        
        return CustomMetadata.Operations
            .callback(
                MetadataDeployment__e.getSObjectType(),
                MetadataDeployment__e.DeploymentId__c, 
                MetadataDeployment__e.Result__c)
            .enqueueUpsertRecords(
                new List<SObject> { record })
            .deployId;
    }
}