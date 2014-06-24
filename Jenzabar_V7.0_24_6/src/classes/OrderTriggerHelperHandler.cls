public with sharing class OrderTriggerHelperHandler {

	// Add the Opportunity product into Order Product when any Opportunity is added on Order
    public static void addOppProduct(List<Order> newOrder){
        List<Order> ordertoUpdate = new List<Order>();
        Map<Id,Id> oppOrderIdsMap = new Map<Id,Id>();
        Map<Id,Order> oppOrderMap = new Map<Id,Order>();
        List<OrderItem> orderItemstoInsert = new List<OrderItem>();
        Map<Id,Order> ordertoInsert = new Map<Id,Order>();
        Map<Id,Id> orderPricebookMap = new Map<Id,Id>();
        System.debug('===newOrder===='+newOrder);
        
        for(Order orderItr : newOrder){
            if(!String.isBlank(orderItr.Opportunity__c)){
                oppOrderIdsMap.put(orderItr.Opportunity__c,orderItr.Id);
                oppOrderMap.put(orderItr.Opportunity__c,orderItr);
            	System.debug('====oppOrderMap==='+oppOrderMap);
            }
        }
       
        for(Order orderItr : [SELECT id,
        							 Pricebook2Id,
        							 Contract.Pricebook2Id,
        							 Opportunity__r.Pricebook2Id,
        							 (SELECT id FROM OrderItems) 
        							 FROM Order
        							 WHERE id IN: oppOrderIdsMap.values()]){
        	
        	Order orderObj = new Order(id=orderItr.id);
        	if(orderItr.Contract.Pricebook2Id != null){
        		System.debug('====Contract.Pricebook2.Id==='+orderItr.Contract.Pricebook2Id);
        		orderObj.Pricebook2Id =   orderItr.Contract.Pricebook2Id;
        		orderPricebookMap.put(orderObj.Id, orderItr.Contract.Pricebook2Id);
        	}
        	else if(orderItr.Opportunity__r.Pricebook2Id != null){
        		System.debug('====Opportunity__r.Pricebook2.Id==='+orderItr.Opportunity__r.Pricebook2Id);
        		orderObj.Pricebook2Id =  orderItr.Opportunity__r.Pricebook2Id;
        		orderPricebookMap.put(orderObj.id,orderItr.Opportunity__r.Pricebook2Id);
        	}
        	System.debug('orderItr===='+orderItr);
        	System.debug('orderItr2===='+ orderItr.Contract.Pricebook2Id);
        	ordertoInsert.put(orderObj.id,orderObj);	
        							 
		}
		
		if(!ordertoInsert.isEmpty()){
        	System.debug('=====ordertoInsert.values()==='+ordertoInsert.values());
        	try{
        		update ordertoInsert.values();
    		}catch(Exception e){
        		(ordertoInsert.values())[0].addError('test');
        	}
         
        
        
        for(Opportunity oppItr : [SELECT id,
                                         Pricebook2Id, 
                                         (SELECT id, Quantity, UnitPrice,PricebookEntryId FROM OpportunityLineItems) 
                                         FROM Opportunity
                                         WHERE id IN : oppOrderIdsMap.keySet()])
        {   
            
        	if(!oppItr.OpportunityLineItems.isEmpty()){
                for(OpportunityLineItem OppLineItr : oppItr.OpportunityLineItems){
                    
                    OrderItem orderItemObj = new OrderItem();
                    orderItemObj.PricebookEntryId = oppLineItr.PricebookEntryId;
                    orderItemObj.Quantity = oppLineItr.Quantity;
                    orderItemObj.OrderId = oppOrderIdsMap.get(oppItr.id);
                    orderItemObj.UnitPrice = OppLineItr.UnitPrice;
                    orderItemObj.Opportunity_Product_ID__c = OppLineItr.id; 
                    orderItemstoInsert.add(orderItemObj);
                }
            }
        }   
        
       if(!orderItemstoInsert.isEmpty()){
            System.debug('=====orderItemstoInsert==='+orderItemstoInsert);
             
             try{
            		 insert orderItemstoInsert;
            }catch(Exception e){
            	newOrder[0].addError(Label.OrderErrorMessageonInsert);
           	   System.debug('Exception '+e);
        	}
        }                           
    }}
     public static void addOppProductUpdate(List<Order> newOrder,Map<Id,Order> newOrderMap){
    	
        List<Order> ordertoUpdate = new List<Order>();
        Map<Id,Id> oppOrderIdsMap = new Map<Id,Id>();
        Map<Id,Order> oppOrderMap = new Map<Id,Order>();
        List<OrderItem> orderItemstoInsert = new List<OrderItem>();
        Map<Id,Order> ordertoInsert = new Map<Id,Order>();
        Map<Id,Id> orderPricebookMap = new Map<Id,Id>();
        System.debug('===newOrder===='+newOrder);
        
        for(Order orderItr : newOrder){
            if(!String.isBlank(orderItr.Opportunity__c)){
                oppOrderIdsMap.put(orderItr.Opportunity__c,orderItr.Id);
                oppOrderMap.put(orderItr.Opportunity__c,orderItr);
            	System.debug('====oppOrderMap==='+oppOrderMap);
            }
        }
       
        for(Order orderItr : [SELECT id,
        							 Pricebook2Id,
        							 Contract.Pricebook2Id,
        							 Opportunity__r.Pricebook2Id,
        							 (SELECT id FROM OrderItems) 
        							 FROM Order
        							 WHERE id IN: oppOrderIdsMap.values()]){
        	
        	Order orderObj = new Order(id=orderItr.id);
        	if(orderItr.Contract.Pricebook2Id != null){
        		System.debug('====Contract.Pricebook2.Id==='+orderItr.Contract.Pricebook2Id);
        		orderObj.Pricebook2Id =   orderItr.Contract.Pricebook2Id;
        		orderPricebookMap.put(orderObj.Id, orderItr.Contract.Pricebook2Id);
        	}
        	else if(orderItr.Opportunity__r.Pricebook2Id != null){
        		System.debug('====Opportunity__r.Pricebook2.Id==='+orderItr.Opportunity__r.Pricebook2Id);
        		orderObj.Pricebook2Id =  orderItr.Opportunity__r.Pricebook2Id;
        		orderPricebookMap.put(orderObj.id,orderItr.Opportunity__r.Pricebook2Id);
        	}
        	System.debug('orderItr===='+orderItr);
        	System.debug('orderItr2===='+ orderItr.Contract.Pricebook2Id);
        	ordertoInsert.put(orderObj.id,orderObj);	
        							 
		}
		
		if(!ordertoInsert.isEmpty()){
        	System.debug('=====ordertoInsert.values()==='+ordertoInsert.values());
        	try{
        		update ordertoInsert.values();
        	}catch(Exception e){
        		(newOrderMap.values())[0].addError(Label.OrderErrorMessage_for_Pricebook);
        	}
        }
        
        for(Opportunity oppItr : [SELECT id,
                                         Pricebook2Id, 
                                         (SELECT id, Quantity, UnitPrice,PricebookEntryId FROM OpportunityLineItems) 
                                         FROM Opportunity
                                         WHERE id IN : oppOrderIdsMap.keySet()])
        {   
            
        	if(!oppItr.OpportunityLineItems.isEmpty()){
                for(OpportunityLineItem OppLineItr : oppItr.OpportunityLineItems){
                    
                    OrderItem orderItemObj = new OrderItem();
                    orderItemObj.PricebookEntryId = oppLineItr.PricebookEntryId;
                    orderItemObj.Quantity = oppLineItr.Quantity;
                    orderItemObj.OrderId = oppOrderIdsMap.get(oppItr.id);
                    orderItemObj.UnitPrice = OppLineItr.UnitPrice;
                    orderItemObj.Opportunity_Product_ID__c = OppLineItr.id; 
                    orderItemstoInsert.add(orderItemObj);
                }
            }
        }   
        
       
        if(!orderItemstoInsert.isEmpty()){
            System.debug('=====orderItemstoInsert==='+orderItemstoInsert);
             try{
             	insert orderItemstoInsert;}
             catch(Exception e){
             	newOrderMap.get(orderItemstoInsert[0].orderId).addError(Label.OrderErrorMessage);
             }
             
        }                           
    
    }
    
    
    
    //If any new Opportunity is added on Order then delete the old Opportunity related Order Product
    // & add newly added Opportunities's product on Order Product.
    public static void updateProduct(Map<Id,Order> oldOrderMap, Map<Id,Order> newOrderMap){
        
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderIdstoDelete = new Set<Id>();
        List<OrderItem> orderItemtoDelete = new List<OrderItem>();
        List<Order> orderList = new List<Order>();
        for(Order orderItr : newOrderMap.values()){
            if(oldOrderMap.get(orderItr.Id).Opportunity__c != newOrderMap.get(orderItr.Id).Opportunity__c ){
                if(String.isBlank(newOrderMap.get(orderItr.id).Opportunity__c)){
                    orderIdstoDelete.add(orderItr.id);
                }
                else{
                    orderIdstoDelete.add(orderItr.id);
                    orderIds.add(orderItr.id);
                }
            }
        }
        
        
        for(OrderItem orderItemItr : [SELECT id, 
                                             OrderId, 
                                             Opportunity_Product_ID__c 
                                             FROM OrderItem 
                                             WHERE OrderId IN:orderIdstoDelete AND Opportunity_Product_ID__c != null]){
               orderItemtoDelete.add(orderItemItr);
        }
        
        if(!orderItemtoDelete.isEmpty()){
            delete orderItemtoDelete;
        }
        
        for(Order orderItr : [SELECT id,
                                     Opportunity__c ,
                                     Contract.Pricebook2Id
                                     FROM Order 
                                     WHERE Id IN: orderIds]){
            orderList.add(orderItr);
        }
        OrderTriggerHelperHandler.addOppProductUpdate(orderList,newOrderMap);
    }
    
}