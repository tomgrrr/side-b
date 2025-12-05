class RecommandationsJob < ApplicationJob
  queue_as :default

def system_prompt
  "You are an assistant for an e-commerce website. \
  Your task is to answer questions about the products and recommend the most relevant one and explain why. \
  Always share the name and URL of the product. \
  If you don't know the answer, you can say \"I don't know\". \
  Your answer should be in markdown. \
  Here are the nearest catalog products based on the user's question: "
end

def product_prompt(product)
  "PRODUCT id: #{product.id}, name: #{product.name}, description: #{product.description}, url: #{product_url(product)}"
end

  def perform

    @chat = Chat.find(params[:chat_id])
    embedding = RubyLLM.embed(params[:message][:content])
    products = Product.nearest_neighbors(:embedding, embedding.vectors, distance: "euclidean").first(2)
    instructions = system_prompt
    instructions += products.map { |product| product_prompt(product) }.join("\n\n")
  
  end
end
