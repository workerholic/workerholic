# $LOAD_PATH << __dir__ + '/../..'

require 'sinatra/base'

# require 'sinatra/reloader'
require 'json'
require 'workerholic'

class WorkerholicWeb < Sinatra::Base

  get '/' do
    if defined? Rails
      redirect '/workerholic/overview'
    else
      redirect '/overview'
    end
  end

  get '/overview' do
    @processes = Workerholic::StatsAPI.process_stats

    erb :overview
  end

  get '/details' do
    completed_jobs = Workerholic::StatsAPI.job_statistics(category: 'completed_jobs', count_only: true)
    failed_jobs = Workerholic::StatsAPI.job_statistics(category: 'failed_jobs', count_only: true)

    @job_stats = {}
    @completed_total = 0
    @failed_total = 0

    completed_jobs.each do |job|
      @job_stats[job[0]] = { completed: job[1] }
      @completed_total += job[1]
    end

    failed_jobs.each do |job|
      if @job_stats[job[0]]
        @job_stats[job[0]].merge({ failed: job[1] })
      else
        @job_stats[job[0]] = { failed: job[1] }
      end
      @failed_total += job[1]
    end

    erb :details
  end

  get '/queues' do
    @queues = Workerholic::StatsAPI.queued_jobs
    @total = 0
    @queues.each do |queue|
      @total += queue[1]
    end

    erb :queues
  end

  get '/history' do
    @days = params[:days]
    @classes = Workerholic::StatsAPI.jobs_classes(true)
    @class = params[:class] || 'completed'

    erb :history
  end

  get '/overview-data-on-load' do
    JSON.generate({
      completed_jobs: Workerholic::StatsAPI.job_statistics_history('completed_jobs'),
      failed_jobs: Workerholic::StatsAPI.job_statistics_history('failed_jobs')
    })
  end

  get '/overview-data' do
    JSON.generate({
      completed_jobs: Workerholic::StatsAPI.job_statistics( {category: 'completed_jobs', count_only: true} ),
      failed_jobs: Workerholic::StatsAPI.job_statistics( {category: 'failed_jobs', count_only: true} ),
      queued_jobs: Workerholic::StatsAPI.queued_jobs,
      scheduled_jobs: Workerholic::StatsAPI.scheduled_jobs( { count_only: true }),
      memory_usage: Workerholic::StatsAPI.process_stats,
      completed_jobs_per_second: Workerholic::StatsAPI.job_statistics_history('completed_jobs'),
    })
  end

  get '/details-data' do
    JSON.generate({
      completed_jobs: Workerholic::StatsAPI.job_statistics( {category: 'completed_jobs', count_only: true} ),
      failed_jobs: Workerholic::StatsAPI.job_statistics( {category: 'failed_jobs', count_only: true} )
    })
  end

  get '/queues-data' do
    JSON.generate({
      queued_jobs: Workerholic::StatsAPI.queued_jobs
    })
  end

  get '/historic-data' do
    puts params[:className]
    params[:className] = nil if params[:className] == 'completed'

    JSON.generate({
      completed_jobs: Workerholic::StatsAPI.history_for_period({ category: 'completed_jobs', klass: params[:className], period: params[:days].to_i }),
      failed_jobs: Workerholic::StatsAPI.history_for_period({ category: 'failed_jobs', klass: params[:className], period: params[:days].to_i })
    })
  end
end
