require_relative 'lib/slack_export_shipper'

desc 'Ship logs of 1 channel to elasticsearch'
task :ship_channel do
  shipper = SlackExportShipper::Shipper.new(ENV['logdir'])
  shipper.ship_channel(ENV['channel'])
end

desc 'Ship logs of all channels to elasticsearch'
task :ship do
  shipper = SlackExportShipper::Shipper.new(ENV['logdir'])
  shipper.ship
end
