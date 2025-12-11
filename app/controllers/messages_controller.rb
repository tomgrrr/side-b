class MessagesController < ApplicationController
  include ActionView::RecordIdentifier

  def create
    @chat = current_user.chats.find(params[:chat_id])
    user_question_embedding = RubyLLM.embed(params[:message][:content])

    @relevant_vinyls = Vinyl.nearest_neighbors(
      :embedding,
      user_question_embedding.vectors,
      distance: "cosine"
    ).first(4)

    user_collection = current_user.matches.includes(vinyl: [:artists, :genres])

    system_prompt = base_system_prompt
    system_prompt += user_collection_context(user_collection)
    system_prompt += catalog_vinyls_context(@relevant_vinyls)

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save

      @assistant_message = @chat.messages.create!(role: "assistant", content: "")

      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history

      @ruby_llm_chat.with_instructions(system_prompt).ask(@message.content) do |chunk|
        next if chunk.content.blank?

        @assistant_message.content += chunk.content
        broadcast_replace(@assistant_message)
      end

      @assistant_message.save!
      broadcast_replace(@assistant_message)

      @chat.generate_title_from_first_message

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def broadcast_replace(message)
    Turbo::StreamsChannel.broadcast_replace_to(
      @chat,
      target: dom_id(message),
      partial: "messages/message",
      locals: { message: message }
    )
  end

  def build_conversation_history
    @chat.messages.each do |message|
      next if message.content.blank?
      next if message.id == @assistant_message.id

      @ruby_llm_chat.add_message(message)
    end
  end

  def base_system_prompt
<<~PROMPT
      You are a specialized assistant for vinyl record recommendations for collectors.

      # ⚠️ ABSOLUTE RULES - NON-NEGOTIABLE:
      1. ❌ You can ONLY recommend vinyls listed in the "📀 AVAILABLE CATALOG" section
      2. ❌ You MUST NEVER invent, imagine, or mention a vinyl that is NOT in the provided catalog
      3. ❌ You MUST NEVER recommend a vinyl from the "📀 USER'S COLLECTION" (they already own it)
      4. ✅ If NO vinyl in the catalog matches the request, you MUST respond exactly:
        "Sorry, I couldn't find any vinyl matching your request in our current catalog. Try rephrasing your search or explore other genres!"

      # 🎯 YOUR MISSION:
      - Analyze the user's current collection to understand their musical tastes (genres, artists, eras)
      - Recommend ONLY vinyls from the provided catalog that match their preferences
      - Clearly explain why each recommended vinyl will appeal to them
      - Limit recommendations to 3 to avoid overwhelming the user

      # 📐 MANDATORY RESPONSE FORMAT:
      Start with a brief intro sentence, then for each vinyl use this EXACT format with line breaks:

      ---

      **[Album Name]** by [Artist Name]

      **Why this choice:** [Personalized explanation - 1-2 sentences max]

      [View this vinyl](/vinyls/[ID])

      ---

      End with a short encouraging sentence.

      # ✅ EXAMPLE OF A GOOD RESPONSE:

      Based on your jazz collection, here are my recommendations:

      ---

      **Blue Train** by John Coltrane

      **Genres:** Jazz, Bebop
      **Year:** 1957
      **Price:** 32€

      **Why this choice:** Since you own "A Love Supreme," you'll love this Coltrane classic with its explosive improvisations.

      [View this vinyl](/vinyls/23)

      ---

      **Kind of Blue** by Miles Davis

      **Genres:** Jazz, Modal Jazz
      **Year:** 1959
      **Price:** 28€

      **Why this choice:** A must-have that perfectly complements your collection with its revolutionary modal approach.

      [View this vinyl](/vinyls/45)

      ---

      Enjoy exploring these timeless gems!

      # ❌ THINGS TO AVOID:
      - Don't put everything on one line
      - Don't forget the --- separators between vinyls
      - Don't skip line breaks
      - Don't invent vinyls not in the catalog

      # 🎨 RESPONSE STYLE:
      - Warm and collector-passionate tone
      - Natural use of "you" (informal)
      - Concise but personalized
      - Use line breaks for readability
    PROMPT
  end

  def user_collection_context(matches)
    return "" if matches.empty?

    context = "\n📀 User's Current Collection:\n"
    matches.each do |match|
      vinyl = match.vinyl
      artists = vinyl.artists.map(&:name).join(", ")
      genres = vinyl.genres.map(&:name).join(", ")

      context += "- **#{vinyl.name}** by #{artists} (#{genres})"
      context += " - Category: #{match.category}" if match.category.present?
      context += "\n"
    end

    context
  end

  def catalog_vinyls_context(vinyls)
    context = "\n\n## 🎵 Available Vinyls in Catalog:\n\n"
    vinyls.each do |vinyl|
      context += vinyl_context(vinyl)
      context += "\n---\n\n"
    end

    context
  end

  def vinyl_context(vinyl)
    artists_names = vinyl.artists.map(&:name).join(", ")
    genres_names = vinyl.genres.map(&:name).join(", ")

    "**VINYL ID**: #{vinyl.id}\n" \
    "**Name**: #{vinyl.name}\n" \
    "**Artists**: #{artists_names}\n" \
    "**Genres**: #{genres_names}\n" \
    "**Year**: #{vinyl.release_date}\n" \
    "**Price**: #{vinyl.price}€\n" \
    "**Notes**: #{vinyl.notes}\n" \
    "**URL**: #{vinyl_url(vinyl)}"
  end

  def message_params
    params.require(:message).permit(:content, :file)
  end
end
