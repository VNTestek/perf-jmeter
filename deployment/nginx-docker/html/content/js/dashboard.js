/*
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
var showControllersOnly = false;
var seriesFilter = "";
var filtersOnlySampleSeries = true;

/*
 * Add header in statistics table to group metrics by category
 * format
 *
 */
function summaryTableHeader(header) {
    var newRow = header.insertRow(-1);
    newRow.className = "tablesorter-no-sort";
    var cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Requests";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 3;
    cell.innerHTML = "Executions";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 7;
    cell.innerHTML = "Response Times (ms)";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Throughput";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 2;
    cell.innerHTML = "Network (KB/sec)";
    newRow.appendChild(cell);
}

/*
 * Populates the table identified by id parameter with the specified data and
 * format
 *
 */
function createTable(table, info, formatter, defaultSorts, seriesIndex, headerCreator) {
    var tableRef = table[0];

    // Create header and populate it with data.titles array
    var header = tableRef.createTHead();

    // Call callback is available
    if(headerCreator) {
        headerCreator(header);
    }

    var newRow = header.insertRow(-1);
    for (var index = 0; index < info.titles.length; index++) {
        var cell = document.createElement('th');
        cell.innerHTML = info.titles[index];
        newRow.appendChild(cell);
    }

    var tBody;

    // Create overall body if defined
    if(info.overall){
        tBody = document.createElement('tbody');
        tBody.className = "tablesorter-no-sort";
        tableRef.appendChild(tBody);
        var newRow = tBody.insertRow(-1);
        var data = info.overall.data;
        for(var index=0;index < data.length; index++){
            var cell = newRow.insertCell(-1);
            cell.innerHTML = formatter ? formatter(index, data[index]): data[index];
        }
    }

    // Create regular body
    tBody = document.createElement('tbody');
    tableRef.appendChild(tBody);

    var regexp;
    if(seriesFilter) {
        regexp = new RegExp(seriesFilter, 'i');
    }
    // Populate body with data.items array
    for(var index=0; index < info.items.length; index++){
        var item = info.items[index];
        if((!regexp || filtersOnlySampleSeries && !info.supportsControllersDiscrimination || regexp.test(item.data[seriesIndex]))
                &&
                (!showControllersOnly || !info.supportsControllersDiscrimination || item.isController)){
            if(item.data.length > 0) {
                var newRow = tBody.insertRow(-1);
                for(var col=0; col < item.data.length; col++){
                    var cell = newRow.insertCell(-1);
                    cell.innerHTML = formatter ? formatter(col, item.data[col]) : item.data[col];
                }
            }
        }
    }

    // Add support of columns sort
    table.tablesorter({sortList : defaultSorts});
}

