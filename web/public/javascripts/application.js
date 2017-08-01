var App = {
  queuedJobsCountHistory: [],
  failedJobsCountHistory: [],
  jobsCompletedHistory: [],
  totalMemoryHistory: [],
  tab: null,
  getOverviewData: function() {
    $.ajax({
      url: '/overview-data',
      context: this,
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

        // var totalMemory = deserializedData.memory_usage ...

        this.queuedJobsCountHistory.unshift(queuedJobsCount);
        this.failedJobsCountHistory.unshift(failedJobsCount);
        this.jobsCompletedHistory.unshift(completedJobs);
        // totalMemoryHistory.unshift(totalMemory); Waiting for data

        if (this.queuedJobsCountHistory.length > 13) {
          this.queuedJobsCountHistory.pop();
          this.failedJobsCountHistory.pop();
          this.jobsCompletedHistory.pop();
          this.totalMemoryHistory.pop();
        }

        this.drawChart();

        var workersCount = deserializedData.workers_count;

        $('.completed_jobs').text(completedJobs);
        $('.failed_jobs').text(failedJobsCount);
        $('.queue_count').text(queuedJobs.length);
        $('.queued_jobs_count').text(queuedJobsCount);
        $('.workers_count').text(workersCount);
      }
    });
  },
  getQueueData: function() {
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
  },
  getDetailData: function() {
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
  },
  drawChart: function() {
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
          { x: '0', y: (this.jobsCompletedHistory[0] - this.jobsCompletedHistory[1]) / 5 || 0 },
          { x: '5', y: (this.jobsCompletedHistory[1] - this.jobsCompletedHistory[2]) / 5 || 0 },
          { x: '10', y: (this.jobsCompletedHistory[2] - this.jobsCompletedHistory[3]) / 5 || 0 },
          { x: '15', y: (this.jobsCompletedHistory[3] - this.jobsCompletedHistory[4]) / 5 || 0 },
          { x: '20', y: (this.jobsCompletedHistory[4] - this.jobsCompletedHistory[5]) / 5 || 0 },
          { x: '25', y: (this.jobsCompletedHistory[5] - this.jobsCompletedHistory[6]) / 5 || 0 },
          { x: '30', y: (this.jobsCompletedHistory[6] - this.jobsCompletedHistory[7]) / 5 || 0 },
          { x: '35', y: (this.jobsCompletedHistory[7] - this.jobsCompletedHistory[8]) / 5 || 0 },
          { x: '40', y: (this.jobsCompletedHistory[8] - this.jobsCompletedHistory[9]) / 5 || 0 },
          { x: '45', y: (this.jobsCompletedHistory[9] - this.jobsCompletedHistory[10]) / 5 || 0 },
          { x: '50', y: (this.jobsCompletedHistory[10] - this.jobsCompletedHistory[11]) / 5 || 0 },
          { x: '55', y: (this.jobsCompletedHistory[11] - this.jobsCompletedHistory[12]) / 5 || 0 },
          { x: '60', y: (this.jobsCompletedHistory[12] - this.jobsCompletedHistory[13]) / 5 || 0 },
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
        dataPoints: this.setDataPoints(this.queuedJobsCountHistory),
      }],
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
          dataPoints: this.setDataPoints(this.failedJobsCountHistory),
        },
      ]
    });

    var totalMemoryChart = new CanvasJS.Chart('total_memory_container', {
      title: {
        text: 'Memory Usage',
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
        title: 'Memory (mb)'
      },
      data: [{
        type: "line",
        showInLegend: true,
        name: "Memory usage",
        color: "#20B2AA",
        markerType: 'circle',
        lineThickness: 2,
        dataPoints: this.setDataPoints(this.totalMemoryHistory),
      }],
    });

    queuedJobsChart.render();
    failedJobsChart.render();
    processedJobsChart.render();
    totalMemoryChart.render();
  },
  setDataPoints: function(array) {
    data = [
      { x: '0', y: array[0] },
      { x: '5', y: array[1] },
      { x: '10', y: array[2] },
      { x: '15', y: array[3] },
      { x: '20', y: array[4] },
      { x: '25', y: array[5] },
      { x: '30', y: array[6] },
      { x: '35', y: array[7] },
      { x: '40', y: array[8] },
      { x: '45', y: array[9] },
      { x: '50', y: array[10] },
      { x: '55', y: array[11] },
      { x: '60', y: array[12] },
    ];

    return data;
  },
  setActiveTab: function() {
    this.tab = $(location).attr('href').split('/').pop();
    var $active = $('a[href=' + this.tab + ']');

    $active.css('background', '#a2a2a2');
    $active.css('color', '#fff');
  },
  pollData: function(tab) {
    if (tab === 'overview') {
      this.getOverviewData();

      setInterval(function() {
        this.getOverviewData();
      }.bind(this), 5000);
    }

    if (tab === 'queues') {
      setInterval(function() {
        this.getQueueData();
      }.bind(this), 5000);
    }

    if (tab === 'details') {
      setInterval(function() {
        this.getDetailData();
      }.bind(this), 5000);
    }
  },
  bindEvents: function() {
    $('#memory_usage').on('click', function(e) {
      $('.nested th').toggle();
    });
  },
  init: function() {
    this.setActiveTab();
    this.bindEvents();
    this.pollData(this.tab);
  }
}

$(document).ready(App.init.bind(App));
