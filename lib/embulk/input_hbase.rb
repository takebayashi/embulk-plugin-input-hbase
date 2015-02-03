require 'java'

java_import org.apache.hadoop.hbase.HBaseConfiguration
java_import org.apache.hadoop.hbase.client.HConnectionManager
java_import org.apache.hadoop.hbase.client.Scan
java_import org.apache.hadoop.hbase.util.Bytes
java_import org.apache.hadoop.hbase.CellUtil

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
        Column.new(i, column['name'], column['type'].to_sym)
      }
      commit_reports = yield(task, columns, threads)
      return {}
    end

    def initialize(task, schema, index, page_builder)
      super
    end

    def run
      conf = HBaseConfiguration.create
      conf.set('hbase.zookeeper.quorum', @task['host'])
      connection = HConnectionManager.createConnection(conf)
      table = connection.getTable(@task['table'])
      scan = Scan.new
      scanner = table.getScanner(scan)
      scanner.each { |result|
        @page_builder.add(@schema.map { |column|
          family, qualifier = column.name.split(':').map {|e|
            Bytes.toBytes(e)
          }
          raw = nil
          if table.containsColumn(family, qualifier) then
            cell = result.getColumnLatestCell(family, qualifier)
            raw = CellUtil.cloneValue(cell)
          end
          if raw then
            case column.type
            when :long
              Bytes.toLong(raw)
            when :string
              Bytes.toString(raw)
            else
              raw
            end
          else
            nil
          end
        })
      }
      @page_builder.finish
      commit_report = {
      }
      return commit_report
    end
  end
end
