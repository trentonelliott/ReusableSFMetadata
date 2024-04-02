@isTest
public class OpportunityAutoCloneOppProductsTest {

    @isTest
    static void testCloneOpportunityProducts() {
        // Get Standard PriceBookId for testing
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        // Use pricebookId to setup PricebookEntry records

        // Create a Product record
        List<Product2> products = new List<Product2>();
        
        for (Integer i = 1; i <= 200; i++) {
            Product2 product = new Product2();
            product.Name = 'Product ' + i;
            product.IsActive = true;
            products.add(product);
        }
        // Insert the products list
        insert products;

        // Specify the standard price for the Pricebook Entry
        Decimal standardPrice = 100.00;

        // Create a new Pricebook Entry record
        List<PricebookEntry> pbEntryList = new List<PricebookEntry>();
        
            for(Product2 p: products){
                PricebookEntry pbEntry = new PricebookEntry();
                pbEntry.Pricebook2Id = pricebookId;
                pbEntry.Product2Id = p.Id;
                pbEntry.UnitPrice = standardPrice;
                pbEntry.IsActive = true;
                pbEntryList.add(pbEntry);
            }

        // Insert the Pricebook Entry record
        insert pbEntryList;

        // Create the Old Opportunity
        Opportunity oldOpp = new Opportunity(
            Name = 'Old Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.today(),
            RecordTypeId = '012Dn000000lSDTIA2',
            Amount = 10000,
            Customer_Budget__c = 10000,
            Compelling_Reason_To_Close__c = 'Test',
            Primary_Contact__c = '003Dn0000069X79IAE'
        );
        insert oldOpp;

        // Create the New Opportunity
        Opportunity newOpp = new Opportunity(
            Name = 'New Opportunity',
            StageName = 'Qualification',
            CloseDate = Date.today(),
            RecordTypeId = '012Dn000000lSDTIA2',
            Amount = 10000,
            Customer_Budget__c = 10000,
            Compelling_Reason_To_Close__c = 'Test',
            Primary_Contact__c = '003Dn0000069X79IAE'
        );
        insert newOpp;

        // Create Opportunity Products related to the Old Opportunity
        List<OpportunityLineItem> oldOppProducts = new List<OpportunityLineItem>();

        for (PricebookEntry pbe : pbEntryList) {
            OpportunityLineItem oppProd = new OpportunityLineItem();
            oppProd.OpportunityId = oldOpp.Id;
            oppProd.PricebookEntryId = pbe.Id;
            oppProd.Quantity = 1;
            oppProd.UnitPrice = 1000;
            oldOppProducts.add(oppProd);
        }
        insert oldOppProducts;

        // Set up the flow input variables
        Map<String, Object> flowInput = new Map<String, Object>{
            'varT_OldOppId' => oldOpp.Id,
            'varT_NewOppId' => newOpp.Id
        };

        // Run the flow
        Test.startTest();
        Flow.Interview.Opportunity_Auto_Clone_Opp_Products flow = new Flow.Interview.Opportunity_Auto_Clone_Opp_Products(flowInput);
        flow.start();
        Test.stopTest();

        // Verify that Opportunity Products were cloned to the New Opportunity
        List<OpportunityLineItem> newOppProducts = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :newOpp.Id];
        System.assertEquals(200, newOppProducts.size(), 'Expected 200 Opportunity Products on the New Opportunity');
    }
}
