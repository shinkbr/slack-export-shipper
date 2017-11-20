# slack-export-shipper

## About
This is a tool to ship Slack's exported log into Elasticsearch.

## How to

### Export Slack messages
- Export your Slack log from https://my.slack.com/services/export
- `unzip -d /path/to/unzip exported-log.zip`

### Set up this repository
- Prepare Ruby >= 2.4.2
- `bundle install`

As of now this assumes a very basic installation of Elasticsearch on port 9200.

### Run
This can take quite a long time depending on the size of your log.

Ship all channels:

```
$ bundle exec rake ship logdir=/path/you/unzipped
```

Ship a specific channel:

```
$ bundle exec rake ship_channel logdir=/path/you/unzipped channel=random
```
