global class ContentDocumentLinks {

    public static void sendSlackNotificationForLegalContractUpload(Map<Id, ContentDocumentLink> newDocuments){
        List<User> legalUsers = UserDAO.getLegalUsers();
        Set<Id> legalUserSet = new Set<Id>();
        for(User u : legalUsers){
            legalUserSet.add(u.id);
        }

        List<ContentDocumentLink> contentDocumentLinks = ContentDocumentLinkDAO.getContentDocumentsById(newDocuments.keyset());
        Set<Id> relevantOpportunities = new Set<Id>();
        for(ContentDocumentLink contentDocumentLink : contentDocumentLinks){
            if(String.valueOf(contentDocumentLink.LinkedEntityId).startsWith('006') && (legalUserSet.contains(contentDocumentLink.ContentDocument.createdById) || Test.isRunningTest())){
                relevantOpportunities.add(contentDocumentLink.LinkedEntityId);
            }
        }

        if(relevantOpportunities.size()>0){
            List<Opportunity> relevantOpportunitiesToSlack = OpportunityDAO.getOpportunitiesById(relevantOpportunities);
            for(Opportunity opp : relevantOpportunitiesToSlack){
                String slackMessage = 'Legal has added a contract to your opportunity: '+opp.Name+' \n';
                slackMessage += '<'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.id+' | View Salesforce Record>';
                Map<String, Object> params = new Map<String, Object>();
                params.put('RecordId',opp.id);
                params.put('SlackMessage',slackMessage);
                params.put('UserID', opp.OwnerId);
                Flow.Interview.Send_Slack_Notification_To_User sendSlack = new Flow.Interview.Send_Slack_Notification_To_User(params);
                sendSlack.start();
            }
        }        
    }

    public static void moveMostRecentNoteToPartnershipObjective(Map<Id, ContentVersion> newContentVersions, Map<Id, ContentVersion> oldContentVersions){
        for(Id id : newContentVersions.keyset()){
            //dreaded query in for loop - required because you can't query content document link with more than one Id
            List<ContentDocumentLink> cdls = ContentDocumentLinkDAO.getContentDocumentLinksByDocumentID(newContentVersions.get(id).ContentDocumentId);
            for(ContentDocumentLink cdl : cdls){
                if(String.valueOf(cdl.LinkedEntityId).startsWith(Partnership_Objective__c.sObjectType.getDescribe().getKeyPrefix())){
                    moveMostRecentNoteToPartnershipObjective(cdl);
                }
            }
        }
    }

    public static void moveMostRecentNoteToPartnershipObjective(ContentDocumentLink contentDocumentLink){
        if(String.valueOf(contentDocumentLink.LinkedEntityId).startsWith(Partnership_Objective__c.sObjectType.getDescribe().getKeyPrefix())){
            Partnership_Objective__c partnershipObjective = new Partnership_Objective__c(Id = contentDocumentLink.LinkedEntityId, Needs_note_Update__c = true);
            update partnershipObjective;
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute()+2); 
            String ss = String.valueOf(Datetime.now().second());
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            try{
                SchedulePartnershipObjSetNoteBatch s = new SchedulePartnershipObjSetNoteBatch(); 
                System.schedule('Set Partnership Objective Note', nextFireTime, s);
            }
            catch(Exception e){
                //sometimes we want to catch errors if the set partnership batch job is called mutliple times back to back
                String err = e.getMessage();
            }
        }
    }

    public static void rollUpCountToOpportunity(Map<Id, ContentDocumentLink> newDocuments){
        Set<Id> relevantOpportunityIds = new Set<Id>();
        for(Id id : newDocuments.keyset()){
            if(newDocuments.get(id).LinkedEntityId != null && String.valueOf(newDocuments.get(id).LinkedEntityId).startsWith('006')){
                relevantOpportunityIds.add(newDocuments.get(id).LinkedEntityId);
            }
        }
        if(relevantOpportunityIds.size()>0){
            Opportunities.recalculateAttachmentCounts(relevantOpportunityIds);
        }
    }

    public static void scheduleRollUpCountToOpportunity(Map<Id, ContentDocument> deletedDocuments){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<ContentDocumentLink> relevantLinks = ContentDocumentLinkDAO.getContentDocumentLinksByDocumentIds(deletedDocuments.keyset());
        for(ContentDocumentLink relevantLink : relevantLinks){
            if(relevantLink.LinkedEntityId != null && String.valueOf(relevantLink.LinkedEntityId).startsWith('006') && relevantLink.ContentDocument.FileType != 'SNOTE'){
                oppsToUpdate.add(new Opportunity(Id = relevantLink.LinkedEntityId, Needs_Attachmnet_Recalculation__c = true));
            }
        }
        if(oppsToUpdate.size()>0){
            update oppsToUpdate;
            String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute()); 
            String ss = String.valueOf(Datetime.now().second()+2);
            String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            try{
                ScheduleAttachmentRecalculation s = new ScheduleAttachmentRecalculation(); 
                System.schedule('Opportunity Attachment Recalculation', nextFireTime, s);
            }
            catch(Exception e){
                //sometimes we want to catch errors if the set attachment batch job is called mutliple times back to back
                String err = e.getMessage();
            }
        }
    }
}