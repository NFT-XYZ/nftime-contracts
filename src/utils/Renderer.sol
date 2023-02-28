//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./SVG.sol";
import "./Utils.sol";
import "./DateTime.sol";

contract Renderer {
    function render(Date memory date) public pure returns (string memory) {
        return
            string.concat(
                prepareSVGStyle(),
                renderDayAttributes(date),
                renderClockAttributes()
            );
    }

    function prepareSVGStyle() internal pure returns (string memory) {
        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="1000" style="background:#000">',
                '<defs><style>@font-face{font-family:"HelveticaNowDisplayMd"; src:url("https://nftime.vercel.app/_next/static/media/HelveticaNowDisplayMd.e2e7c552.woff2");} .container {height: 100%; display:flex; align-items:center; justify-content:center;} p {font-family:"HelveticaNowDisplayMd"; color:white; margin:0;}</style></defs>'
            );
    }

    function renderDayAttributes(Date memory date)
        internal
        pure
        returns (string memory)
    {
        return
            string.concat(
                getSVGPath("M0 0h1000.8v1000.8H0z", false),
                getDayAttribute(":", "126", "200", "40", "720", "520"),
                getDayAttribute(date.hour, "142", "200", "200", "520", "520"),
                getDayAttribute(date.minute, "142", "200", "200", "760", "520"),
                getDayAttribute(
                    date.dayOfWeek,
                    "138",
                    "200",
                    "440",
                    "520",
                    "760"
                ),
                getDayAttribute(date.year, "142", "200", "440", "520", "40"),
                getDayAttribute(date.month, "142", "200", "440", "520", "280"),
                getDayAttribute(date.day, "360", "440", "440", "40", "40"),
                getDayAttribute(date.day, "11", "20", "20", "330", "730")
            );
    }

    function renderClockAttributes() internal pure returns (string memory) {
        return
            string.concat(
                getSVGPath(
                    "M520 620h200m40 0h200M520 860h440M520 380h440M520 140h440M40 260h440",
                    false
                ),
                getSVGPath(
                    "M278.835 918.99l-1.6-14.6m-36.1-343.4l1.6 14.6m36.1-14.6l-1.6 14.6m-36.1 343.4l1.6-14.6m-20.2-340.5l3.1 14.4m71.8 337.8l-3.1-14.4m-90-332.9l4.6 13.9m106.7 328.5l-4.5-13.9m22.1 7.2l-6-13.4m-140.5-315.6l6 13.4m173.1 296.7l-8.7-11.8m-202.9-279.4l8.6 11.9m-23.3-.1l9.8 11m231.1 256.6l-9.8-10.9m-244.4-243.3l10.9 9.8m256.6 231.1l-10.9-9.9m-268.5-216.4l11.9 8.6m279.4 203l-11.9-8.6m30.7-24l-13.4-5.9m-315.5-140.5l13.4 6m-20.2 11.6l14 4.5m328.5 106.7l-14-4.5m18.9-13.7l-14.4-3m-337.8-71.8l14.3 3m340.8 53.2l-14.6-1.5m-343.5-36.1l14.6 1.5m-14.6 36.1l14.6-1.5m343.5-36.1l-14.6 1.5m-340.5 54.7l14.3-3m337.9-71.8l-14.4 3m-333 90l14-4.5m328.5-106.7l-14 4.5m-308.3 118.4l-13.4 5.9m328.9-146.4l-13.4 6m-5.4-38.6l-11.9 8.6m-279.4 203l11.9-8.6m267.5-217.6l-10.9 9.8m-256.6 231.1l10.9-9.9m243.3-244.4l-9.8 11m-231.1 256.6l9.8-10.9m4.9 22.7l8.6-11.8m203-279.4l-8.7 11.9m-170.4 298.2l6-13.4m140.5-315.6l-6 13.4m-11.6-20.1l-4.5 13.9m-106.8 328.5l4.6-13.9m13.6 18.8l3.1-14.4m71.8-337.8l-3.1 14.4",
                    false
                ),
                getSVGPath(
                    "M364.635 739.99h75.4m-360 0h75.3m104.7 104.7v75.3m0-360v75.3m-90-51.2l37.6 65.2m104.7 181.4l37.7 65.2m-245.9-245.9l65.2 37.7m246.6 142.3l-65.3-37.6m0-104.7l65.3-37.7m-311.8 180l65.2-37.6m143-143.1l37.7-65.2m-142.4 246.6l-37.6 65.2",
                    false
                ),
                svg.g(
                    svg.prop("transform", "translate(141.12 743.15)"),
                    string.concat(
                        svg.circle(
                            string.concat(
                                svg.prop("cx", "118.9"),
                                svg.prop("cy", "-3.2"),
                                svg.prop("r", "8.8"),
                                svg.prop("fill", "white")
                            ),
                            ""
                        ),
                        getSVGPath(
                            "M232.3-101.2l3.5-7.3-7.7 2.7L116.8-5.5 121-.9l111.3-100.3z",
                            true
                        ),
                        getSVGPath(
                            "M33.3-52.6l5.4 6.7L117.4-.5l3.1-5.4-78.7-45.4-8.5-1.3z",
                            true
                        ),
                        getSVGPath(
                            "M102.058 154.95L118.683-3.277l1.591.167-16.625 158.23z",
                            true
                        ),
                        getSVGPath(
                            "M120-28.7l-2 25.4 1.6.2 3.3-25.3 1.6-15.5-3-.3-1.5 15.5z",
                            true
                        )
                    )
                ),
                getSVGPath(
                    "M960 220c0 11-9 20-20 20H540c-11 0-20-9-20-20V60c0-11 9-20 20-20h400c11 0 20 9 20 20v160zm0 240c0 11-9 20-20 20H540c-11 0-20-9-20-20V300c0-11 9-20 20-20h400c11 0 20 9 20 20v160zM720 700c0 11-9 20-20 20H540c-11 0-20-9-20-20V540c0-11 9-20 20-20h160c11 0 20 9 20 20v160zm240 0c0 11-9 20-20 20H780c-11 0-20-9-20-20V540c0-11 9-20 20-20h160c11 0 20 9 20 20v160zm0 240c0 11-9 20-20 20H540c-11 0-20-9-20-20V780c0-11 9-20 20-20h400c11 0 20 9 20 20v160zM480 460c0 11-9 20-20 20H60c-11 0-20-9-20-20V60c0-11 9-20 20-20h400c11 0 20 9 20 20v400zm0 480c0 11-9 20-20 20H60c-11 0-20-9-20-20V540c0-11 9-20 20-20h400c11 0 20 9 20 20v400z",
                    false
                ),
                getSVGPath(
                    "M350.5 745.9c0 2.2-1.8 4-4 4h-12c-2.2 0-4-1.8-4-4v-12c0-2.2 1.8-4 4-4h12c2.2 0 4 1.8 4 4v12z",
                    false
                ),
                "</svg>"
            );
    }

    function getDayAttribute(
        string memory attribute,
        string memory fontSize,
        string memory height,
        string memory width,
        string memory transformX,
        string memory transformY
    ) internal pure returns (string memory) {
        return
            string.concat(
                '<foreignObject x="',
                transformX,
                '" y="',
                transformY,
                '" height="',
                height,
                '" width="',
                width,
                '">',
                '<div class="container" xmlns="http://www.w3.org/1999/xhtml">',
                '<p style="font-size: ',
                fontSize,
                'px;">',
                attribute,
                "</p>"
                "</div>",
                "</foreignObject>"
            );
    }

    function getSVGPath(string memory d, bool fill)
        internal
        pure
        returns (string memory)
    {
        return
            svg.path(
                string.concat(
                    svg.prop("fill", fill ? "white" : "none"),
                    svg.prop("stroke", "#fff"),
                    svg.prop("d", d)
                ),
                ""
            );
    }
}
