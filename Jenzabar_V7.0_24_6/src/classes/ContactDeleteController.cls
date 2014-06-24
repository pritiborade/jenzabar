public with sharing class ContactDeleteController {

   private ApexPages.standardcontroller stdCtrl;

   public ContactDeleteController(ApexPages.Standardcontroller std)
   {
      stdCtrl=std;
   }

   public PageReference checkDelete()
   {
          if(ApexPages.currentPage().getParameters().get('flag') == '1')
          {return new PageReference('/apex/ContactSearch');}
          return new PageReference('/apex/ContactEnhancedList?save_new=1&sfdc.override=1');
   }

}