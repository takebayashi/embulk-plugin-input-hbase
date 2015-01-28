require 'hbaserb'

module Embulk
  class InputHBase < InputPlugin
    Plugin.register_input('hbase', self)

    def self.transaction(config, &control)
      task = {
        'host' => config.param('host', :string, default: 'localhost'),
        'table' => config.param('table', :string)
      }
      threads = 1
      columns = [
        # Column.new(0, 'col0', :long),
        # Column.new(1, 'col1', :double),
        # Column.new(2, 'col2', :string),
      ]
      commit_reports = yield(task, columns, threads)
      return {}
    end

    def initialize(task, schema, index, page_builder)
      super
    end

    def run
      client = HBaseRb::Client.new task['host']
      table = client.get_table task['table']
      table.create_scanner() { |row|
        # @page_builder.add([i, 10.0, "example"])
      }
      @page_builder.finish
      commit_report = {
      }
      return commit_report
    end
  end
end
