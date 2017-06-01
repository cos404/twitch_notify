require 'yaml'
require 'telegram/bot'
require './twitch-api/base.rb'

token = '382897175:AAHTpTpyWAakEIwBpasJQzQ_gyew4tf9ERI'

@twitch = Base.new({
  client_id: '9hkyghtspdabk7g2eyqpqntayfmnzr',
  secret_key: 'ry7mv0tjq2v2jbfsz0zhjccm8b21d0',
  redirect_uri: 'https://localhost:3000/',
  scope: ["user_read", "channel_read", "user_follows_edit"],
  access_token: '0f2wea68a2yhgzhhvkhpcg4gj4by1v'
})


last_update = YAML.load_file('streamers.yml')


# Telegram::Bot::Client.run(token) do |bot|
#   puts "Run"
#   bot.listen do |message|
#     msg = message.text
#     chat_id = message.chat.id
#     first_name = message.from.first_name
#     case msg
#       when '/start'
#         bot.api.sendMessage(chat_id: chat_id, text: "Hello, #{first_name}")
#       when /\/add (.+)/
#         streamer = msg.sub(/\/add /, "")

#         last_update = {} unless last_update
#         last_update[chat_id] = [] if last_update[chat_id] == nil
#         last_update[chat_id] << [streamer, false] unless last_update[chat_id].include?(streamer)

#         File.open('streamers.yml','w+') do |h|
#           puts h.to_yaml
#           puts h.to_s
#           h.write(last_update.to_yaml)
#         end

#     end
#   end
# end

loop do
  last_update.length.times do |group_num|
    last_update[last_update.keys[group_num]].length.times do |streamer_num|

      keys = last_update.keys[group_num]
      s = last_update[keys][streamer_num][0]
      s = @twitch.stream(s)

      puts "#{streamer_num}: Stream RUN" if s["stream"] && last_update[keys][streamer_num][1] == false
      last_update[keys][streamer_num][1] = true if s["stream"]
      last_update[keys][streamer_num][1] = false unless s["stream"]
    end
  end
  puts "Stream run: cancel"
  sleep(6)
end
