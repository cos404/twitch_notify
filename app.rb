require 'yaml'
require 'telegram/bot'
require './twitch-api/base.rb'

token = ENV['TOKEN']

@twitch = Base.new(
  client_id: ENV['CLIENT_ID'],
  secret_key: ENV['SECRET_KEY'],
  redirect_uri: 'https://localhost:3000/',
  scope: %w[user_read channel_read user_follows_edit],
  access_token: ENV['ACCESS_TOKEN']
)

streamers_list = YAML.load_file('streamers.yml')

Telegram::Bot::Client.run(token) do |bot|
  # STREAM CHECKOUT
  Thread.new do
    loop do
      puts 'Stream check: RUN'
      streamers_list.length.times do |group_num|
        keys = streamers_list.keys[group_num]
        chat_id = streamers_list[keys]

        chat_id.length.times do |streamer_num|
          streamer = chat_id[streamer_num]
          result = @twitch.stream(streamer[0])

          puts "#{Time.now.strftime("%H:%M")} Stream: #{streamer[0]}."

          bot.api.sendMessage(chat_id: keys, text: "https://www.twitch.tv/#{streamer[0]}") if result['stream'] && !streamer[1]

          streamer[1] = true if result['stream']
          streamer[1] = false unless result['stream']
        end
      end
      puts 'Stream check: END'
      sleep 10
    end
  end

  # TELEGRAM COMMANDS
  bot.listen do |message|
    msg = message.text
    chat_id = message.chat.id
    first_name = message.from.first_name
    case msg
    when '/start'
      bot.api.sendMessage(chat_id: chat_id, text: "Hello, #{first_name}")
    when %r{\/add (.+)}
      streamer = msg.sub(%r{\/add }, '').gsub(" ", "")
      streamers_list = {} unless streamers_list
      streamers_list[chat_id] = [] if streamers_list[chat_id].nil?
      streamers_list[chat_id] << [streamer, false] unless streamers_list[chat_id].include?(streamer)

      File.open('streamers.yml', 'w+') do |f|
        f.write(streamers_list.to_yaml)
      end
    end
  end
end
