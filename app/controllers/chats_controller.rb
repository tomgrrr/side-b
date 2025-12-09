class ChatsController < ApplicationController
def create
    @chat = Chat.new(title: Chat::DEFAULT_TITLE)
    @chat.user = current_user

    if @chat.save
      redirect_to chat_path(@chat)
    else
      render "pages/home"
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end

  def destroy
    @chat = Chat.find(params[:id])
    @chat.destroy

  redirect_to chats_path, status: :see_other
  end
end
