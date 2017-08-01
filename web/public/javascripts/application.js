var queuedJobsCountHistory = [];
var failedJobsCountHistory = [];
var jobsCompletedHistory = [];

$(document).ready(function() {
  var tab = $(location).attr('href').split('/').pop();
  var $active = $('a[href=' + tab + ']');

  $active.css('background', '#a2a2a2');
  $active.css('color', '#fff');

  if (tab === 'overview') {
    getOverviewData();

    setInterval(function() {
      getOverviewData();
    }, 5000);
  }

  if (tab === 'queues') {
    setInterval(function() {
      getQueueData();
    }, 5000);
  }

  if (tab === 'details') {
    setInterval(function() {
      getDetailData();
    }, 5000);
  }
});

function getOverviewData() {
  $.ajax({
    url: '/overview-data',
    success: function(data) {
      var deserializedData = JSON.parse(data);

      var completedJobs = deserializedData.completed_jobs.reduce(function(sum, subArray) {
        return sum + subArray[1];
      }, 0);

      var failedJobsCount= deserializedData.failed_jobs.reduce(function(sum, subArray) {
        return sum + subArray[1];
      }, 0);

      var queuedJobs = deserializedData.queued_jobs;

      var queuedJobsCount = queuedJobs.reduce(function(sum, queue) {
        return sum + queue[1];
      }, 0);

      queuedJobsCountHistory.unshift(queuedJobsCount);
      failedJobsCountHistory.unshift(failedJobsCount);
      jobsCompletedHistory.unshift(completedJobs);

      if (queuedJobsCountHistory.length > 13) {
        queuedJobsCountHistory.pop();
        failedJobsCountHistory.pop();
        jobsCompletedHistory.pop();
      }

      drawChart();

      var workersCount = deserializedData.workers_count;

      $('.completed_jobs').text(completedJobs);
      $('.failed_jobs').text(failedJobsCount);
      $('.queue_count').text(queuedJobs.length);
      $('.queued_jobs_count').text(queuedJobsCount);
      $('.workers_count').text(workersCount);
    }
  });
}

function getQueueData() {
  $.ajax({
    url: '/queues-data',
    success: function(data) {
      var deserializedData = JSON.parse(data);
      var queuedJobs = deserializedData.queued_jobs;
      var total = 0;

      for (var i = 0; i < queuedJobs.length; i++) {
        $('#queue_name_' + queuedJobs[i][0].split(':').pop()).text(queuedJobs[i][0]);
        $('#queue_count_' + queuedJobs[i][0].split(':').pop()).text(queuedJobs[i][1]);
        total = total + queuedJobs[i][1];
      }

      $('#queue_total').text(total);
    }
  });
}

function getDetailData() {
  $.ajax({
    url: '/details-data',
    success: function(data) {
      var deserializedData = JSON.parse(data);
      var completedJobs = deserializedData.completed_jobs;
      var failedJobs = deserializedData.failed_jobs;
      var completedTotal = 0;
      var failedTotal = 0;

      completedJobs.forEach(function(job) {
        $('#completed_' + job[0]).text(job[1]);
        completedTotal = completedTotal + job[1];
      });

      failedJobs.forEach(function(job) {
        $('#failed_' + job[0]).text(job[1]);
        failedTotal = failedTotal + job[1];
      });

      $('#failed_total').text(failedTotal);
      $('#completed_total').text(completedTotal);
    }
  })
}

