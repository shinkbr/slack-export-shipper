require_relative 'lib/slack_export_shipper'

desc '[bundle exec] rake ship logdir=/path/to/unzipped/logs [channel=general]'
task :ship do
  shipper = SlackExportShipper::Shipper.new(ENV['logdir'])

  unless ENV['channel'].nil?
    shipper.ship_channel(ENV['channel'])
  else
    shipper.ship
  end
end
