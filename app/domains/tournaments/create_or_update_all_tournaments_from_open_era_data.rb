module Tournaments
  class CreateOrUpdateAllTournamentsFromOpenEraData
    include Service

    def initialize
    end

    def call
      # iterate from 1968 to previous year
      (1968..Time.now.year - 1).each do |year|
        Tournaments::CreateOrUpdateTournamentsPerYearData.call(year: year)
      end
    end
  end
end
