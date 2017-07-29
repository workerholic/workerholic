$(document).ready(function() {
  var tab = $(location).attr('href').split('/').pop();
  var $active = $('a[href=' + tab + ']');
  $active.css('background', '#a2a2a2');
  $active.css('color', '#fff');

  setInterval(getDataFromRedis, 5000);

  var chart = new CanvasJS.Chart('chart_container', {
    title: {
      text: 'Overview',
      fontSize: 24,
    },
    axisX: {
      reversed: true,
      gridColor: 'Silver',
      tickColor: 'silver',
      animationEnabled: true,
      title: 'Time ago (s)',
      // minimum: 0,
      maximum: 65
    },
    toolTip: {
      shared: true
    },
		theme: "theme2",
		axisY: {
			gridColor: "Silver",
			tickColor: "silver"
		},
		legend:{
			verticalAlign: "center",
			horizontalAlign: "right"
		},
		data: [{
			type: "line",
			showInLegend: true,
			lineThickness: 2,
			name: "Queued Jobs",
			markerType: "square",
			color: "#F08080",
  		dataPoints: [
          { x: '0', y: 510 },
          { x: '5', y: 570 },
          { x: '10', y: 510 },
          { x: '15', y: 510 },
          { x: '20', y: 610 },
          { x: '25', y: 510 },
          { x: '30', y: 510 },
          { x: '35', y: 510 },
          { x: '40', y: 510 },
          { x: '45', y: 910 },
          { x: '50', y: 510 },
          { x: '55', y: 710 },
          { x: '60', y: 510 },
  		  ]
  		},
      {
			type: "line",
			showInLegend: true,
			name: "Finished Jobs",
			color: "#20B2AA",
			lineThickness: 2,

			dataPoints: [
        { x: '0', y: 430 },
        { x: '5', y: 580 },
        { x: '10', y: 420 },
        { x: '15', y: 110 },
        { x: '20', y: 180 },
        { x: '25', y: 900 },
        { x: '30', y: 510 },
        { x: '35', y: 510 },
        { x: '40', y: 510 },
        { x: '45', y: 510 },
        { x: '50', y: 670 },
        { x: '55', y: 990 },
        { x: '60', y: 240 },
			]
		}


		],
    legend: {
      cursor: "pointer",
      itemclick: function(e){
        if (typeof(e.dataSeries.visible) === "undefined" || e.dataSeries.visible) {
        	e.dataSeries.visible = false;
        }
        else{
          e.dataSeries.visible = true;
        }
        chart.render();
      }
    }
	});

  chart.render();
});

function getDataFromRedis() {
  $.ajax({
    url: '/redis-data',
    data: 'something',
    success: function(data) {
      $('.data').text(data);
    }
  });
}
