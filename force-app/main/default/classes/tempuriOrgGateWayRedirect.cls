//Generated by wsdl2apex

public class tempuriOrgGateWayRedirect {
    public class SaveAddRoleParametersExResponse_element {
        public String SaveAddRoleParametersExResult;
        private String[] SaveAddRoleParametersExResult_type_info = new String[]{'SaveAddRoleParametersExResult','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'SaveAddRoleParametersExResult'};
    }
    /*public class SaveAddRoleParameters_element {
        public String PageUrl;
        public String ApplicationName;
        public String RoleName;
        private String[] PageUrl_type_info = new String[]{'PageUrl','http://tempuri.org/',null,'0','1','true'};
        private String[] ApplicationName_type_info = new String[]{'ApplicationName','http://tempuri.org/',null,'0','1','true'};
        private String[] RoleName_type_info = new String[]{'RoleName','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'PageUrl','ApplicationName','RoleName'};
    }
    public class SaveAddRoleParametersResponse_element {
        public String SaveAddRoleParametersResult;
        private String[] SaveAddRoleParametersResult_type_info = new String[]{'SaveAddRoleParametersResult','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'SaveAddRoleParametersResult'};
    }*/
    public class RoleRequestShortcut_element {
        public String returnURL;
        public String applicationName;
        public String roleName;
        public Boolean showRequestConfirmationPage;
        public schemasDatacontractOrg200407KeupsB.UserAttributes userAttributes;
        private String[] returnURL_type_info = new String[]{'returnURL','http://tempuri.org/',null,'0','1','true'};
        private String[] applicationName_type_info = new String[]{'applicationName','http://tempuri.org/',null,'0','1','true'};
        private String[] roleName_type_info = new String[]{'roleName','http://tempuri.org/',null,'0','1','true'};
        private String[] showRequestConfirmationPage_type_info = new String[]{'showRequestConfirmationPage','http://tempuri.org/',null,'0','1','false'};
        private String[] userAttributes_type_info = new String[]{'userAttributes','http://tempuri.org/',null,'0','1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'returnURL','applicationName','roleName','showRequestConfirmationPage','userAttributes'};
    }
    public class RoleRequestShortcutResponse_element {
        public String RoleRequestShortcutResult;
        private String[] RoleRequestShortcutResult_type_info = new String[]{'RoleRequestShortcutResult','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'RoleRequestShortcutResult'};
    }
    public class SaveAddRoleParametersEx_element {
        public String PageUrl;
        public String ApplicationName;
        public String RoleName;
        public Boolean ShowRequestConfirmationPage;
        private String[] PageUrl_type_info = new String[]{'PageUrl','http://tempuri.org/',null,'0','1','true'};
        private String[] ApplicationName_type_info = new String[]{'ApplicationName','http://tempuri.org/',null,'0','1','true'};
        private String[] RoleName_type_info = new String[]{'RoleName','http://tempuri.org/',null,'0','1','true'};
        private String[] ShowRequestConfirmationPage_type_info = new String[]{'ShowRequestConfirmationPage','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'PageUrl','ApplicationName','RoleName','ShowRequestConfirmationPage'};
    }
    public class BasicHttpsBinding_IGatewayRedirectContextService {
        public String endpoint_x = 'https://kogideinternal.chfsinet.ky.gov/parameterpassingsvc/GatewayRedirectContextService.svc';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://schemas.datacontract.org/2004/07/Keups.Business.KogEntities', 'schemasDatacontractOrg200407KeupsB', 'http://tempuri.org/', 'tempuriOrgGateWayRedirect', 'http://schemas.microsoft.com/2003/10/Serialization/', 'schemasMicrosoftComGateWayRedirect'};
        /*public String SaveAddRoleParameters(String PageUrl,String ApplicationName,String RoleName) {
            tempuriOrgGateWayRedirect.SaveAddRoleParameters_element request_x = new tempuriOrgGateWayRedirect.SaveAddRoleParameters_element();
            request_x.PageUrl = PageUrl;
            request_x.ApplicationName = ApplicationName;
            request_x.RoleName = RoleName;
            tempuriOrgGateWayRedirect.SaveAddRoleParametersResponse_element response_x;
            Map<String, tempuriOrgGateWayRedirect.SaveAddRoleParametersResponse_element> response_map_x = new Map<String, tempuriOrgGateWayRedirect.SaveAddRoleParametersResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/IGatewayRedirectContextService/SaveAddRoleParameters',
              'http://tempuri.org/',
              'SaveAddRoleParameters',
              'http://tempuri.org/',
              'SaveAddRoleParametersResponse',
              'tempuriOrgGateWayRedirect.SaveAddRoleParametersResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SaveAddRoleParametersResult;
        }*/
        public String RoleRequestShortcut(String returnURL,String applicationName,String roleName,Boolean showRequestConfirmationPage,schemasDatacontractOrg200407KeupsB.UserAttributes userAttributes) {
            tempuriOrgGateWayRedirect.RoleRequestShortcut_element request_x = new tempuriOrgGateWayRedirect.RoleRequestShortcut_element();
            request_x.returnURL = returnURL;
            request_x.applicationName = applicationName;
            request_x.roleName = roleName;
            request_x.showRequestConfirmationPage = showRequestConfirmationPage;
            request_x.userAttributes = userAttributes;
            tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element response_x;
            Map<String, tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element> response_map_x = new Map<String, tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/IGatewayRedirectContextService/RoleRequestShortcut',
              'http://tempuri.org/',
              'RoleRequestShortcut',
              'http://tempuri.org/',
              'RoleRequestShortcutResponse',
              'tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.RoleRequestShortcutResult;
        }
        public String SaveAddRoleParametersEx(String PageUrl,String ApplicationName,String RoleName,Boolean ShowRequestConfirmationPage) {
            tempuriOrgGateWayRedirect.SaveAddRoleParametersEx_element request_x = new tempuriOrgGateWayRedirect.SaveAddRoleParametersEx_element();
            request_x.PageUrl = PageUrl;
            request_x.ApplicationName = ApplicationName;
            request_x.RoleName = RoleName;
            request_x.ShowRequestConfirmationPage = ShowRequestConfirmationPage;
            tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element response_x;
            Map<String, tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element> response_map_x = new Map<String, tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'http://tempuri.org/IGatewayRedirectContextService/SaveAddRoleParametersEx',
              'http://tempuri.org/',
              'SaveAddRoleParametersEx',
              'http://tempuri.org/',
              'SaveAddRoleParametersExResponse',
              'tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.SaveAddRoleParametersExResult;
        }
    }
}