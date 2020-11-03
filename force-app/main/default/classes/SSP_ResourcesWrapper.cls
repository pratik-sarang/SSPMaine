/**
* @author: Karthik Gulla
* @Class Name: SSP_ResourcesWrapper
* @desc This class is used to generate the data structure for Resources
* @Date 11-15-2019
MODIFICATION LOG :
* */ 
public with sharing class SSP_ResourcesWrapper {
    public String strResourceId                             {get;set;}
    public String strResourceTypeLabel                      {get;set;}
    public String strResourceType                           {get;set;}
    public String strTempResId                              {get;set;}
    public String strMemberName                             {get;set;}
    public Boolean bDetailsRequired                         {get;set;}
    public Boolean isResourceEditable                       {get;set;}
    public Double dResourceValue                            {get;set;}
    public Boolean bNoInformation                           {get;set;}
    public String strFuneralLocation                        {get;set;}
    public String strFuneralFundedOption                    {get;set;}
    public String strItemisedGoodsSigned                    {get;set;}
    public String strGoodsServicesCost                      {get;set;}
    public String strHomeSteadProperty                      {get;set;}
    public String strIncomeProducingProperty                {get;set;}
    public String strIncomeEssentialToSupport               {get;set;}
    public String strOtherOwners                            {get;set;}
    public String strAdditionalOwners                       {get;set;}
    public String strResourceSubType                        {get;set;}
    public String strRealEstateAddress                      {get;set;}
    public Double dRealEstateFairMarketValue                {get;set;}
    public String strAnotherOwner                           {get;set;}
    public Boolean bExistingData                            {get;set;}
    public String strResTileLineOneValue                    {get;set;}
    public String strResTileLineTwoValue                    {get;set;}
    public String strVehicleCategory                        {get;set;}
    public String strVehicleMake                            {get;set;}
    public String strVehicleModel                           {get;set;}
    public String strVehicleModelYear                       {get;set;}
    public String strVehicleUseReason                       {get;set;}
    public Date dtResourceStartDate                         {get;set;}
    public Date dtResourceEndDate                           {get;set;}
    public Double dVehicleFairMarketValue                   {get;set;}
    public Double dVehicleDebt                              {get;set;}
    public String strIndividualAbleToRide                   {get;set;}
    public String strAccessToVehicle                        {get;set;}
    public String strNoAccessReason                         {get;set;}
    public String strPrimaryUserIndividual                  {get;set;}
    public String strInsuranceFaceValueAmount               {get;set;}
    public Double dCashSurrenderValue                       {get;set;}
    public String strInsuranceCompanyAddress                {get;set;}
    public String strInsuranceCompanyPhone                  {get;set;}
    public Double dLoanBalance                              {get;set;}
    public String strPolicyDesignatedForBurial              {get;set;}
    public String strPolicyUsedForFuneral                   {get;set;}
    public String strInsuranceCompanyName                   {get;set;}   
    public String strPolicyNumber                           {get;set;}
    public Date dtPolicyIssuanceDate                        {get;set;}
    public Boolean bHideAdditionalDetails                   {get;set;}
    public String strResourceEndReason                      {get;set;}
    public String strInsuranceAssetId                       {get;set;}
    public String strPolicyBeenAssignedForFuneral           {get;set;}
    public Boolean bIsCoownerResource                       {get;set;}
    public class HouseholdMemberWrapper {
        public String strAppIndividualId        {get;set;}
        public String strMemberId               {get;set;}
        public String strHouseholdMemberName    {get;set;}
        public String strAppliedPrograms        {get;set;}
        public String strMemberStatus           {get;set;}
        public String strDCPrograms             {get;set;}
        public Boolean bHeadOfHousehold         {get;set;}
        public String strMemberPrograms         {get;set;}
        public Boolean bTMember                 {get;set;}
    }
    public class InsurancePolicyWrapper {
        public String strInsurancePolicyNumber      {get;set;}
        public String strInsuranceAssetId           {get;set;}
    }
    public class ResourceSelectionWrapper {
        public String strObject             {get;set;}
        public String strField              {get;set;}
        public String strObjectRecords      {get;set;}
        public String strQuestionValue      {get;set;}
        public String strAppliedPrograms    {get;set;}
    }
}