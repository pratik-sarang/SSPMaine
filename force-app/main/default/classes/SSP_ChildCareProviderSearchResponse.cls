/*
* Classname     :  SSP_ChildCareProviderSearchRequest
* @description  :  This class is to make callout for SSP_ChildCareProviderSearch
* @author       :  Ragunathan
* @date         :  05/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  05/14/2020			Initial creation 
**/

public with sharing class SSP_ChildCareProviderSearchResponse {
	
	public FileStream FileStream;
	public List<ChildCareProviderDetails> ChildCareProviderDetails;
	public List<ChildCareEnrollmentDetails> ChildCareEnrollmentDetails;
	public List<ChildCareEnrollmentScheduleDetails> ChildCareEnrollmentScheduleDetails;
	public AckResponse AckResponse;
	public List<ExportData> ExportData;

	public class ChildCareEnrollmentScheduleDetails {
		public String CaseNumber;
		public String EnrollmentID;
		public String SchoolOpenNeed;
		public String SchoolClosedNeed;
		public String SchoolSaturday;
		public String SchoolSunday;
		public String FlexiMaxFullDays;
		public String FlexiMaxPartDays;
		public String ServiceScheduleOnMonday;
		public String ServiceScheduleOnTuesday;
		public String ServiceScheduleOnWednesday;
		public String ServiceScheduleOnThursday;
		public String ServiceScheduleOnFriday;
		public String ServiceScheduleOnSaturday;
		public String ServiceScheduleOnSunday;
	}

	public class ChildCareEnrollmentDetails {
		public String IndividualId;
		public String Casenumber;
		public String EnrolledChildName;
		public String EnrollmentId;
		public String EnrollmentProviderId;
		public String EnrollmentProviderName;
		public String EnrollmentStatus;
		public String EnrollmentStatusFromDate;
		public String EnrollmentStatusEndDate;
		public String IndividualAllocatedDailyCoPayAmount;
		public String FamilyAllocatedDailyCoPayAmount;
		public String ProviderDailyRate;
    }

	public class InspectionHistoryList {
		public Double InspectionId;
		public String ReportName;
		public String InspectionType;
		public String PlanOfCorrectionID;
		public String Source;
		public String DocumentType;
		public String DocumentID;
		public String InspectionStartDate;
		public String InspectionEndDate;
	}

	public class ChildCareProviderDetails {
		public Double ProviderId;
		public String ProviderName;
		public String ProviderStatus;
		public String ProviderType;
		public String ProviderCLRNumber;
		public String LocationAddressLine1;
		public String LocationAddressLine2;
		public String LocationCity;
		public Double LocationZipCode5;
		public String LocationStateDescription;
		public String LocationCountyDescription;
		public Integer NumberOfStars;
		public Double Distance;
		public String IsOngoingProcess;
		public String PhoneNumber;
		public List<HoursOfOperationList> HoursOfOperationList;
		public String Capacity;
		public String IsSubsidyAccepted;
		public String IsAcceditationsAvailable;
		public String Transportation;
		public String Infant;
		public String Toddler;
		public String PreSchool;
		public String SchoolAge;
		public List<ServiceCostList> ServiceCostList;
		public List<InspectionHistoryList> InspectionHistoryList;
		public List<OnGoingProcessList> OnGoingProcessList;
		public String IsFoodPermitAvailable;
	}

	public class HoursOfOperationList {
		public String Day;
		public String ServiceTime;
	}

	public class ServiceCostList {
		public String AgeGroup;
		public Double FullTimeCost;
		public Double PartTimeCost;
		public String NonTraditional;
		public String IsSpecialNeedsSupported;
	}

	public class OnGoingProcessList {
		public String ProcessType;
		public String ProcessDescription;
		public String Status;
	}
    
	public class FileStream {

		public String FileData;
		public FileStream() {

		}
	}

	public class ExportData {
		public String LocationCountyDescription;
		public String ProviderCLRNumber;
		public String ProviderName;
		public String LocationAddress;
		public String PhoneNumber;
		public String MailingAddress;
		public String ExpiryDate;
		public String capacity;
		public String AgeRangeSupported;
		public String Transportation;
		public String NonTraditional;
		public String StarsRatingText;
		public String ProviderType;
		public String IsActiveCCAPChildren;
		public String IsServingSpecialNeeds;
	}
	public class AckResponse {
		public String AckResponseCode;
		public String AckResponseDescription;

		public AckResponse() {
			
		}
	}
    public SSP_ChildCareProviderSearchResponse() {
        
    }
}