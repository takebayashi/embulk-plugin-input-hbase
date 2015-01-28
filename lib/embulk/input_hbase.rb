require 'hbase-jruby'

module Embulk
  class InputHBase < InputPlugin
    Plugin.register_input('hbase', self)

    def self.transaction(config, &control)
      task = {
        'host' => config.param('host', :string, default: 'localhost'),
        'table' => config.param('table', :string)
      }
      threads = 1
      columns = config.param('columns', :array).map.with_index { |column, i|
        Columns.new(i, column['name'], column['type'].to_sym)
      }
      commit_reports = yield(task, columns, threads)
      return {}
    end

    def initialize(task, schema, index, page_builder)
      super
    end

    def run
      hbase = HBase.new('hbase.zookeeper.quorum' => task['host'])
      table = hbase.table(task['table'])
      table.each { |row|
        @page_builder.add(schema.map { |column|
          row[column.name]
        })
      }
      @page_builder.finish
      commit_report = {
      }
      return commit_report
    end
  end
end
