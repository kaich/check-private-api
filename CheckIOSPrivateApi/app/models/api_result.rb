class ApiResult < ActiveRecord::Base
  serialize :result, JSON
end