function drawChart() {
  var processedJobsChart = new CanvasJS.Chart('jobs_processed_container', {
    title: {
      text: 'Jobs Processed per second',
      fontFamily: 'Arial',
      fontSize: 24,
    },
    axisX: {
      reversed: true,
      gridColor: 'Silver',
      tickColor: 'silver',
      animationEnabled: true,
      title: 'Time ago (s)',
      maximum: 60
    },
    toolTip: {
      shared: true
    },
    theme: "theme2",
    axisY: {
      gridColor: "Silver",
      tickColor: "silver",
      title: 'Jobs per second',
    },
    data: [{
      type: "line",
      showInLegend: true,
      name: "Jobs completed",
      color: "blue",
      markerType: 'circle',
      lineThickness: 2,
      dataPoints: [
        { x: '0', y: (jobsCompletedHistory[0] - jobsCompletedHistory[1]) / 5 || 0 },
        { x: '5', y: (jobsCompletedHistory[1] - jobsCompletedHistory[2]) / 5 || 0 },
        { x: '10', y: (jobsCompletedHistory[2] - jobsCompletedHistory[3]) / 5 || 0 },
        { x: '15', y: (jobsCompletedHistory[3] - jobsCompletedHistory[4]) / 5 || 0 },
        { x: '20', y: (jobsCompletedHistory[4] - jobsCompletedHistory[5]) / 5 || 0 },
        { x: '25', y: (jobsCompletedHistory[5] - jobsCompletedHistory[6]) / 5 || 0 },
        { x: '30', y: (jobsCompletedHistory[6] - jobsCompletedHistory[7]) / 5 || 0 },
        { x: '35', y: (jobsCompletedHistory[7] - jobsCompletedHistory[8]) / 5 || 0 },
        { x: '40', y: (jobsCompletedHistory[8] - jobsCompletedHistory[9]) / 5 || 0 },
        { x: '45', y: (jobsCompletedHistory[9] - jobsCompletedHistory[10]) / 5 || 0 },
        { x: '50', y: (jobsCompletedHistory[10] - jobsCompletedHistory[11]) / 5 || 0 },
        { x: '55', y: (jobsCompletedHistory[11] - jobsCompletedHistory[12]) / 5 || 0 },
        { x: '60', y: (jobsCompletedHistory[12] - jobsCompletedHistory[13]) / 5 || 0 },
      ]
    }]
  });

  var queuedJobsChart = new CanvasJS.Chart('queued_jobs_container', {
    title: {
      text: 'Queued Jobs',
      fontFamily: 'Arial',
      fontSize: 24,
    },
    axisX: {
      reversed: true,
      gridColor: 'Silver',
      tickColor: 'silver',
      animationEnabled: true,
      title: 'Time ago (s)',
      // minimum: 0,
      maximum: 60
    },
    toolTip: {
      shared: true
    },
    theme: "theme2",
    axisY: {
      gridColor: "Silver",
      tickColor: "silver",
      title: 'Jobs'
    },
    data: [{
      type: "line",
      showInLegend: true,
      lineThickness: 2,
      name: "Queued Jobs",
      markerType: "circle",
      color: "#F08080",
      dataPoints: [
          { x: '0', y: queuedJobsCountHistory[0] },
          { x: '5', y: queuedJobsCountHistory[1] },
          { x: '10', y: queuedJobsCountHistory[2] },
          { x: '15', y: queuedJobsCountHistory[3] },
          { x: '20', y: queuedJobsCountHistory[4] },
          { x: '25', y: queuedJobsCountHistory[5] },
          { x: '30', y: queuedJobsCountHistory[6] },
          { x: '35', y: queuedJobsCountHistory[7] },
          { x: '40', y: queuedJobsCountHistory[8] },
          { x: '45', y: queuedJobsCountHistory[9] },
          { x: '50', y: queuedJobsCountHistory[10] },
          { x: '55', y: queuedJobsCountHistory[11] },
          { x: '60', y: queuedJobsCountHistory[12] },
        ]
      },
    ],
  });

  var failedJobsChart = new CanvasJS.Chart('failed_jobs_container', {
    title: {
      text: 'Failed Jobs',
      fontFamily: 'Arial',
      fontSize: 24,
    },
    axisX: {
      reversed: true,
      gridColor: 'Silver',
      tickColor: 'silver',
      animationEnabled: true,
      title: 'Time ago (s)',
      // minimum: 0,
      maximum: 60
    },
    toolTip: {
      shared: true
    },
    theme: "theme2",
    axisY: {
      gridColor: "Silver",
      tickColor: "silver",
      title: 'Jobs'
    },
    data: [{
        type: "line",
        showInLegend: true,
        name: "Failed Jobs",
        color: "#20B2AA",
        markerType: 'circle',
        lineThickness: 2,
        dataPoints: [
          { x: '0', y: failedJobsCountHistory[0] },
          { x: '5', y: failedJobsCountHistory[1] },
          { x: '10', y: failedJobsCountHistory[2] },
          { x: '15', y: failedJobsCountHistory[3] },
          { x: '20', y: failedJobsCountHistory[4] },
          { x: '25', y: failedJobsCountHistory[5] },
          { x: '30', y: failedJobsCountHistory[6] },
          { x: '35', y: failedJobsCountHistory[7] },
          { x: '40', y: failedJobsCountHistory[8] },
          { x: '45', y: failedJobsCountHistory[9] },
          { x: '50', y: failedJobsCountHistory[10] },
          { x: '55', y: failedJobsCountHistory[11] },
          { x: '60', y: failedJobsCountHistory[12] },
        ]
      },
    ]
  });

  queuedJobsChart.render();
  failedJobsChart.render();
  processedJobsChart.render();
}
