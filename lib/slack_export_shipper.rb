#!/usr/bin/env ruby
# coding: utf-8

require 'date'
require 'elasticsearch'
require 'fileutils'
require 'json'
require 'pp'
require 'ruby-progressbar'
require 'pry'

module SlackExportShipper
  class Shipper
    def initialize(logdir, index_prefix: 'slack', workspace: '')
      @logdir = logdir
      @es = Elasticsearch::Client.new(request_timeout: 180)
      @index_prefix = 'slack'
      @workspace = workspace
      @batch_size = 500
    end

    def ship
      channels.each do |channel|
        ship_channel(channel)
      end
    end

    def ship_channel(channel)
      puts "shipping \"#{channel}\" ..."
      channel_messages = load_channel(channel)
      docs = aggregate(channel_messages, channel_name: channel)
      bulk_index(docs)
    end

    def users
      @users ||= JSON.load(File.open("#{@logdir}/users.json"))
      return @users
    end

    def userid2name(id)
      user = users.find {|i| i['id'] == id }
      return user.nil? ? id : user['name']
    end

    def name2userid(name)
      user = users.find {|i| i['name'] == name }
      return user.nil? ? nil : user['id']
    end

    def channels
      @channels ||= Dir.entries(@logdir).select do |i|
        File.directory?(File.join(@logdir, i)) and ['.', '..'].include?(i).!
      end

      return @channels
    end

    def load_channel(channel_name)
      channel = {}

      Dir.entries("#{@logdir}/#{channel_name}").each do |i|
        next if ['.', '..'].include?(i)
        channel[i.chomp('.json')] = JSON.load(File.open("#{@logdir}/#{channel_name}/#{i}"))
      end

      return channel
    end

    # regroup by local date for elasticsearch's indexing reason
    def aggregate(channel_messages, channel_name: '')
      docs = {}

      channel_messages.values.flatten.each do |i|
        ts = i['ts'].to_f
        datetime = Time.at(ts).to_datetime
        index = datetime.strftime("#{@index_prefix}-%Y.%m.%d")

        i['@timestamp'] = datetime.to_s
        i['hour_of_day'] = datetime.hour
        i['day_of_week'] = datetime.wday
        i['user_name'] = userid2name(i['user']) unless i['user'].nil?
        i['channel_name'] = channel_name unless channel_name.empty?
        i['workspace'] = @workspace unless @workspace.empty?

        docs[index] ||= []
        docs[index] << i
      end

      return docs
    end

    def bulk_index(docs)
      bulk_body = []
      total = docs.values.inject(0){|m, i| m + i.size}
      pb = ProgressBar.create(total: total, format: "|%B| %c/%C")

      docs.each do |index, messages|
        messages.each do |message|
          bulk_body << {
            index: {
              _index: index,
              _type: 'slack-message',
              data: message
            }
          }
        end

        if bulk_body.size > @batch_size
          @es.bulk(body: bulk_body) if bulk_body.size > @batch_size
          pb.progress += bulk_body.size
          bulk_body = []
        end
      end

      @es.bulk body:bulk_body unless bulk_body.empty?
      pb.progress += bulk_body.size
    end
  end
end
