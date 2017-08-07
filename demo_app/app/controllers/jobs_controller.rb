class JobsController < ApplicationController
  def create
    if parse_jobs.all?(&:zero?)
      flash[:error] = 'Please add at least 1 job.'
      redirect_to root_path and return
    end

    non_blocking, cpu, io = parse_jobs

    non_blocking.times do |n|
      NonBlockingJob.new.perform_async(n)
    end

    cpu.times do
      CpuBoundJob.new.perform_async(1000)
    end

    io.times do |n|
      IoBoundJob.new.perform_async
    end

    counter = parse_jobs.reduce(:+)

    flash[:success] = "Successfully added #{counter} jobs."
    redirect_to root_path
  end

  private

  def job_params
    params.require(:jobs).permit(:non_blocking, :cpu_bound, :io_bound)
  end

  def parse_jobs
    jobs = params[:jobs]
    [jobs[:non_blocking].to_i, jobs[:cpu_bound].to_i, jobs[:io_bound].to_i]
  end
end
