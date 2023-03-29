// SPDX-License-Identifier: MIT
// Copyright (c) 2018 The Officious BokkyPooBah / Bok Consulting Pty Ltd
// Copyright (c) 2022 NFTXYZ (Olivier Winkler) Added & Modified Functions

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";

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

contract DateTime {
    uint256 private constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 private constant SECONDS_PER_HOUR = 60 * 60;
    uint256 private constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;

    function timestampToDateTime(
        uint256 _timestamp
    ) public pure returns (Date memory) {
        (uint256 year, string memory month, string memory day) = _daysToDate(
            _timestamp / SECONDS_PER_DAY
        );
        uint256 secs = _timestamp % SECONDS_PER_DAY;
        uint256 _hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        uint256 _minute = secs / SECONDS_PER_MINUTE;

        string memory hour = _formatOctalNumbers(_hour);
        string memory minute = _formatOctalNumbers(_minute);
        string memory dayOfWeek = _getDayOfWeek(_timestamp);

        return Date(year, month, day, dayOfWeek, hour, _hour, minute, _minute);
    }

    function formatDate(Date memory _date) public pure returns (string memory) {
        return
            string.concat(
                _date.day,
                " ",
                _date.month,
                " ",
                Strings.toString(_date.year),
                " ",
                _date.hour,
                ":",
                _date.minute
            );
    }

    function _daysToDate(
        uint256 _days
    )
        internal
        pure
        returns (uint256 year, string memory month, string memory day)
    {
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

    function _formatOctalNumbers(
        uint256 _number
    ) internal pure returns (string memory temp) {
        temp = Strings.toString(_number);
        if (_number < 10) temp = string.concat("0", temp);
    }

    function _getDayOfWeek(
        uint256 _timestamp
    ) internal pure returns (string memory) {
        uint256 _days = _timestamp / SECONDS_PER_DAY;
        uint256 dayOfWeek = ((_days + 3) % 7) + 1;

        if (dayOfWeek == 1) return "MON";
        if (dayOfWeek == 2) return "TUE";
        if (dayOfWeek == 3) return "WED";
        if (dayOfWeek == 4) return "THU";
        if (dayOfWeek == 5) return "FRI";
        if (dayOfWeek == 6) return "SAT";
        if (dayOfWeek == 7) return "SUN";

        return "";
    }

    function _getMonthByNumber(
        uint256 _month
    ) internal pure returns (string memory month) {
        if (_month == 1) return "JAN";
        if (_month == 2) return "FEB";
        if (_month == 3) return "MAR";
        if (_month == 4) return "APR";
        if (_month == 5) return "MAY";
        if (_month == 6) return "JUN";
        if (_month == 7) return "JUL";
        if (_month == 8) return "AUG";
        if (_month == 9) return "SEP";
        if (_month == 10) return "OCT";
        if (_month == 11) return "NOV";
        if (_month == 12) return "DEC";
    }
}
