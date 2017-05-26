require 'yaml'
require 'telegram/bot'
token = '382897175:AAHTpTpyWAakEIwBpasJQzQ_gyew4tf9ERI'
# require './twitch-api/base.rb'

# @twitch = Base.new({
#   client_id: '9hkyghtspdabk7g2eyqpqntayfmnzr',
#   secret_key: 'ry7mv0tjq2v2jbfsz0zhjccm8b21d0',
#   redirect_uri: 'https://localhost:3000/',
#   scope: ["user_read", "channel_read", "user_follows_edit"],
#   access_token: '0f2wea68a2yhgzhhvkhpcg4gj4by1v'
# })

# twitch = []
# twitch << @twitch.stream('a1taoda')
# twitch << @twitch.stream('guit88man')


# twitch.each do |t|
#   puts t["stream"] if t["stream"]
# end






# streamers.each do |f|
#     f[213123131313] << streamer if f.exists?(group_id)
#     f << [213123131313] << streamer unless f.exists?(group_id)
# end

Telegram::Bot::Client.run(token) do |bot|
  puts "Run"
  bot.listen do |message|
    msg = message.text
    chat_id = message.chat.id
    case msg
      when '/start'
        bot.api.sendMessage(chat_id: msg.chat.id, text: "Hello, #{msg.from.first_name}")
      when /\/add (.+)/
        streamer = msg.sub(/\/add /, "")

        last_update = YAML.load_file('streamers.yml')
        last_update = {} unless last_update
        last_update[chat_id] = [] if last_update[chat_id] == nil
        last_update[chat_id] << streamer unless last_update[chat_id].include?(streamer)
        File.open('streamers.yml','w') do |h|
          h.write(last_update.to_yaml)
        end
    end

  end
end