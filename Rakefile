require_relative 'lib/slack_export_shipper'

desc '[bundle exec] rake ship logdir=/path/to/unzipped/logs [host=localhost:9200] [channel=general]'
task :ship do
  # elasticsearch's host address
  host = ENV['host'] || 'localhost:9200'
  shipper = SlackExportShipper::Shipper.new(ENV['logdir'], host)

  unless ENV['channel'].nil?
    shipper.ship_channel(ENV['channel'])
  else
    shipper.ship
  end
end
