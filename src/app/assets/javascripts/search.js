//= require highlightRegex.min.js

var chartData = [];
var loadChart = function (chartAPI) {
  chartAPI = (chartAPI !== 'undefined') ? chartAPI : "";

  if (chartData.length === 0)
  {
    if (chartAPI !== '')
    {
      $.getJSON( chartAPI )
      .done(function( data ) {
        if (data.length > 1) {
          for(i=0; i< data.length; i++)
          {
            var row = data[i];
            newRow = row.slice(0, 3);
            newRow.push(new Date(row[3]));
            newRow.push(new Date(row[4]));
            chartData[i] = newRow;
          }
          $('#toggleChart-1').show();
        }
      });
    }
  }
  else if ($('#chart-1').css('visibility') === 'hidden') {
    google.charts.load('current', {'packages':['timeline']});
    google.charts.setOnLoadCallback(drawChart);
    var drawChart = function () {
      var container = document.getElementById('chart-1');
      var chart = new google.visualization.Timeline(container);
      var dataTable = new google.visualization.DataTable();

      dataTable.addColumn({type: "string", id: "Name"});
      dataTable.addColumn({type: "string", id: 'dummy bar label' });
      dataTable.addColumn({type: "string", role: 'tooltip', 'p': {'html': true} });
      dataTable.addColumn({type: "date", id: "Start"});
      dataTable.addColumn({type: "date", id: "End"});
      dataTable.addRows(chartData);

      var options = {
        timeline: { colorByRowLabel: true },
        tooltip: {isHtml: true},
      };

      chart.draw(dataTable, options);

      $('#chart-1').css('visibility', 'visible');
      $('#chart-1').css('height', 'auto');
      $(window).trigger('resize');
    }; drawChart();
  }
  else {
    $('#chart-1').fadeToggle();
    $(window).trigger('resize');
  }
};

toggle_search_tools_when_regex = function(){
  $disabled = $("select[name='sm']").val() == 5;
  $("select[name='m']").prop("disabled", $disabled);
};

$(function() {
  // Search method is Regex
  $('select').on('change', function() {
    toggle_search_tools_when_regex();
  });
  toggle_search_tools_when_regex();
  if($("select[name='sm']").val() == 5){
    $('.list-group-item').highlightRegex(new RegExp($("input.simple-search").val(), "ig"));
  }
});
