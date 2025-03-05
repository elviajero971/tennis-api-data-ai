#jobs/TasksJob.rb
class TasksJob < ApplicationJob
  queue_as :default

  def perform
    p "hello"
    sleep 3
    p "world"

    Turbo::StreamsChannel.broadcast_replace_to(
      "task_channel",
      target: "task",
      partial: "tasks/completed",
    )
  end
end
