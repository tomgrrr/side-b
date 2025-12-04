class MessagesController < ApplicationController
   def create
    @matches = Match.all
    system_prompt = "You are a Vinyl collector, a music expert and assistant.\n\n I am somebody who wants to have new suggestions about vinyls so I can grow my vinyl collection.\n\n Help me get the most relevant vinyls, based on my musical taste and vinyl collection .\n\n Answer concisely in Markdown."
    @chat = current_user.chats.find(params[:chat_id])

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"
    if @message.save!
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(instructions(system_prompt,challenge_context(@matches))).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)
      @chat.generate_title_from_first_message
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private
  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

  def challenge_context(matches)

  end

  def instructions(prompt, matches)
    [prompt, matches].compact.join("\n\n")
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
