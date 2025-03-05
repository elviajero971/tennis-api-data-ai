class MessagesController < ApplicationController
  def index
    @messages = Message.all.order(created_at: :asc)
  end

  def create
    @user_message = Message.create(
      content: params[:content],
      role: "user"
    )

    @assistant_message = Message.create(
      content: "Searching the answer for you...",
      role: "assistant"
    )

    ProcessChatMessageJob.perform_later(@user_message, @assistant_message)

    head :ok
  end
end
