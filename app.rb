require 'yaml'
require 'telegram/bot'
require './twitch-api/base.rb'

token = ENV['TOKEN']

@twitch = Base.new({
  client_id: ENV['CLIENT_ID'],
  secret_key: ENV['SECRET_KEY'],
  redirect_uri: 'https://localhost:3000/',
  scope: ["user_read", "channel_read", "user_follows_edit"],
  access_token: ENV['ACCESS_TOKEN']
})

last_update = YAML.load_file('streamers.yml')

Telegram::Bot::Client.run(token) do |bot|
  puts "Run"

  # STREAM CHECKOUT
  Thread.new do
    loop do
      puts "Stream check: RUN"
      last_update.length.times do |group_num|
        keys = last_update.keys[group_num]

        last_update[keys].length.times do |streamer_num|

          streamer_name = last_update[keys][streamer_num][0]
          result = @twitch.stream(streamer_name)

          bot.api.sendMessage(chat_id: keys, text: "#{streamer_name}: Stream RUN") if result["stream"] && !last_update[keys][streamer_num][1]
          last_update[keys][streamer_num][1] = true if result["stream"]
          last_update[keys][streamer_num][1] = false unless result["stream"]
        end
      end
      puts "Stream check: END"
      sleep 300
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
      when /\/add (.+)/
        streamer = msg.sub(/\/add /, "")
        last_update = {} unless last_update
        last_update[chat_id] = [] if last_update[chat_id] == nil
        last_update[chat_id] << [streamer, false] unless last_update[chat_id].include?(streamer)

        File.open('streamers.yml','w+') do |f|
          f.write(last_update.to_yaml)
        end
    end
  end
end