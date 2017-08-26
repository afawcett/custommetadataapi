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

@IsTest
private class CustomMetadataTest {
        
    @IsTest
    private static void whenUpsertingByFieldMapSendsEvent() {

        // Given
        MockPlatform mockPlatform = new MockPlatform();
        mockPlatform.metadataEnqueueDeploymentResult = new Metadata.DeployResult();
        mockPlatform.metadataEnqueueDeploymentResult.details = new Metadata.DeployDetails();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentFailures = new List<Metadata.DeployMessage>();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses = new List<Metadata.DeployMessage>();
        Metadata.DeployMessage deploySuccess = 
            (Metadata.DeployMessage) JSON.deserialize(
                '{"fullName":"Account","success":true}', Metadata.DeployMessage.class);
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses.add(deploySuccess);
        mockPlatform.eventBusPublishResponse = 
            (List<Database.SaveResult>) JSON.deserialize(
                '[{"id":"e00xx000000001TAAQ","success":true,"errors":[],"warnings":[]}]', List<Database.SaveResult>.class);
        CustomMetadata.Platform = mockPlatform;
        List<Map<SObjectField, Object>> records = 
            new List<Map<SObjectField, Object>> {
                new Map<SObjectField, Object> {
                    Account.Description => 'My Record'
            } };
        
        // When
        String deployId = 
            CustomMetadata.Operations
                // Opportunity SObject emulating Event object
                .callback(Opportunity.getSObjectType(), Opportunity.Name, Opportunity.Description)
                // Account SObject emulating Custom Metadata object 
                .enqueueUpsertRecords(Account.getSObjectType(), records)
                .deployId;
        
        // Then
        System.assertEquals(
            'Description', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].field);
        System.assertEquals(
            'My Record', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].value);        
        System.assertEquals(
            '[{"success":true,"fullName":"Account"}]', 
            mockPlatform.eventBusPublishEvents[0].get('Description'));
    }    

    @IsTest
    private static void whenUpsertingBySObjectSendsEvent() {

        // Given
        MockPlatform mockPlatform = new MockPlatform();
        mockPlatform.metadataEnqueueDeploymentResult = new Metadata.DeployResult();
        mockPlatform.metadataEnqueueDeploymentResult.details = new Metadata.DeployDetails();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentFailures = new List<Metadata.DeployMessage>();
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses = new List<Metadata.DeployMessage>();
        Metadata.DeployMessage deploySuccess = 
            (Metadata.DeployMessage) JSON.deserialize(
                '{"fullName":"Account","success":true}', Metadata.DeployMessage.class);
        mockPlatform.metadataEnqueueDeploymentResult.details.componentSuccesses.add(deploySuccess);
        mockPlatform.eventBusPublishResponse = 
            (List<Database.SaveResult>) JSON.deserialize(
                '[{"id":"e00xx000000001TAAQ","success":true,"errors":[],"warnings":[]}]', List<Database.SaveResult>.class);
        CustomMetadata.Platform = mockPlatform;
        List<SObject> records = new List<SObject> { new Account(Description = 'My Record') }; 
        
        // When
        String deployId = 
            CustomMetadata.Operations
                // Opportunity SObject emulating Event object
                .callback(Opportunity.getSObjectType(), Opportunity.Name, Opportunity.Description)
                // Account SObject emulating Custom Metadata object 
                .enqueueUpsertRecords(records)
                .deployId;
        
        // Then
        System.assertEquals(
            'Description', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].field);
        System.assertEquals(
            'My Record', ((Metadata.CustomMetadata) mockPlatform.metadataEnqueueDeploymentContainer.getMetadata()[0]).values[0].value);        
        System.assertEquals(
            '[{"success":true,"fullName":"Account"}]', 
            mockPlatform.eventBusPublishEvents[0].get('Description'));
    }    
    
    /**
     * Mock platform API behaviours and responses
     **/
    public class MockPlatform extends CustomMetadata.Platform {
        
        // Mock test inputs and captured responses
        public List<Database.SaveResult> eventBusPublishResponse;
        public List<SObject> eventBusPublishEvents;
        public Metadata.DeployContainer metadataEnqueueDeploymentContainer;
        public Metadata.DeployResult metadataEnqueueDeploymentResult; 
        
        // Mock System.EventBus.publish
        public override List<Database.SaveResult> eventBusPublish(List<SObject> events) {
            eventBusPublishEvents = events;
            return eventBusPublishResponse;
        }
        // Mock Metadata.Operations.enqueueDeployment
        public override Id metadatEnqueueDeployment(Metadata.DeployContainer mdContainer, Metadata.DeployCallback deployCallback) {
            metadataEnqueueDeploymentContainer = mdContainer;
            deployCallback.handleResult(metadataEnqueueDeploymentResult, new Metadata.DeployCallbackContext());
            return null; // Not used
        }        
    }
}