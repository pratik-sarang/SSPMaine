const bHOHSSNPresentCheck = memberObject => {
    const isDisabled =
        memberObject.bSSNVerified &&
        (memberObject.bSSNVerified ||
            memberObject.addRemoveMember ||
            (memberObject.bisHOH &&
                memberObject.sSSN !== undefined &&
                memberObject.sSSN !== null &&
                memberObject.sSSN !== ""))
            ? true
            : false;

    return isDisabled;
};

const getAgeValue = (birthValue, tDate) => {
    let birth = birthValue;
    const today = new Date(tDate);
    const nowYear = today.getFullYear();
    const nowMonth = today.getMonth();
    const nowDay = today.getDate();
    birth = new Date(birth);
    const birthYear = birth.getFullYear();
    const birthMonth = birth.getMonth();
    const birthday = birth.getDate();

    let age = nowYear - birthYear;
    const ageMonth = nowMonth - birthMonth;
    const ageDay = nowDay - birthday;

    if (ageMonth < 0 || (ageMonth == 0 && ageDay < 0)) {
        age = parseInt(age) - 1;
    }

    return age;
};
const getAgeInMonthsValue = (date, tDate) => {
    const todayDate = new Date(tDate);
    const dateParam = new Date(date);
    const months =
        todayDate.getMonth() -
        dateParam.getMonth() +
        12 * (todayDate.getFullYear() - dateParam.getFullYear());

    return months;
};

const ageBoundariesCrossedValue = (oldBirthDate, newBirthDate, tDate) => { //Defect-392437 - Added tDate param
    const boundaries = [11, 13, 17, 19, 60, 65];
    const oldAge = getAgeValue(oldBirthDate, tDate); //Defect-392437 - Added tDate param
    const newAge = getAgeValue(newBirthDate, tDate); //Defect-392437 - Added tDate param
    const result = {};
    for (const boundary of boundaries) {
        if (oldAge < boundary && boundary <= newAge) {
            result[boundary] = true;
        } else if (newAge < boundary && boundary <= oldAge) {
            result[boundary] = false;
        }
    }
    return result;
};

export {
    bHOHSSNPresentCheck,
    getAgeValue,
    getAgeInMonthsValue,
    ageBoundariesCrossedValue
};