$(document).ready(function() {

    // Customize table sorter default options
    $.extend( $.tablesorter.defaults, {
        theme: 'blue',
        cssInfoBlock: "tablesorter-no-sort",
        widthFixed: true,
        widgets: ['zebra']
    });

    var data = {"OkPercent": 98.52140475752184, "KoPercent": 1.4785952424781657};
    var dataset = [
        {
            "label" : "FAIL",
            "data" : data.KoPercent,
            "color" : "#FF6347"
        },
        {
            "label" : "PASS",
            "data" : data.OkPercent,
            "color" : "#9ACD32"
        }];
    $.plot($("#flot-requests-summary"), dataset, {
        series : {
            pie : {
                show : true,
                radius : 1,
                label : {
                    show : true,
                    radius : 3 / 4,
                    formatter : function(label, series) {
                        return '<div style="font-size:8pt;text-align:center;padding:2px;color:white;">'
                            + label
                            + '<br/>'
                            + Math.round10(series.percent, -2)
                            + '%</div>';
                    },
                    background : {
                        opacity : 0.5,
                        color : '#000'
                    }
                }
            }
        },
        legend : {
            show : true
        }
    });

    // Creates APDEX table
    createTable($("#apdexTable"), {"supportsControllersDiscrimination": true, "overall": {"data": [0.9641754106072692, 500, 1500, "Total"], "isController": false}, "titles": ["Apdex", "T (Toleration threshold)", "F (Frustration threshold)", "Label"], "items": [{"data": [0.9724522674619871, 500, 1500, "2.4 Get Avatar"], "isController": false}, {"data": [0.9823654768247203, 500, 1500, "2.7 Register FireBase Token"], "isController": false}, {"data": [0.9763115845539281, 500, 1500, "2.5 Get Beneficiary Bank"], "isController": false}, {"data": [0.9563296178343949, 500, 1500, "1.1 Get Config"], "isController": false}, {"data": [0.9954877239548773, 500, 1500, "1.2 ForceUpdateAppVersion"], "isController": false}, {"data": [0.8902250838078007, 500, 1500, "2.1 Get Casa List"], "isController": false}, {"data": [0.8852487317733925, 500, 1500, "1.11 Synchronization"], "isController": false}, {"data": [0.9836720560424047, 500, 1500, "2.6 CountUnread"], "isController": false}, {"data": [0.9869909201932777, 500, 1500, "1.4 Pre-init"], "isController": false}, {"data": [0.9756929694137638, 500, 1500, "1.6 Get Info"], "isController": false}, {"data": [0.9506974763071026, 500, 1500, "2.3 Get Billing Casa List"], "isController": false}, {"data": [0.9831225875149741, 500, 1500, "2.2 Get M4uDashBoard"], "isController": false}, {"data": [0.9956865659756324, 500, 1500, "1.3 DownTimeNoti"], "isController": false}]}, function(index, item){
        switch(index){
            case 0:
                item = item.toFixed(3);
                break;
            case 1:
            case 2:
                item = formatDuration(item);
                break;
        }
        return item;
    }, [[0, 0]], 3);

    // Create statistics table
    createTable($("#statisticsTable"), {"supportsControllersDiscrimination": true, "overall": {"data": ["Total", 488910, 7229, 1.4785952424781657, 194.78505450901113, 60, 27590, 128.0, 559.0, 666.0, 949.9900000000016, 627.8460530877991, 2231.2759518747353, 785.3509580347626], "isController": false}, "titles": ["Label", "#Samples", "FAIL", "Error %", "Average", "Min", "Max", "Median", "90th pct", "95th pct", "99th pct", "Transactions/s", "Received", "Sent"], "items": [{"data": ["2.4 Get Avatar", 37553, 959, 2.5537240699810932, 174.74185817377997, 62, 10345, 100.0, 134.0, 173.0, 365.9900000000016, 48.37602235296088, 33.28893415235362, 79.03711317168703], "isController": false}, {"data": ["2.7 Register FireBase Token", 37540, 555, 1.4784230154501865, 138.7977091102831, 62, 3873, 111.0, 271.0, 297.0, 397.0, 48.368497342567245, 34.78544124456434, 89.27445668585923], "isController": false}, {"data": ["2.5 Get Beneficiary Bank", 37550, 555, 1.478029294274301, 161.70612516644363, 61, 16765, 134.0, 217.0, 278.0, 607.0, 48.373590982286636, 1617.1617023953302, 79.6471832226248], "isController": false}, {"data": ["1.1 Get Config", 37680, 518, 1.3747346072186837, 339.9307059448, 92, 27590, 229.0, 408.0, 625.0, 10097.0, 48.411466631034735, 39.99425742183887, 15.601351551017052], "isController": false}, {"data": ["1.2 ForceUpdateAppVersion", 37675, 1, 0.0026542800265428003, 131.47076310550878, 74, 4711, 115.0, 172.0, 223.0, 487.0, 48.43385420349289, 75.97635409703162, 15.75046235328431], "isController": false}, {"data": ["2.1 Get Casa List", 37586, 1065, 2.8335018357899218, 395.90557654445894, 61, 10647, 216.0, 603.0, 678.0, 815.0, 48.33689993621268, 104.40348124768515, 78.92681876853499], "isController": false}, {"data": ["1.11 Synchronization", 37651, 682, 1.8113728719024726, 282.83811850946813, 62, 12001, 106.0, 665.0, 766.0, 966.9900000000016, 48.404680666154135, 32.437413361619, 79.70090630013898], "isController": false}, {"data": ["2.6 CountUnread", 37543, 555, 1.4783048770742881, 103.40926404389654, 60, 4300, 93.0, 124.0, 164.0, 355.9900000000016, 48.37454418946256, 33.019780294891696, 79.27065054270444], "isController": false}, {"data": ["1.4 Pre-init", 37666, 429, 1.1389582116497636, 138.6612594913187, 64, 10586, 91.0, 121.0, 159.0, 570.9800000000032, 48.43853683880227, 38.89657439511306, 16.556140521074994], "isController": false}, {"data": ["1.6 Get Info", 37664, 800, 2.1240441801189465, 177.33843988954885, 62, 10336, 117.0, 260.0, 301.0, 503.9900000000016, 48.43085769835126, 73.37498832674756, 77.71061586271644], "isController": false}, {"data": ["2.3 Get Billing Casa List", 37564, 555, 1.4774784368011926, 251.31391758066246, 63, 4116, 167.0, 466.0, 534.0, 675.9900000000016, 48.35057902534274, 33.288793515392406, 81.07338388609541], "isController": false}, {"data": ["2.2 Get M4uDashBoard", 37565, 555, 1.4774391055503793, 104.62060428590416, 62, 8028, 93.0, 124.0, 160.0, 361.0, 48.362137332248466, 34.40790880747067, 79.29810107158858], "isController": false}, {"data": ["1.3 DownTimeNoti", 37673, 0, 0.0, 131.16929896742923, 73, 4168, 115.0, 174.0, 223.0, 483.9800000000032, 48.43688727459741, 86.38847091864614, 15.325733864228088], "isController": false}]}, function(index, item){
        switch(index){
            // Errors pct
            case 3:
                item = item.toFixed(2) + '%';
                break;
            // Mean
            case 4:
            // Mean
            case 7:
            // Median
            case 8:
            // Percentile 1
            case 9:
            // Percentile 2
            case 10:
            // Percentile 3
            case 11:
            // Throughput
            case 12:
            // Kbytes/s
            case 13:
            // Sent Kbytes/s
                item = item.toFixed(2);
                break;
        }
        return item;
    }, [[0, 0]], 0, summaryTableHeader);

    // Create error table
    createTable($("#errorsTable"), {"supportsControllersDiscrimination": false, "titles": ["Type of error", "Number of errors", "% in errors", "% in all samples"], "items": [{"data": ["502/Bad Gateway", 593, 8.203070964172085, 0.12129021701335624], "isController": false}, {"data": ["504/Gateway Timeout", 1021, 14.123668557200165, 0.20883189135014624], "isController": false}, {"data": ["500/Internal Server Error", 620, 8.576566606722922, 0.12681270581497617], "isController": false}, {"data": ["401/Unauthorized", 4995, 69.09669387190483, 1.021660428299687], "isController": false}]}, function(index, item){
        switch(index){
            case 2:
            case 3:
                item = item.toFixed(2) + '%';
                break;
        }
        return item;
    }, [[1, 1]]);

        // Create top5 errors by sampler
    createTable($("#top5ErrorsBySamplerTable"), {"supportsControllersDiscrimination": false, "overall": {"data": ["Total", 488910, 7229, "401/Unauthorized", 4995, "504/Gateway Timeout", 1021, "500/Internal Server Error", 620, "502/Bad Gateway", 593, "", ""], "isController": false}, "titles": ["Sample", "#Samples", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors"], "items": [{"data": ["2.4 Get Avatar", 37553, 959, "401/Unauthorized", 555, "504/Gateway Timeout", 212, "500/Internal Server Error", 192, "", "", "", ""], "isController": false}, {"data": ["2.7 Register FireBase Token", 37540, 555, "401/Unauthorized", 555, "", "", "", "", "", "", "", ""], "isController": false}, {"data": ["2.5 Get Beneficiary Bank", 37550, 555, "401/Unauthorized", 555, "", "", "", "", "", "", "", ""], "isController": false}, {"data": ["1.1 Get Config", 37680, 518, "502/Bad Gateway", 302, "504/Gateway Timeout", 215, "500/Internal Server Error", 1, "", "", "", ""], "isController": false}, {"data": ["1.2 ForceUpdateAppVersion", 37675, 1, "502/Bad Gateway", 1, "", "", "", "", "", "", "", ""], "isController": false}, {"data": ["2.1 Get Casa List", 37586, 1065, "401/Unauthorized", 555, "504/Gateway Timeout", 298, "500/Internal Server Error", 212, "", "", "", ""], "isController": false}, {"data": ["1.11 Synchronization", 37651, 682, "401/Unauthorized", 555, "504/Gateway Timeout", 84, "500/Internal Server Error", 43, "", "", "", ""], "isController": false}, {"data": ["2.6 CountUnread", 37543, 555, "401/Unauthorized", 555, "", "", "", "", "", "", "", ""], "isController": false}, {"data": ["1.4 Pre-init", 37666, 429, "502/Bad Gateway", 290, "504/Gateway Timeout", 139, "", "", "", "", "", ""], "isController": false}, {"data": ["1.6 Get Info", 37664, 800, "401/Unauthorized", 555, "500/Internal Server Error", 172, "504/Gateway Timeout", 73, "", "", "", ""], "isController": false}, {"data": ["2.3 Get Billing Casa List", 37564, 555, "401/Unauthorized", 555, "", "", "", "", "", "", "", ""], "isController": false}, {"data": ["2.2 Get M4uDashBoard", 37565, 555, "401/Unauthorized", 555, "", "", "", "", "", "", "", ""], "isController": false}, {"data": [], "isController": false}]}, function(index, item){
        return item;
    }, [[0, 0]], 0);

});
