require 'java'

java_import org.apache.hadoop.hbase.HBaseConfiguration
java_import org.apache.hadoop.hbase.client.HConnectionManager
java_import org.apache.hadoop.hbase.client.Scan
java_import org.apache.hadoop.hbase.util.Bytes
java_import org.apache.hadoop.hbase.CellUtil
java_import org.apache.hadoop.hbase.HConstants

module Embulk
  class InputHBase < InputPlugin
    Plugin.register_input('hbase', self)

    def self.transaction(config, &control)
      host_name = config.param('host', :string, default: 'localhost')
      table_name = config.param('table', :string)

      columns = config.param('columns', :array).map.with_index { |column, i|
        Column.new(i, column['name'], column['type'].to_sym)
      }

      connection = connect(host_name)
      table = connection.getTable(table_name)
      regions = table.getRegionsInRange(HConstants::EMPTY_START_ROW, HConstants::EMPTY_END_ROW).map { |location|
        location.getRegionInfo.getRegionNameAsString
      }

      task = {
        'host' => host_name,
        'table' => table_name,
        'regions' => regions
      }
      threads = regions.size
      commit_reports = yield(task, columns, threads)
      return {}
    end

    def self.connect(host_name)
      conf = HBaseConfiguration.create
      conf.set('hbase.zookeeper.quorum', host_name)
      HConnectionManager.createConnection(conf)
    end

    def initialize(task, schema, index, page_builder)
      super
    end

    def run
      connection = self.class.connect(@task['host'])
      table = connection.getTable(@task['table'])
      region = connection.locateRegion(Bytes.toBytes(@task['regions'][@index])).getRegionInfo
      scan = Scan.new(region.getStartKey, region.getEndKey)
      scanner = table.getScanner(scan)
      scanner.each { |result|
        @page_builder.add(@schema.map { |column|
          family, qualifier = column.name.split(':').map {|e|
            Bytes.toBytes(e)
          }
          raw = nil
          if result.containsColumn(family, qualifier) then
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
