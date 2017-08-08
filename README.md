# Workerholic: background job processor

## Summary

Workerholic is a multi-threaded, multi-process background job processing manager. It is an experimental project and as such is not meant to replace other stable engines like Sidekiq or Resque. In fact, Workerholic is inspired in large part by these projects.

In general, background job managers are great for asynchronous processing of time-consuming tasks like calling third party APIs and performing long calculations. What we are building aims to cover all those use cases.

## Features
### Overview
#### Here's a brief overview of Workerholic's data flow:
- enqueue a job
- job is serialized and added to queue in Redis
- workers pick jobs from Redis queues, deserialize and process them
- on completion (or failure), relevant statistics are added to Redis
- web-ui monitors application metrics and outputs the result

### Job retry
  Workerholic will retry every unsuccessfully performed job up to 5 times before placing it into a failed jobs queue

### Multiple queues
  It is possible to specify your own queues for each job your application needs to perform. This way every job has its own namespace and can be easily distinguished between multiple jobs.

### Job scheduler
  You can schedule a job to be performed at certain time

### Job persistence in Redis
  Every job (both active and completed) is stored in a Redis database. This way you will not lose any jobs even if your application crashes

### Graceful shutdown
  Workerholic will finish all currently processing jobs before shutting down

### Web UI with statistics
  Detailed statistics for processed jobs, queues sizes, overall performance and memory usage

### Workers provisioning
  Each worker is treated as a separate entity with its state changing dynamically based on the current number of jobs to perform

### Auto-balancing
  By default, each job queue will get a fair number of workers assigned to it. With provided optional argument, Workerholic can dynamically reassign workers to different queues depending on the number of jobs in each queue

### Multi-process execution
  Workerholic can be executed in multiple processes to utilize different CPU cores (MRI)

## Installation
### Installing the gem
Install the gem with the following command:

    $ gem install workerholic

Or, add the following line to your application's Gemfile:

    gem 'workerholic', '~> 0.1'

And then make sure to execute the following command:

    $ bundle install

### Starting Redis
In order to start Redis, execute the following:

    redis-server

By default, Workerholic will try to connect to Redis via `localhost:6379`.

For a production environment, make sure to set a `REDIS_URL` environment variable to the address of your redis server.

## Usage
### Including Workerholic

In order to perform your jobs asynchronously you will need to include Workerholic in your job classes:

```ruby
class MyJob
  include Workerholic::Job

  def perform(args)
    # job logic goes here
  end
end
```

It is important to follow this pattern:
- include `Workerholic::Job` in your job class
- define a `perform` method holding your job's logic

### Job Options
#### Specifying a Queue

Workerholic allows you to specify a name for the queue that your job will be enqueued in:

```ruby
class MyJob
  include Workerholic::Job

  job_options queue_name: 'my_queue'

  def perform(args)
    # job logic goes here
  end
end
```

#### Performing a Job Asynchronously

You can perform a job asynchronously:

```ruby
my_job = MyJob.new
my_job.perform_async(arg1, arg2)
```

This will ensure that your job is performed in the background, asynchronously, as soon as possible.

#### Scheduling the Job

You can schedule a job to be executed at a later time:

```ruby
my_job = MyJob.new
my_job.peform_delayed(100, arg1, arg2)
```

The above example ensures that `my_job` will be performed in 100 seconds.

## Configuration
### Loading Application's Files
#### For a Rails Application

When using Workerholic with a Rails application, as long as you make sure to start Workerholic from the root directory of your Rails application, it will automatically detect your Rails application and eager load your application's files.

#### For Another Application

For Workerholic to execute the jobs you enqueue properly it needs to have access to the job classes.

Make sure to require all classes/dependencies needed with a single file:

    workerholic -r my_app/all_dependencies_needed.rb

### Setting Number of Workers

When starting Workerholic you can specify the number of workers you want running and performing jobs:

    workerholic -w 25

### Setting Number of Redis Connections

Internally, Workerholic uses a connection pool. By default, Workerholic will create a connection pool with a number of `workers_count + 5` Redis connections.

In a production environment, you might be limited by the number of concurrent connections to Redis you are allowed to have. Make sure to check what the limit is and you can then start Workerholic by specifying a number of connections:

    workerholic -c 10

### Setting Number of Processes to Boot

Workerholic allows you to start multiple processes in parallel by forking children processes from the main process. This can be achieved with the following option:

    workerholic -p 3

This will allow you to run 3 processes in parallel, with each process having its own workers and connection pool to Redis.

## Integration
### ActiveJob

Workerholic integrates with ActiveJob. Add the following line to your `application.rb` file:

```ruby
class Application < Rails::Application
  # ...

  config.active_job.queue_adapter = :workerholic

  # ...
end
```

After that line is added, you can use `ActiveJob`'s API to execute your jobs asynchronously:

```ruby
class MyJob < ApplicationJob
  queue_as: 'my_queue'

  def perform(args)
    # job logic goes here
  end
end

MyJob.perform_later(args)
```

### Web UI

Workerholic comes with a Web UI tracking various statistics about the jobs that are being performed.

#### For a Rails Application

For a Rails application you will need to mount the Web UI on a specific route. In your `routes.rb` file make sure to add the following:

```ruby
require 'workerholic/web/application'

Rails.application.routes.draw do
  # ...

  mount WorkerholicWeb => '/workerholic'

  # ...
end
```

#### For Another Application

If you are using another kind of application, you can start the Web UI using the following command:

    workerholic-web

You can then view the the app at: `localhost:4567`
