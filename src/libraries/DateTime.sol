// SPDX-License-Identifier: MIT
// Copyright (c) 2018 The Officious BokkyPooBah / Bok Consulting Pty Ltd
// Copyright (c) 2023 NFTXYZ (Olivier Winkler) Added & Modified Functions

pragma solidity ^0.8.18;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

struct Date {
    uint256 year;
    string month;
    string day;
    string dayOfWeek;
    string hour;
    uint256 hourUint;
    string minute;
    uint256 minuteUint;
}

// TODO Comments
///
///  ███╗   ██╗███████╗████████╗██╗███╗   ███╗███████╗
///  ████╗  ██║██╔════╝╚══██╔══╝██║████╗ ████║██╔════╝
///  ██╔██╗ ██║█████╗     ██║   ██║██╔████╔██║█████╗
///  ██║╚██╗██║██╔══╝     ██║   ██║██║╚██╔╝██║██╔══╝
///  ██║ ╚████║██║        ██║   ██║██║ ╚═╝ ██║███████╗
///  ╚═╝  ╚═══╝╚═╝        ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝
///
/// @title NFTIME
/// @author https://nftxyz.art/ (Olivier Winkler)
/// @notice MINT YOUR MINUTE
/// @custom:security-contact abc@nftxyz.art
library DateTime {
    uint256 private constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 private constant SECONDS_PER_HOUR = 60 * 60;
    uint256 private constant SECONDS_PER_MINUTE = 60;
    int256 private constant OFFSET19700101 = 2440588;

    string private constant WEEKDAY_MON = "MON";
    string private constant WEEKDAY_TUE = "TUE";
    string private constant WEEKDAY_WED = "WED";
    string private constant WEEKDAY_THU = "THU";
    string private constant WEEKDAY_FRI = "FRI";
    string private constant WEEKDAY_SAT = "SAT";
    string private constant WEEKDAY_SUN = "SUN";

    string private constant MONTH_JAN = "JAN";
    string private constant MONTH_FEB = "FEB";
    string private constant MONTH_MAR = "MAR";
    string private constant MONTH_APR = "APR";
    string private constant MONTH_MAY = "MAY";
    string private constant MONTH_JUN = "JUN";
    string private constant MONTH_JUL = "JUL";
    string private constant MONTH_AUG = "AUG";
    string private constant MONTH_SEP = "SEP";
    string private constant MONTH_OCT = "OCT";
    string private constant MONTH_NOV = "NOV";
    string private constant MONTH_DEC = "DEC";

    function timestampToDateTime(uint256 _timestamp) public pure returns (Date memory) {
        (uint256 _year, string memory _month, string memory _day) = _daysToDate(_timestamp / SECONDS_PER_DAY);
        uint256 _secs = _timestamp % SECONDS_PER_DAY;
        uint256 _hourUint = _secs / SECONDS_PER_HOUR;
        _secs = _secs % SECONDS_PER_HOUR;
        uint256 _minuteUint = _secs / SECONDS_PER_MINUTE;

        string memory _hour = _formatOctalNumbers(_hourUint);
        string memory _minute = _formatOctalNumbers(_minuteUint);
        string memory _dayOfWeek = _getDayOfWeek(_timestamp);

        return Date(_year, _month, _day, _dayOfWeek, _hour, _hourUint, _minute, _minuteUint);
    }

    function formatDate(Date memory _date, bool _isMinute) public pure returns (string memory) {
        string memory _name = string.concat(_date.day, " ", _date.month, " ", Strings.toString(_date.year));

        if (_isMinute) {
            _name = string.concat(_name, " ", _date.hour, ":", _date.minute);
        }

        return _name;
    }

    function _daysToDate(uint256 _days) internal pure returns (uint256 year, string memory month, string memory day) {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = _getMonthByNumber(uint256(_month));
        day = _formatOctalNumbers(uint256(_day));
    }

    function _formatOctalNumbers(uint256 _number) internal pure returns (string memory temp) {
        temp = Strings.toString(_number);
        if (_number < 10) temp = string.concat("0", temp);
    }

    function _getDayOfWeek(uint256 _timestamp) internal pure returns (string memory) {
        uint256 _days = _timestamp / SECONDS_PER_DAY;
        uint256 dayOfWeek = ((_days + 3) % 7) + 1;

        if (dayOfWeek == 1) return WEEKDAY_MON;
        if (dayOfWeek == 2) return WEEKDAY_TUE;
        if (dayOfWeek == 3) return WEEKDAY_WED;
        if (dayOfWeek == 4) return WEEKDAY_THU;
        if (dayOfWeek == 5) return WEEKDAY_FRI;
        if (dayOfWeek == 6) return WEEKDAY_SAT;
        if (dayOfWeek == 7) return WEEKDAY_SUN;

        return "";
    }

    function _getMonthByNumber(uint256 _month) internal pure returns (string memory month) {
        if (_month == 1) return MONTH_JAN;
        if (_month == 2) return MONTH_FEB;
        if (_month == 3) return MONTH_MAR;
        if (_month == 4) return MONTH_APR;
        if (_month == 5) return MONTH_MAY;
        if (_month == 6) return MONTH_JUN;
        if (_month == 7) return MONTH_JUL;
        if (_month == 8) return MONTH_AUG;
        if (_month == 9) return MONTH_SEP;
        if (_month == 10) return MONTH_OCT;
        if (_month == 11) return MONTH_NOV;
        if (_month == 12) return MONTH_DEC;
    }
}
