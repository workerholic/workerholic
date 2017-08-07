# workerholic
A Background Job Processing Manager

## Features

- ### Job retry
       Workerholic will retry every unsuccessfully performed job up to 5 times before placing it into a failed jobs queue.

- ### Job scheduler
       You can schedule a job to be performed at certain time

- ### Job persistence in Redis
       Every job (both active and completed) is stored in a Redis database. This way you will not lose any jobs even if your application crashes.

- ### Graceful shutdown
       Workerholic will finish all currently processing jobs before shutting down. 

- ### Web UI with statistics
       Detailed statistics for processed jobs, queues sizes, overall performance and memory usage.

- ### Workers provisioning
       each worker is treated as a separate entity with its state changing dynamically based on the current number of jobs to perform.

- ### Auto-balancing
       By default, each job queue will get a fair number of workers assigned to it. With provided optional argument, Workerholic can dynamically reassign workers to different queues depending on the number of jobs in each queue.

- ### Multi-process execution
       Workerholic can be executed in multiple processes to utilize different CPU cores (MRI)
