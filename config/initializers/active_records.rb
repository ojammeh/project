module ActiveRecord
  module ConnectionAdapters
    class SQLServerAdapter < AbstractAdapter
      SUPPORTED_VERSIONS << 2014
      # === SQLServer Specific (DB Reflection) ======================== #

      def sqlserver_2014?
        @database_year = 2014
      end
    end
  end
end