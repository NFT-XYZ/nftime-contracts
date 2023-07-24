// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {HelveticaNowFont} from "./HelveticaNowFont.sol";

library NFTIMEArtStyles {
    function generateStyles() public pure returns (string memory) {
        /// forgefmt: disable-start
        return string.concat(
            '<defs>',
                '<style>',
                    '@font-face { font-family:"HelveticaNowDisplayMd";',
                    'src: url("',
                        HelveticaNowFont.HELVETICA_NOW_FONT,
                    '")}',
                    '.container { height: 100%; display: flex; align-items: center; justify-content: center; }',
                    'p { font-family: "HelveticaNowDisplayMd"; color: white; margin: 0; }',
                    '@keyframes rotation { from { transform: rotate(0deg); transform-origin: 50% 50%; } to { transform: rotate(360deg); transform-origin: 50% 50%; } }',
                    '#hand-s-use { animation: rotation 60s infinite steps(60); }',
                '</style>',
            '</defs>'
        );
        /// forgefmt: disable-end
    }
}
