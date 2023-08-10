// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {NFTIMEArtStyles} from "./NFTIMEArtStyles.sol";
import {Date} from "./DateTime.sol";

library NFTIMEArt {
    /// @dev Generate the complete SVG code for a given Check.
    /// @param _date The check to render.
    function generateSVG(Date memory _date) public pure returns (bytes memory) {
        /// forgefmt: disable-start
        return abi.encodePacked(
            '<svg ',
                'xmlns="http://www.w3.org/2000/svg" ',
                'width="1000" ',
                'height="1000" ',
                'style="background:black;"',
            '>',
                NFTIMEArtStyles.generateStyles(),
                '<path fill="none" stroke="black" d="M0 0h1000.8v1000.8H0z"/>',
                _fillDateAttributes(_date),
                '<path fill="none" stroke="#000" d="M520 620h200m40 0h200M520 860h440M520 380h440M520 140h440M40 260h440"/>',
                _generateClock(_date),
                '<path fill="none" stroke="#fff" d="M960 220c0 11-9 20-20 20H540c-11 0-20-9-20-20V60c0-11 9-20 20-20h400c11 0 20 9 20 20v160zm0 240c0 11-9 20-20 20H540c-11 0-20-9-20-20V300c0-11 9-20 20-20h400c11 0 20 9 20 20v160zM720 700c0 11-9 20-20 20H540c-11 0-20-9-20-20V540c0-11 9-20 20-20h160c11 0 20 9 20 20v160zm240 0c0 11-9 20-20 20H780c-11 0-20-9-20-20V540c0-11 9-20 20-20h160c11 0 20 9 20 20v160zm0 240c0 11-9 20-20 20H540c-11 0-20-9-20-20V780c0-11 9-20 20-20h400c11 0 20 9 20 20v160zM480 460c0 11-9 20-20 20H60c-11 0-20-9-20-20V60c0-11 9-20 20-20h400c11 0 20 9 20 20v400zm0 480c0 11-9 20-20 20H60c-11 0-20-9-20-20V540c0-11 9-20 20-20h400c11 0 20 9 20 20v400z" />'
                '<path fill="none" stroke="#fff" d="M350.5 745.9c0 2.2-1.8 4-4 4h-12c-2.2 0-4-1.8-4-4v-12c0-2.2 1.8-4 4-4h12c2.2 0 4 1.8 4 4v12z" />'
            '</svg>'
        );
        /// forgefmt: disable-end
    }

    function _fillDateAttributes(Date memory _date) internal pure returns (string memory) {
        return string.concat(
            '<foreignObject x="720" y="520" height="200" width="40"><div xmlns="http://www.w3.org/1999/xhtml" class="container"><p style="font-size: 126px;">:</p></div></foreignObject>',
            '<foreignObject x="520" y="520" height="200" width="200"><div xmlns="http://www.w3.org/1999/xhtml" class="container"><p style="font-size: 142px;">',
            _date.hour,
            "</p></div></foreignObject>",
            '<foreignObject x="760" y="520" height="200" width="200"><div xmlns="http://www.w3.org/1999/xhtml" class="container"><p style="font-size: 142px;">',
            _date.minute,
            "</p></div></foreignObject>",
            '<foreignObject x="520" y="760" height="200" width="440"><div xmlns="http://www.w3.org/1999/xhtml" class="container"><p style="font-size: 138px;">',
            _date.dayOfWeek,
            "</p></div></foreignObject>",
            '<foreignObject x="520" y="40" height="200" width="440"><div xmlns="http://www.w3.org/1999/xhtml" class="container"><p style="font-size: 142px;">',
            Strings.toString(_date.year),
            "</p></div></foreignObject>",
            '<foreignObject x="520" y="280" height="200" width="440"><div xmlns="http://www.w3.org/1999/xhtml" class="container"><p style="font-size: 142px;">',
            _date.month,
            "</p></div></foreignObject>",
            '<foreignObject x="40" y="40" height="440" width="440"><div xmlns="http://www.w3.org/1999/xhtml" class="container"><p style="font-size: 360px;">',
            _date.day,
            "</p></div></foreignObject>",
            '<foreignObject x="330" y="730" height="20" width="20"><div xmlns="http://www.w3.org/1999/xhtml" class="container"><p style="font-size: 11px;">',
            _date.day,
            "</p></div></foreignObject>"
        );
    }

    function _generateClock(Date memory _date) internal pure returns (string memory) {
        return string.concat(
            '<g transform="translate(60, 540)">',
            '<svg width="400" height="400" viewBox="0 0 566 566">',
            '<path stroke="white" d="M310.221 542.499l-2.202-21.116M255.679 23.401l2.202 21.116M310.221 23.401l-2.202 21.116M255.679 542.499l2.202-21.116M228.658 27.604l4.504 20.816M337.242 538.296l-4.404-20.816M202.338 34.71l6.505 20.215M363.662 531.19l-6.605-20.215M389.181 521.483l-8.706-19.515M176.819 44.517l8.606 19.415M436.418 494.162l-12.51-17.213M129.582 71.838l12.51 17.213M108.366 89.051l14.211 15.813M457.634 476.949l-14.311-15.812M89.051 108.366l15.813 14.211M476.949 457.634l-15.813-14.311M71.838 129.582l17.213 12.51M494.162 436.418l-17.213-12.51M521.483 389.181l-19.515-8.706M44.517 176.819l19.415 8.606M34.71 202.338l20.215 6.505M531.19 363.662l-20.215-6.605M538.296 337.242l-20.816-4.404M27.604 228.658l20.816 4.504M542.499 310.221l-21.116-2.202M23.401 255.679l21.116 2.202M23.401 310.221l21.116-2.202M542.499 255.679l-21.116 2.202M27.604 337.242l20.816-4.404M538.296 228.658l-20.816 4.504M34.71 363.662l20.215-6.605M531.19 202.338l-20.215 6.505M63.932 380.475l-19.415 8.706M521.483 176.819l-19.515 8.606M494.162 129.582l-17.213 12.51M71.838 436.418l17.213-12.51M476.949 108.366l-15.813 14.211M89.051 457.634l15.813-14.311M457.634 89.051l-14.311 15.813M108.366 476.949l14.211-15.812M129.582 494.162l12.51-17.213M436.418 71.838l-12.51 17.213M176.819 521.483l8.606-19.515M389.181 44.517l-8.706 19.415M363.662 34.71l-6.605 20.215M202.338 531.19l6.505-20.215M228.658 538.296l4.504-20.816M337.242 27.604l-4.404 20.816" />',
            '<path stroke="#fff" d="M434.716 283H544M22 283h109.184M283 434.716V544M283 22v109.184M152.5 56.927l54.542 94.572M358.858 414.401l54.642 94.672M56.927 152.5l94.572 54.542M509.073 413.5l-94.672-54.642M414.401 207.042l94.672-54.542M56.927 413.5l94.572-54.642M358.858 151.499L413.5 56.927M207.042 414.401L152.5 509.073" />',
            '<path fill="#fff" d="M283 295.81c7.075 0 12.81-5.735 12.81-12.81s-5.735-12.81-12.81-12.81-12.81 5.735-12.81 12.81 5.735 12.81 12.81 12.81z" />',
            '<path fill="#fff" d="M283 139.69l-4.503 11.609V283h9.006V151.299L283 139.69z" transform="rotate(',
            _computeRotation(_date.hourUint, 30),
            ',283,283) translate(0,0)" id="hand-h" />',
            ' <path fill="#fff" d="M287.503 65.633L283 53.324l-4.503 12.31V282.9h9.006V65.633z" transform="rotate(',
            _computeRotation(_date.minuteUint, 6),
            ',283,283) translate(0,0)" id="hand-m" />',
            '<path fill="#fff" fillRule="evenodd" id="hand-s-use" d="M284.201 283V53.224h-2.402V283l-1.001 36.928v22.618h4.404v-22.618L284.201 283z" clipRule="evenodd" />',
            "</svg>",
            "</g>"
        );
    }

    function _computeRotation(uint256 rotation, uint256 product) internal pure returns (string memory) {
        return Strings.toString(rotation * product);
    }
}
