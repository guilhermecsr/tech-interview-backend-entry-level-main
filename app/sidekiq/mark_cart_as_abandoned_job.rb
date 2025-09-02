class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    ::CartsCleanupJob.new.perform(*args)
  end
end
