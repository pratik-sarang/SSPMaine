//Generated by wsdl2apex

public class AsyncKyHbeMci {
    /*public class DeleteMemberResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.DeleteMemberResponse getValue() {
            kyHbeMci.DeleteMemberResponse_element response = (kyHbeMci.DeleteMemberResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.DeleteMemberResult;
        }
    } 
    public class GetMciCrossReferenceResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.MciCrossReferenceResponse getValue() {
            kyHbeMci.GetMciCrossReferenceResponse_element response = (kyHbeMci.GetMciCrossReferenceResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.GetMciCrossReferenceResult;
        }
    }
    public class UpdateCaseNumberResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.CaseNumberUpdateResponse getValue() {
            kyHbeMci.UpdateCaseNumberResponse_element response = (kyHbeMci.UpdateCaseNumberResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.UpdateCaseNumberResult;
        }
    }
    public class CreateOrUpdateMembersResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.CreateOrUpdateMemberResponse getValue() {
            kyHbeMci.CreateOrUpdateMembersResponse_element response = (kyHbeMci.CreateOrUpdateMembersResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.CreateOrUpdateMembersResult;
        }
    }
    public class UpdateConversionStatusResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.UpdateConversionStatusResponse getValue() {
            kyHbeMci.UpdateConversionStatusResponse_element response = (kyHbeMci.UpdateConversionStatusResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.UpdateConversionStatusResult;
        }
    }
    public class KamesCreateOrUpdateBenefitsResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.CreateOrUpdateBenefitsResponse getValue() {
            kyHbeMci.KamesCreateOrUpdateBenefitsResponse_element response = (kyHbeMci.KamesCreateOrUpdateBenefitsResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.KamesCreateOrUpdateBenefitsResult;
        }
    }*/
    public class EntityMciSearchResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.MciEntitySearchResponse getValue() {
            kyHbeMci.EntityMciSearchResponse_element response = (kyHbeMci.EntityMciSearchResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.EntityMciSearchResult;
        }
    }
    /*public class GetMciCrossReferencesResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.MciCrossReferencesResponse getValue() {
            kyHbeMci.GetMciCrossReferencesResponse_element response = (kyHbeMci.GetMciCrossReferencesResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.GetMciCrossReferencesResult;
        }
    }
    public class GetMemberBenefitsResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.GetMemberBenefitsResponse getValue() {
            kyHbeMci.GetMemberBenefitsResponse_element response = (kyHbeMci.GetMemberBenefitsResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.GetMemberBenefitsResult;
        }
    }
    public class CreateOrUpdateBenefitsResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.CreateOrUpdateBenefitsResponse getValue() {
            kyHbeMci.CreateOrUpdateBenefitsResponse_element response = (kyHbeMci.CreateOrUpdateBenefitsResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.CreateOrUpdateBenefitsResult;
        }
    }
    public class GetConversionStatusResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.ConversionStatusResponse getValue() {
            kyHbeMci.GetConversionStatusResponse_element response = (kyHbeMci.GetConversionStatusResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.GetConversionStatusResult;
        }
    }
    public class SearchMembersResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.MemberSearchResponse getValue() {
            kyHbeMci.SearchMembersResponse_element response = (kyHbeMci.SearchMembersResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.SearchMembersResult;
        }
    }
    public class GetAllMemberBenefitsResponse_elementFuture extends System.WebServiceCalloutFuture {
        public kyHbeMciDatacontracts.GetMembersBenefitsResponse getValue() {
            kyHbeMci.GetAllMemberBenefitsResponse_element response = (kyHbeMci.GetAllMemberBenefitsResponse_element)System.WebServiceCallout.endInvoke(this);
            return response.GetAllMemberBenefitsResult;
        }
    }*/
    public class AsyncMciHttpsDefaultEndpoint {
        public String endpoint_x = 'http://ky-re-mci-services-xapi-development.us-e2.cloudhub.io/MCI_WCFService/MciService.svc';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'schemasMicrosoftCom200310Serializat', 'http://Ky.Hbe.Mci.DataContracts', 'kyHbeMciDatacontracts', 'http://schemas.datacontract.org/2004/07/Ky.Hbe.Mci.DataContracts', 'schemasDatacontractOrg200407KyHbe', 'Ky.Hbe.Mci.DataContracts', 'kyHbeMciDatacontracts', 'http://schemas.microsoft.com/2003/10/Serialization/', 'schemasMicrosoftCom200310Serializat', 'http://Ky.Hbe.Mci', 'kyHbeMci'};
       /* public AsyncKyHbeMci.DeleteMemberResponse_elementFuture beginDeleteMember(System.Continuation continuation,kyHbeMciDatacontracts.DeleteMemberRequest request) {
            kyHbeMci.DeleteMember_element request_x = new kyHbeMci.DeleteMember_element();
            request_x.request = request;
            return (AsyncKyHbeMci.DeleteMemberResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.DeleteMemberResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/DeleteMember',
              'http://Ky.Hbe.Mci',
              'DeleteMember',
              'http://Ky.Hbe.Mci',
              'DeleteMemberResponse',
              'kyHbeMci.DeleteMemberResponse_element'}
            );
        }
        public AsyncKyHbeMci.GetMciCrossReferenceResponse_elementFuture beginGetMciCrossReference(System.Continuation continuation,kyHbeMciDatacontracts.MciCrossReferenceRequest request) {
            kyHbeMci.GetMciCrossReference_element request_x = new kyHbeMci.GetMciCrossReference_element();
            request_x.request = request;
            return (AsyncKyHbeMci.GetMciCrossReferenceResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.GetMciCrossReferenceResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/GetMciCrossReference',
              'http://Ky.Hbe.Mci',
              'GetMciCrossReference',
              'http://Ky.Hbe.Mci',
              'GetMciCrossReferenceResponse',
              'kyHbeMci.GetMciCrossReferenceResponse_element'}
            );
        }
        public AsyncKyHbeMci.UpdateCaseNumberResponse_elementFuture beginUpdateCaseNumber(System.Continuation continuation,kyHbeMciDatacontracts.CaseNumberUpdateRequest request) {
            kyHbeMci.UpdateCaseNumber_element request_x = new kyHbeMci.UpdateCaseNumber_element();
            request_x.request = request;
            return (AsyncKyHbeMci.UpdateCaseNumberResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.UpdateCaseNumberResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/UpdateCaseNumber',
              'http://Ky.Hbe.Mci',
              'UpdateCaseNumber',
              'http://Ky.Hbe.Mci',
              'UpdateCaseNumberResponse',
              'kyHbeMci.UpdateCaseNumberResponse_element'}
            );
        }
        public AsyncKyHbeMci.CreateOrUpdateMembersResponse_elementFuture beginCreateOrUpdateMembers(System.Continuation continuation,kyHbeMciDatacontracts.CreateOrUpdateMemberRequest request) {
            kyHbeMci.CreateOrUpdateMembers_element request_x = new kyHbeMci.CreateOrUpdateMembers_element();
            request_x.request = request;
            return (AsyncKyHbeMci.CreateOrUpdateMembersResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.CreateOrUpdateMembersResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/CreateOrUpdateMembers',
              'http://Ky.Hbe.Mci',
              'CreateOrUpdateMembers',
              'http://Ky.Hbe.Mci',
              'CreateOrUpdateMembersResponse',
              'kyHbeMci.CreateOrUpdateMembersResponse_element'}
            );
        }
        public AsyncKyHbeMci.UpdateConversionStatusResponse_elementFuture beginUpdateConversionStatus(System.Continuation continuation,kyHbeMciDatacontracts.UpdateConversionStatusRequest request) {
            kyHbeMci.UpdateConversionStatus_element request_x = new kyHbeMci.UpdateConversionStatus_element();
            request_x.request = request;
            return (AsyncKyHbeMci.UpdateConversionStatusResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.UpdateConversionStatusResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/UpdateConversionStatus',
              'http://Ky.Hbe.Mci',
              'UpdateConversionStatus',
              'http://Ky.Hbe.Mci',
              'UpdateConversionStatusResponse',
              'kyHbeMci.UpdateConversionStatusResponse_element'}
            );
        }
        public AsyncKyHbeMci.KamesCreateOrUpdateBenefitsResponse_elementFuture beginKamesCreateOrUpdateBenefits(System.Continuation continuation,kyHbeMciDatacontracts.CreateOrUpdateBenefitsRequest request) {
            kyHbeMci.KamesCreateOrUpdateBenefits_element request_x = new kyHbeMci.KamesCreateOrUpdateBenefits_element();
            request_x.request = request;
            return (AsyncKyHbeMci.KamesCreateOrUpdateBenefitsResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.KamesCreateOrUpdateBenefitsResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/KamesCreateOrUpdateBenefits',
              'http://Ky.Hbe.Mci',
              'KamesCreateOrUpdateBenefits',
              'http://Ky.Hbe.Mci',
              'KamesCreateOrUpdateBenefitsResponse',
              'kyHbeMci.KamesCreateOrUpdateBenefitsResponse_element'}
            );
        }*/
        public AsyncKyHbeMci.EntityMciSearchResponse_elementFuture beginEntityMciSearch(System.Continuation continuation,kyHbeMciDatacontracts.MciEntitySearchRequest request) {
            kyHbeMci.EntityMciSearch_element request_x = new kyHbeMci.EntityMciSearch_element();
            request_x.request = request;
            return (AsyncKyHbeMci.EntityMciSearchResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.EntityMciSearchResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/EntityMciSearch',
              'http://Ky.Hbe.Mci',
              SSP_InterfaceConstants.ENTITY_MCI_SEARCH,
              'http://Ky.Hbe.Mci',
              SSP_InterfaceConstants.ENTITY_MCI_SEARCH_RESPONSE,
              SSP_InterfaceConstants.ENTITY_MCI_SEARCH_RESPONSE_ELEMENT}
            );
        }
        /*public AsyncKyHbeMci.GetMciCrossReferencesResponse_elementFuture beginGetMciCrossReferences(System.Continuation continuation,kyHbeMciDatacontracts.MciCrossReferenceRequests request) {
            kyHbeMci.GetMciCrossReferences_element request_x = new kyHbeMci.GetMciCrossReferences_element();
            request_x.request = request;
            return (AsyncKyHbeMci.GetMciCrossReferencesResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.GetMciCrossReferencesResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/GetMciCrossReferences',
              'http://Ky.Hbe.Mci',
              'GetMciCrossReferences',
              'http://Ky.Hbe.Mci',
              'GetMciCrossReferencesResponse',
              'kyHbeMci.GetMciCrossReferencesResponse_element'}
            );
        }
        public AsyncKyHbeMci.GetMemberBenefitsResponse_elementFuture beginGetMemberBenefits(System.Continuation continuation,kyHbeMciDatacontracts.MemberBenefitsRequest request) {
            kyHbeMci.GetMemberBenefits_element request_x = new kyHbeMci.GetMemberBenefits_element();
            request_x.request = request;
            return (AsyncKyHbeMci.GetMemberBenefitsResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.GetMemberBenefitsResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/GetMemberBenefits',
              'http://Ky.Hbe.Mci',
              'GetMemberBenefits',
              'http://Ky.Hbe.Mci',
              'GetMemberBenefitsResponse',
              'kyHbeMci.GetMemberBenefitsResponse_element'}
            );
        }
        public AsyncKyHbeMci.CreateOrUpdateBenefitsResponse_elementFuture beginCreateOrUpdateBenefits(System.Continuation continuation,kyHbeMciDatacontracts.CreateOrUpdateBenefitsRequest request) {
            kyHbeMci.CreateOrUpdateBenefits_element request_x = new kyHbeMci.CreateOrUpdateBenefits_element();
            request_x.request = request;
            return (AsyncKyHbeMci.CreateOrUpdateBenefitsResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.CreateOrUpdateBenefitsResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/CreateOrUpdateBenefits',
              'http://Ky.Hbe.Mci',
              'CreateOrUpdateBenefits',
              'http://Ky.Hbe.Mci',
              'CreateOrUpdateBenefitsResponse',
              'kyHbeMci.CreateOrUpdateBenefitsResponse_element'}
            );
        }
        public AsyncKyHbeMci.GetConversionStatusResponse_elementFuture beginGetConversionStatus(System.Continuation continuation,kyHbeMciDatacontracts.ConversionStatusRequest request) {
            kyHbeMci.GetConversionStatus_element request_x = new kyHbeMci.GetConversionStatus_element();
            request_x.request = request;
            return (AsyncKyHbeMci.GetConversionStatusResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.GetConversionStatusResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/GetConversionStatus',
              'http://Ky.Hbe.Mci',
              'GetConversionStatus',
              'http://Ky.Hbe.Mci',
              'GetConversionStatusResponse',
              'kyHbeMci.GetConversionStatusResponse_element'}
            );
        }
        public AsyncKyHbeMci.SearchMembersResponse_elementFuture beginSearchMembers(System.Continuation continuation,kyHbeMciDatacontracts.MemberSearchRequest request) {
            kyHbeMci.SearchMembers_element request_x = new kyHbeMci.SearchMembers_element();
            request_x.request = request;
            return (AsyncKyHbeMci.SearchMembersResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.SearchMembersResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/SearchMembers',
              'http://Ky.Hbe.Mci',
              'SearchMembers',
              'http://Ky.Hbe.Mci',
              'SearchMembersResponse',
              'kyHbeMci.SearchMembersResponse_element'}
            );
        }
        public AsyncKyHbeMci.GetAllMemberBenefitsResponse_elementFuture beginGetAllMemberBenefits(System.Continuation continuation,kyHbeMciDatacontracts.MembersBenefitsRequest request) {
            kyHbeMci.GetAllMemberBenefits_element request_x = new kyHbeMci.GetAllMemberBenefits_element();
            request_x.request = request;
            return (AsyncKyHbeMci.GetAllMemberBenefitsResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncKyHbeMci.GetAllMemberBenefitsResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://Ky.Hbe.Mci/IMciService/GetAllMemberBenefits',
              'http://Ky.Hbe.Mci',
              'GetAllMemberBenefits',
              'http://Ky.Hbe.Mci',
              'GetAllMemberBenefitsResponse',
              'kyHbeMci.GetAllMemberBenefitsResponse_element'}
            );
        }*/
    }
}